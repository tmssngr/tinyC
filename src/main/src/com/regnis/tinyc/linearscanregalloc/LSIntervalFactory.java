package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class LSIntervalFactory {

	public static void printInstructions(@NotNull List<IRInstruction> instructions) {
		int pos = 0;
		for (IRInstruction instruction : instructions) {
			System.out.printf("%03d %s %s\n",
			                  pos,
			                  instruction instanceof IRLabel ? "" : "    ",
			                  instruction.toString(true));
			pos += 2;
		}
	}

	private final List<LSInterval> varIntervals = new ArrayList<>();
	private final Map<IRVar, LSInterval> varToInterval = new HashMap<>();
	private final LSInterval[] fixedIntervals;
	private final LSInstructions lsInstructions;
	private final IRCanBeRegister canBeRegister;
	private final LSCallingConventionProvider callingConventionProvider;
	private final boolean isX86;

	private int pos;
	private int blockStart;

	public LSIntervalFactory(@NotNull LSInstructions lsInstructions, @NotNull IRCanBeRegister canBeRegister, @NotNull LSCallingConventionProvider callingConventionProvider, int registerCount, boolean isX86) {
		this.lsInstructions = lsInstructions;
		this.canBeRegister = canBeRegister;
		this.callingConventionProvider = callingConventionProvider;
		this.isX86 = isX86;

		fixedIntervals = new LSInterval[registerCount];
	}

	public void debugPrint(@NotNull String name) {
		debugPrint(name, varIntervals);
	}

	public void debugPrint(@NotNull String name, List<LSInterval> varIntervals) {
		System.out.println(name);

		final int max = determineMaxPos();

		printFixedIntervals(max);
		System.out.println();

		printVarIntervals(max, varIntervals);
		System.out.println();
	}

	@NotNull
	public List<LSInterval> getVarIntervals() {
		return Collections.unmodifiableList(this.varIntervals);
	}

	@NotNull
	public List<LSInterval> getFixedIntervals() {
		final List<LSInterval> fixedIntervals = new ArrayList<>();
		for (LSInterval interval : this.fixedIntervals) {
			if (interval != null) {
				fixedIntervals.add(interval);
			}
		}
		return Collections.unmodifiableList(fixedIntervals);
	}

	public void handleInstructions(@NotNull List<IRInstruction> instructions) {
		final Set<IRVar> live = new HashSet<>();
		boolean blockBoundary = true;
		for (int i = instructions.size(); i-- > 0; ) {
			pos = 2 * i;
			if (blockBoundary) {
				final var result = lsInstructions.getLiveVarsAndBlockStartAt(pos);
				final List<IRVar> liveVars = result.first();
				blockStart = result.second();
				liveVars.forEach(var -> {
					if (canBeRegister.canBeRegister(var)) {
						final LSInterval interval = getInterval(var);
						interval.add(blockStart, pos);
					}
				});
				live.addAll(liveVars);
			}

			final IRInstruction instruction = instructions.get(i);
			handleInstruction(instruction, live);
			blockBoundary = instruction instanceof IRLabel;
		}
	}

	private void printVarIntervals(int max, List<LSInterval> varIntervals) {
		final List<LSInstructions.Indices> indices = lsInstructions.getBlockIndices();
		final List<LSInterval> intervals = new ArrayList<>(varIntervals);
		intervals.sort(Comparator.comparingInt(LSInterval::getFrom));
		for (LSInterval interval : intervals) {
			while (interval != null) {
				final String rangesString = interval.rangesAsString(max, indices);
				println(interval.getName(), rangesString);
				interval = interval.getNextSplit();
			}
		}
	}

	private int determineMaxPos() {
		int max = 0;
		for (LSInterval interval : fixedIntervals) {
			if (interval != null) {
				max = Math.max(interval.getTo(), max);
			}
		}
		for (LSInterval interval : varIntervals) {
			while (true) {
				final LSInterval split = interval.getNextSplit();
				if (split == null) {
					break;
				}
				interval = split;
			}
			max = Math.max(interval.getTo(), max);
		}
		return max;
	}

	private void handleInstruction(@NotNull IRInstruction instruction, @NotNull Set<IRVar> live) {
//		System.out.println(getIndex() + ":\t" + instruction);

		switch (instruction) {
		case IRAddConst addConst -> {
			final IRVar var = addConst.var();
			handleTarget(var, live);
			handleSource(var, live);
		}
		case IRAddrOf addrOf -> handleTarget(addrOf.target(), live);
		case IRAddrOfArray addrOf -> handleTarget(addrOf.addr(), live);
		case IRBinary binary -> {
			final IRVar left = binary.left();
			final IRVar right = binary.right();
			final IRVar target = binary.target();

			if (isX86) {
				final int rax = 0;
				final int rcx = 1;
				final int rdx = 2;
				// https://www.felixcloutier.com/x86/idiv
				switch (binary.op()) {
				case Div -> {
					// (rdx rax) / %reg -> rax
					expectRegister(left, rax);
					expectRegister(target, rax);

					handleTarget(target, live);
					getRegisterInterval(rdx).add(pos - 1, pos);

					handleSource(left, live);
					handleSource(right, live);
					return;
				}
				case Mod -> {
					// (rdx rax) % %reg -> rdx
					expectRegister(left, rax);
					expectRegister(target, rdx);

					getRegisterInterval(rax).add(pos, pos + 1);

					handleTarget(target, live);
					final LSInterval rdxInterval = getRegisterInterval(rdx);
					Utils.assertTrue(rdxInterval.getFrom() >= 0);
					rdxInterval.truncateFirstRangeTo(pos - 1);

					handleSource(left, live);
					handleSource(right, live);
					return;
				}
				case ShiftLeft, ShiftRight -> expectRegister(right, rcx);
				}
			}

			handleTarget(target, live);
			handleSource(left, live);
			handleSource(right, live);
		}
		case IRBranch branch -> handleSource(branch.conditionVar(), live);
		case IRCall call -> {
			final IRVar target = call.target();
			if (target != null) {
				expectRegister(target, 0);
				handleTarget(target, live);
			}

			final LSCallingConvention targetCallingConvention = callingConventionProvider.getCallingConvention(call.type(), call.getArgumentTypes());

			for (int i = 0; i < targetCallingConvention.volatileRegisterCount(); i++) {
				if (target != null && i == 0) {
					// already handled above
					continue;
				}

				final LSInterval interval = getRegisterInterval(i);
				interval.add(pos, pos + 1);
			}

			for (IRVar arg : call.args()) {
				if (arg.scope() == VariableScope.register) {
					handleSource(arg, live);
				}
				else {
					Utils.assertTrue(arg.scope() == VariableScope.function);
					Utils.assertTrue(!canBeRegister.canBeRegister(arg));
					live.add(arg);
				}
			}
		}
		case IRCast cast -> {
			handleTarget(cast.target(), live);
			handleSource(cast.source(), live);
		}
		case IRComment ignored -> {
		}
		case IRCompare compare -> {
			handleTarget(compare.target(), live);
			handleSource(compare.left(), live);
			handleSource(compare.right(), live);
		}
		case IRCompareConst compare -> {
			handleTarget(compare.target(), live);
			handleSource(compare.left(), live);
		}
		case IRJump ignored -> {
		}
		case IRLabel ignored -> {
		}
		case IRLiteral literal -> handleTarget(literal.target(), live);
		case IRMemLoad load -> {
			handleTarget(load.target(), live);
			handleSource(load.addr(), live);
		}
		case IRMemStore store -> {
			handleSource(store.addr(), live);
			handleSource(store.value(), live);
		}
		case IRMove move -> handleMove(move.source(), move.target(), live);
		case IRString literal -> handleTarget(literal.target(), live);
		case IRUnary unary -> {
			handleTarget(unary.target(), live);
			handleSource(unary.source(), live);
		}
		default -> throw new UnsupportedOperationException(instruction.toString());
		}
	}

	private void printFixedIntervals(int max) {
		final List<LSInstructions.Indices> indices = lsInstructions.getBlockIndices();
		for (int reg = 0; reg < fixedIntervals.length; reg++) {
			final LSInterval interval = fixedIntervals[reg];
			if (interval == null) {
				continue;
			}
			final String rangesString = interval.rangesAsString(max, indices);
			println("r" + reg, rangesString);
		}
	}

	private void println(String s1, String s2) {
		System.out.printf("%14s %s\n", s1, s2);
	}

	private void expectRegister(IRVar target, int expectedReg) {
		Utils.assertTrue(target.scope() == VariableScope.register);
		Utils.assertTrue(target.index() == expectedReg);
	}

	private void handleMove(@NotNull IRVar source, @NotNull IRVar target, @NotNull Set<IRVar> live) {
		if (target.scope() == VariableScope.global) {
			Utils.assertTrue(source.scope() != VariableScope.global);
			Utils.assertTrue(canBeRegister.canBeRegister(source));
			handleSource(source, live);
			return;
		}

		if (target.scope() != VariableScope.register) {
			Utils.assertTrue(live.contains(target));
			if (!canBeRegister.canBeRegister(target)) {
				Utils.assertTrue(source.scope() != VariableScope.global);
				Utils.assertTrue(canBeRegister.canBeRegister(source));
				live.remove(target);

				handleSource(source, live);
				return;
			}
		}

		final LSInterval targetInterval = handleTarget(target, live);
		if (source.scope() == VariableScope.global) {
			return;
		}
		if (!canBeRegister.canBeRegister(source)) {
			return;
		}

		if (source.scope() == VariableScope.register) {
			// this may overwrite an already set register hint
			targetInterval.setRegisterHint(source.index());
		}
		final LSInterval sourceInterval = handleSource(source, live);
		if (target.scope() == VariableScope.register) {
			sourceInterval.setRegisterHint(target.index());
		}
	}

	private LSInterval handleSource(@NotNull IRVar var, Set<IRVar> live) {
		Utils.assertTrue(var.scope() != VariableScope.global);
		if (var.scope() != VariableScope.register) {
			live.add(var);
		}
		final LSInterval interval = getInterval(var);
		if (pos > blockStart) {
			interval.add(blockStart, pos);
		}
		interval.addReadUse(pos);
		return interval;
	}

	@NotNull
	private LSInterval handleTarget(@NotNull IRVar var, Set<IRVar> live) {
		Utils.assertTrue(var.scope() != VariableScope.global);
		if (var.scope() != VariableScope.register) {
			Utils.assertTrue(canBeRegister.canBeRegister(var));
			live.remove(var);
		}

		final LSInterval interval = getInterval(var);
		// no range yet?
		if (interval.getFrom() < 0) {
			Utils.assertTrue(var.scope() == VariableScope.register);
			Utils.assertTrue(var.index() == 0);
			interval.add(pos, pos + 1);
			return interval;
		}

		interval.truncateFirstRangeTo(pos);
		interval.addWritePos(pos);
		return interval;
	}

	@NotNull
	private LSInterval getInterval(@NotNull IRVar var) {
		if (var.scope() == VariableScope.register) {
			return getRegisterInterval(var.index());
		}

		LSInterval interval = varToInterval.get(var);
		if (interval == null) {
			interval = new LSInterval(var);
			varToInterval.put(var, interval);
			varIntervals.add(interval);
		}
		return interval;
	}

	@NotNull
	private LSInterval getRegisterInterval(int reg) {
		LSInterval interval = fixedIntervals[reg];
		if (interval == null) {
			interval = new LSInterval(reg);
			fixedIntervals[reg] = interval;
		}
		return interval;
	}

	public interface Indices {
		int start();

		int end();
	}

	private static final class IndicesImpl implements Indices {
		private final int start;

		private int end;

		public IndicesImpl(int start) {
			this.start = start;
			end = start;
		}

		@Override
		public String toString() {
			return "[" + start + "-" + end + ")";
		}

		public int start() {
			return start;
		}

		public int end() {
			return end;
		}

		public void setEnd(int end) {
			Utils.assertTrue(end >= this.end);
			this.end = end;
		}
	}
}
