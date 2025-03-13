package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class LSAlgorithm {

	private final List<LSInterval> active = new ArrayList<>();
	private final List<LSInterval> inactive = new ArrayList<>();
	private final Map<IRVar, LSVarRegisters> varToRegisters = new LinkedHashMap<>();
	private final List<LSInterval> fixedIntervals;
	private final List<LSInterval> unhandled;
	private final int registerCount;

	public LSAlgorithm(@NotNull List<LSInterval> varIntervals, @NotNull List<LSInterval> fixedIntervals, int registerCount) {
		this.unhandled = new ArrayList<>(varIntervals);
		this.fixedIntervals = fixedIntervals;
		this.registerCount = registerCount;
	}

	@NotNull
	public Map<IRVar, LSVarRegisters> run() {
		unhandled.forEach(i -> varToRegisters.put(i.var(), new LSVarRegisters(i.var())));

		int prevFrom = 0;
		while (unhandled.size() > 0) {
			final LSInterval current = unhandled.removeFirst();
			final int from = current.getFrom();
			Utils.assertTrue(from >= prevFrom);
			prevFrom = from;
			checkActiveForExpiredOrInactive(from);
			checkInactiveForExpiredOrInactive(from);

			if (!tryAllocateFree(current)) {
				allocateBlockedReg(current);
			}

			if (current.register() >= 0) {
				active.add(current);
			}
		}

		active.forEach(this::addToDone);
		inactive.forEach(this::addToDone);
		return varToRegisters;
	}

	private void checkActiveForExpiredOrInactive(int pos) {
		for (final Iterator<LSInterval> it = active.iterator(); it.hasNext(); ) {
			final LSInterval interval = it.next();
			final int lastTo = interval.getTo();
			if (pos >= lastTo) {
				it.remove();
				addToDone(interval);
				continue;
			}

			if (!interval.contains(pos)) {
				it.remove();
				inactive.add(interval);
			}
		}
	}

	private void checkInactiveForExpiredOrInactive(int position) {
		for (final Iterator<LSInterval> it = inactive.iterator(); it.hasNext(); ) {
			final LSInterval interval = it.next();
			final int lastTo = interval.getTo();
			if (position > lastTo) {
				it.remove();
				addToDone(interval);
				continue;
			}

			if (interval.contains(position)) {
				it.remove();
				active.add(interval);
			}
		}
	}

	private boolean tryAllocateFree(LSInterval current) {
		final RegisterPositions registersFreeUntil = new RegisterPositions(registerCount);
		prepareFreeUntil(current, registersFreeUntil);

		final int currentTo = current.getTo();

		final int registerHint = current.getRegisterHint();
		final int reg;
		if (registerHint >= 0 && registersFreeUntil.get(registerHint) >= currentTo) {
			reg = registerHint;
		}
		else {
			reg = registersFreeUntil.getExactOrMax(currentTo);
			if (reg < 0) {
				return false;
			}
		}

		final int maxFreeUntil = registersFreeUntil.get(reg);
		if (maxFreeUntil < currentTo) {
			final LSInterval split = current.truncateAndSplit(maxFreeUntil);
			addToUnhandled(split);
		}
		current.setRegister(reg);
		return true;
	}

	private void prepareFreeUntil(LSInterval current, RegisterPositions registersFreeUntil) {
		final int from = current.getFrom();
		for (LSInterval interval : fixedIntervals) {
			final int freeUntil = interval.getFreeUntil(from);
			registersFreeUntil.setMinPos(freeUntil, interval);
		}

		for (LSInterval interval : active) {
			registersFreeUntil.setMinPos(0, interval);
		}

		for (LSInterval interval : inactive) {
			final int freeUntil = LSInterval.getFirstIntersection(interval, current);
			registersFreeUntil.setMinPos(freeUntil, interval);
		}
	}

	/**
	 * The interval that is not used for the longest time is spilled because
	 * this frees a register as long as possible.
	 */
	private void allocateBlockedReg(LSInterval current) {
		final RegisterPositions registersUsedNext = new RegisterPositions(registerCount);
		final RegisterPositions registersBlockedNext = new RegisterPositions(registerCount);

		final int from = current.getFrom();
		prepareUseAndBlockPos(from, registersUsedNext, registersBlockedNext);

		final int reg = Math.max(registersUsedNext.getMax(), 0);
		final int maxUsedNext = registersUsedNext.get(reg);

		final int firstCurrentUse = current.getUsedNext(0, Integer.MAX_VALUE);
		if (firstCurrentUse > maxUsedNext) {
			// If the first use position of the current interval is found
			// after the highest use_pos, it is better to spill current.
			if (firstCurrentUse > from && firstCurrentUse < Integer.MAX_VALUE) {
				final LSInterval split = current.truncateAndSplit(firstCurrentUse);
				addToUnhandled(split);
			}
			addToDone(current);
			return;
		}

		// Otherwise, current gets the selected register assigned.
		current.setRegister(reg);

		final int blockedNext = registersBlockedNext.get(reg);
		if (blockedNext <= current.getTo()) {// If the selected register has a block_pos somewhere in the middle of current,
			// then the register is not available for the whole lifetime. So current is
			// split before block_pos, and the split child is sorted into the unhandled list.
			final LSInterval split = current.truncateAndSplit(blockedNext - 1);
			addToUnhandled(split);
		}

		// All active and inactive intervals for this register intersecting with
		// current are split before the start of current and spilled to the stack.
		spillAndSplit(current, reg, active);
		spillAndSplit(current, reg, inactive);
	}

	private void prepareUseAndBlockPos(int from, RegisterPositions registersUsedNext, RegisterPositions registersBlockedNext) {
		for (LSInterval interval : fixedIntervals) {
			final int freeUntil = interval.getFreeUntil(from);
			registersUsedNext.setMinPos(freeUntil, interval);
			registersBlockedNext.setMinPos(freeUntil, interval);
		}

		for (LSInterval interval : active) {
			registersUsedNext.setMinPos(0, interval);
		}

		for (LSInterval interval : inactive) {
			final int usedNext = interval.getUsedNext(from, Integer.MAX_VALUE);
			registersUsedNext.setMinPos(usedNext, interval);
		}
	}

	private void spillAndSplit(LSInterval current, int reg, List<LSInterval> intervals) {
		final int from = current.getFrom();
		for (LSInterval interval : intervals) {
			if (interval.register() != reg
			    || LSInterval.getFirstIntersection(interval, current) < 0) {
				continue;
			}

			// These split children are not considered during allocation
			// any more because they do not have a register assigned. If they have a use positions
			// requiring a register, however, they must be reloaded again to a register later on.
			// Therefore, they are split a second time before these use positions, and the second
			// split children are sorted into the unhandled list.
			final LSInterval split = interval.truncateAndSplit(from - 1);
			final int nextUse = split.getUsedNext(0, -1);
			if (nextUse < 0) {
				continue;
			}

			final LSInterval secondSplit = split.truncateAndSplit(nextUse - 1);
			addToUnhandled(secondSplit);
		}
	}

	private void addToUnhandled(LSInterval split) {
		final int pos = Utils.binarySearch(split, unhandled, LSInterval::getFrom);
		unhandled.add(pos, split);
	}

	private void addToDone(@NotNull LSInterval interval) {
		final LSVarRegisters registers = varToRegisters.get(interval.var());
		registers.add(interval, interval.uses());
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
	}
}
