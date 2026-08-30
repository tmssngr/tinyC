package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class LSAlgorithm {

	@NotNull
	public static Map<IRVar, LSInterval> perform(@NotNull Map<IRVar, LSInterval> varIntervals, @NotNull List<LSInterval> intervals, int registerCount, @NotNull LSAlgorithmLogger logger) {
		final LSAlgorithm algorithm = new LSAlgorithm(varIntervals, intervals, registerCount, logger);
		return algorithm.run();
	}

	private final List<LSInterval> unhandled = new ArrayList<>();
	private final List<LSInterval> active = new ArrayList<>();
	private final List<LSInterval> inactive = new ArrayList<>();
	private final Map<IRVar, LSInterval> varToInterval = new LinkedHashMap<>();
	private final Map<IRVar, LSInterval> varIntervals;
	private final LSAlgorithmLogger logger;
	private final List<LSInterval> fixedIntervals;
	private final int registerCount;

	private LSAlgorithm(@NotNull Map<IRVar, LSInterval> varIntervals, @NotNull List<LSInterval> fixedIntervals, int registerCount, @NotNull LSAlgorithmLogger logger) {
		Utils.assertTrue(registerCount > 1);
		this.varIntervals = varIntervals;
		this.fixedIntervals = fixedIntervals;
		this.registerCount = registerCount;
		this.logger = logger;
	}

	private Map<IRVar, LSInterval> run() {
		varIntervals.values().forEach(interval -> unhandled.add(new LSInterval(interval)));
		// if two intervals start at the same position,
		// the longer one should be before the shorter one
		unhandled.sort((o1, o2) -> {
			int result = o1.getFrom() - o2.getFrom();
			if (result == 0) {
				// flipped
				result = o2.getTo() - o1.getTo();
			}
			return result;
		});
		logger.initialize(unhandled);

		int prevFrom = 0;
		while (unhandled.size() > 0) {
			final LSInterval current = unhandled.removeFirst();
			final int from = current.getFrom();
			Utils.assertTrue(from >= prevFrom);
			prevFrom = from;
			makeActiveOrInactive(from, false, active, inactive);
			makeActiveOrInactive(from, true, inactive, active);
			logger.log("Unhandled:", unhandled);
			logger.log("Fixed:", fixedIntervals);
			logger.log("Active:", active);
			logger.log("Inactive:", inactive);
			logger.log("Current '" + current.toDebugString() + ":", current);

			if (!tryAllocateFree(current)) {
				allocateBlockedReg(current);
			}

			logger.log("");
		}

		active.forEach(this::addToDone);
		inactive.forEach(this::addToDone);
		return Collections.unmodifiableMap(varToInterval);
	}

	private void makeActiveOrInactive(int pos, boolean makeActive, List<LSInterval> from, List<LSInterval> to) {
		for (final Iterator<LSInterval> it = from.iterator(); it.hasNext(); ) {
			final LSInterval interval = it.next();
			final int lastTo = interval.getTo();
			if (pos >= lastTo) {
				it.remove();
				logger.log("->done:");
				logger.log(interval);
				addToDone(interval);
				continue;
			}

			if (makeActive == interval.contains(pos)) {
				logger.log(makeActive ? "-> active:" : "-> inactive:");
				logger.log(interval);
				it.remove();
				to.add(interval);
			}
		}
	}

	private boolean tryAllocateFree(LSInterval current) {
		final RegisterPositions registersFreeUntil = new RegisterPositions(registerCount);
		prepareFreeUntil(current, registersFreeUntil);
		registersFreeUntil.log("free until:", logger);

		final int currentTo = current.getTo();

		final int registerHint = current.getRegisterHint();
		int reg = getIdealRegister(registerHint, currentTo, registersFreeUntil);
		if (reg < 0) {
			return false;
		}

		final int maxFreeUntil = registersFreeUntil.get(reg);
		if (maxFreeUntil >= currentTo) {
			setRegister(current, reg);
			return true;
		}

		final LSUse firstUse = current.getUsedNext(0);
		if (firstUse == null) {
			addToDone(current);
			return true;
		}

		final int firstUsePos = firstUse.pos();
		if (firstUsePos > maxFreeUntil) {
			final LSInterval splitStartingWithUse = truncateAndSplit(current, firstUsePos - 1);
			addToDone(current);
			addToUnhandled(splitStartingWithUse);
			return true;
		}

		final int splitPos = getIdealSplitPosition(current, maxFreeUntil);
		reg = getIdealRegister(registerHint, splitPos, registersFreeUntil);
		Utils.assertTrue(reg >= 0);
		setRegister(current, reg);
		final LSInterval split = truncateAndSplit(current, splitPos + 1);
		if (firstUsePos > splitPos + 1) {
			addToDone(split);
			return true;
		}

		splitRemainingInterval(split);
		return true;
	}

	private int getIdealRegister(int registerHint, int to, RegisterPositions registersFreeUntil) {
		if (registerHint >= 0 && registersFreeUntil.get(registerHint) >= to) {
			return registerHint;
		}
		return registersFreeUntil.getExactOrMax(to);
	}

	private void prepareFreeUntil(LSInterval current, RegisterPositions registersFreeUntil) {
		final int from = current.getFrom();
		for (LSInterval interval : fixedIntervals) {
			final int freeUntil = interval.getFreeUntil(from);
			registersFreeUntil.setMinPos(freeUntil, interval);
		}

		for (LSInterval interval : active) {
			registersFreeUntil.setMinPos(-1, interval);
		}

		for (LSInterval interval : inactive) {
			final int firstIntersection = LSInterval.getFirstIntersection(interval, current);
			if (firstIntersection >= 0) {
				registersFreeUntil.setMinPos(firstIntersection, interval);
			}
		}
	}

	private int getIdealSplitPosition(LSInterval interval, int maxPos) {
		final LSUse use = interval.getUseBefore(maxPos);
		if (use == null) {
			return maxPos;
		}

		final int usePos = use.pos();
		Utils.assertTrue(usePos < maxPos);
		return usePos;
	}

	/**
	 * The interval that is not used for the longest time is spilled because
	 * this frees a register as long as possible.
	 */
	private void allocateBlockedReg(LSInterval current) {
		final RegisterPositions registersUsedNext = new RegisterPositions(registerCount);
		final RegisterPositions registersBlockedNext = new RegisterPositions(registerCount);

		final int from = current.getFrom();
		prepareUseAndBlockPos(current, registersUsedNext, registersBlockedNext);

		registersUsedNext.log("used next:", logger);

		final LSUse firstUse = current.getUsedNext(0);
		Utils.assertTrue(firstUse != null);

		final int currentNextUse = firstUse.pos();
		final int reg = Math.max(registersUsedNext.getMax(), 0);
		final int regUsedNextAt = registersUsedNext.get(reg);
		if (regUsedNextAt < currentNextUse) {
			// all active and inactive intervals are used before current, so it is best to spill current
			final LSInterval split = truncateAndSplit(current, currentNextUse - 1);
			addToDone(current);
			addToUnhandled(split);
			return;
		}

		registersBlockedNext.log("blocked next:", logger);
		final int regBlockedNextAt = registersBlockedNext.get(reg);
		if (regBlockedNextAt < current.getTo()) {
			// If the selected register has a blocked pos somewhere in the middle of current
			// then the register is not available for the whole lifetime. So current must be
			// split before the blocked pos and the split part be sorted to the unhandled list.
			int splitPos = regBlockedNextAt - 1;
			final LSUse prevUse = current.getUseBefore(splitPos);
			if (prevUse != null) {
				// todo: determine ideal split position, somewhere between `last use before (regBlockedNextAt - 1) -1` and `regBlockedNextAt - 1`
				Utils.assertTrue(prevUse.pos() < splitPos);
				splitPos = prevUse.pos() + 1;
			}
			final LSInterval split = truncateAndSplit(current, splitPos);
			splitRemainingInterval(split);
		}

		for (LSInterval active : this.active) {
			if (active.register() != reg) {
				continue;
			}
			this.active.remove(active);
			setRegister(current, reg);
			splitOffSpilledPart(from, active);
			break;
		}

		for (LSInterval inactive : this.inactive) {
			final int intersectionAt = LSInterval.getFirstIntersection(current, inactive);
			if (intersectionAt < 0) {
				continue;
			}

			splitOffSpilledPart(from, inactive);
		}
	}

	private void splitRemainingInterval(LSInterval interval) {
		final LSUse nextUse = interval.getUsedNext(0);
		if (nextUse != null && nextUse.pos() > interval.getFrom()) {
			final LSInterval split = truncateAndSplit(interval, nextUse.pos() - 1);
			addToDone(interval);
			addToUnhandled(split);
		}
		else {
			addToUnhandled(interval);
		}
	}

	private void splitOffSpilledPart(int from, LSInterval interval) {
		if (interval.getFrom() == from) {
			interval.setRegister(-1);
			addToUnhandled(interval);
			return;
		}

		final LSInterval split = truncateAndSplit(interval, from);
		addToDone(interval);

		final LSUse usedNext = split.getUsedNext(from);
		if (usedNext != null) {
			final int usePos = usedNext.pos();
			if (usePos == split.getFrom()) {
				addToUnhandled(split);
				return;
			}

			final LSInterval usedPart = truncateAndSplit(split, usePos - 1);
			addToUnhandled(usedPart);
		}
		Utils.assertTrue(split.register() < 0);
		Utils.assertTrue(split.uses().isEmpty());
		addToDone(split);
	}

	private void prepareUseAndBlockPos(LSInterval current, RegisterPositions registersUsedNext, RegisterPositions registersBlockedNext) {
		// registersUsedNext[reg] stores the position where an interval with a register reg
		// assigned is used next. It is calculated by interating all active and inactive
		// intervals and searching their next use position after current's from-position.
		final int from = current.getFrom();
		for (LSInterval interval : active) {
			final LSUse usedNext = interval.getUsedNext(from + 1);
			if (usedNext != null) {
				registersUsedNext.setMinPos(usedNext.pos(), interval);
			}
		}

		for (LSInterval interval : inactive) {
			final int firstIntersection = LSInterval.getFirstIntersection(interval, current);
			if (firstIntersection >= 0) {
				final LSUse usedNext = interval.getUsedNext(firstIntersection);
				if (usedNext != null) {
					registersUsedNext.setMinPos(usedNext.pos(), interval);
				}
			}
		}

		// registersBlockedNext[reg] stores a hard limit for each register where the register
		// cannot be freed by spilling. This position is set by the fixed intervals. Setting
		// a blocked pos implicitly sets used-next pos, so used-next pos of a register never
		// is higher than blocked pos.
		for (LSInterval interval : fixedIntervals) {
			final int blockedAt = interval.getFreeUntil(from);
			registersUsedNext.setMinPos(blockedAt, interval);
			registersBlockedNext.setMinPos(blockedAt, interval);
		}
	}

	@NotNull
	private LSInterval truncateAndSplit(LSInterval interval, int pos) {
		logger.log("Split", interval);
		final LSInterval split = interval.truncateAndSplit(pos);
		logger.log("into", interval);
		logger.log("and", split);
		return split;
	}

	private void addToUnhandled(LSInterval split) {
		split.setRegister(-1);

		int pos = Collections.binarySearch(unhandled, split, (i1, i2) -> {
			final int from1 = i1.getFrom();
			final int from2 = i2.getFrom();
			if (from1 != from2) {
				return from1 - from2;
			}
			final LSUse nextUse1 = i1.getUsedNext(0);
			final LSUse nextUse2 = i2.getUsedNext(0);
			final int nextUsePos1 = nextUse1 != null ? nextUse1.pos() : Integer.MAX_VALUE;
			final int nextUsePos2 = nextUse2 != null ? nextUse2.pos() : Integer.MAX_VALUE;
			return nextUsePos2 - nextUsePos1;
		});
		if (pos < 0) {
			pos = -1 - pos;
		}
		unhandled.add(pos, split);
	}

	private void setRegister(LSInterval current, int reg) {
		Utils.assertTrue(reg >= 0);

		logger.log(current.getName() + ": assigned r" + reg);
		current.setRegister(reg);
		active.add(current);
	}

	private void addToDone(@NotNull LSInterval interval) {
		logger.log("Done", interval);
		final IRVar var = interval.var();
		final LSInterval prevInterval = varToInterval.get(var);
		if (prevInterval == null
		    || prevInterval.getFrom() >= interval.getFrom()) {
			varToInterval.put(var, interval);
		}
	}

	private static final class RegisterPositions {
		private final int[] positions;

		public RegisterPositions(int registerCount) {
			positions = new int[registerCount];
			Arrays.fill(positions, Integer.MAX_VALUE);
		}

		@Override
		public String toString() {
			return Arrays.toString(positions);
		}

		public void setMinPos(int pos, LSInterval interval) {
			final int register = interval.register();
			final int prev = positions[register];
			positions[register] = Math.min(pos, prev);
		}

		public int get(int r) {
			return positions[r];
		}

		public int getExactOrMax(int to) {
			for (int reg = 0; reg < positions.length; reg++) {
				final int pos = positions[reg];
				if (pos == to) {
					return reg;
				}
			}
			return getMax();
		}

		public int getMax() {
			int maxReg = -1;
			int max = 0;
			for (int reg = 0; reg < positions.length; reg++) {
				final int pos = positions[reg];
				if (pos > max) {
					max = pos;
					maxReg = reg;
				}
			}
			return maxReg;
		}

		public void log(String s, LSAlgorithmLogger logger) {
			logger.log(s);
			final StringBuilder buffer = new StringBuilder();
			for (int i = 0; i < positions.length; i++) {
				buffer.append(new Formatter().format("  r%02d", i));
			}
			logger.log(buffer.toString());
			buffer.setLength(0);
			for (final int position : positions) {
				buffer.append(new Formatter().format("  %3d", Math.min(999, position)));
			}
			logger.log(buffer.toString());
		}
	}
}
