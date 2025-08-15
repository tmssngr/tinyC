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

	private final List<IRInstruction> instructions = new ArrayList<>();
	private final Map<String, Indices> blockToIndex = new HashMap<>();
	private final List<LSInterval> varIntervals = new ArrayList<>();
	private final Map<IRVar, LSInterval> varToInterval = new HashMap<>();
	private final LSInterval[] fixedIntervals;
	private final IRCanBeRegister canBeRegister;
	private final LSCallingConventionProvider callingConventionProvider;
	private final boolean isX86;

	private IndicesImpl indices;

	public LSIntervalFactory(@NotNull IRCanBeRegister canBeRegister, @NotNull LSCallingConventionProvider callingConventionProvider, int registerCount, boolean isX86) {
		this.canBeRegister = canBeRegister;
		this.callingConventionProvider = callingConventionProvider;
		this.isX86 = isX86;

		fixedIntervals = new LSInterval[registerCount];
	}

	public void debugPrint(@NotNull String name) {
		System.out.println(name);

		printFixedIntervals();
		System.out.println();

		printVarIntervals(varIntervals);
		System.out.println();
	}

	@NotNull
	public List<IRInstruction> getInstructions() {
		return Collections.unmodifiableList(instructions);
	}

	@NotNull
	public List<LSInterval> getVarIntervalsSorted() {
		final List<LSInterval> varIntervals = new ArrayList<>(this.varIntervals);
		// if two intervals start at the same position,
		// the longer one should be before the shorter one
		varIntervals.sort((o1, o2) -> {
			int result = o1.getFrom() - o2.getFrom();
			if (result == 0) {
				// flipped
				result = o2.getTo() - o1.getTo();
			}
			return result;
		});
		return Collections.unmodifiableList(varIntervals);
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

	public Map<String, Indices> getBlockToIndex() {
		return Collections.unmodifiableMap(blockToIndex);
	}

	public void addFunctionArgs(@NotNull IRVarInfos varInfos, @NotNull List<Integer> argRegisters) {
		Utils.assertTrue(instructions.isEmpty());

		for (IRVarDef varDef : varInfos.vars()) {
			final IRVar var = varDef.var();
			if (var.scope() != VariableScope.argument) {
				continue;
			}

			final int index = var.index();
			if (index >= argRegisters.size()) {
				continue;
			}

			final int register = argRegisters.get(index);
			final LSInterval interval = getRegisterInterval(register);
			interval.startNewRange(-1);
		}
	}

	public void blockStart(String name, @NotNull Set<IRVar> liveBefore) {
		// just to create predictable order
		final List<IRVar> liveBeforeSorted = new ArrayList<>(liveBefore);
		liveBeforeSorted.sort(Comparator.comparing(IRVar::index));

		final int index = getIndex();
		indices = new IndicesImpl(index);
		blockToIndex.put(name, indices);

		for (IRVar var : liveBeforeSorted) {
			if (!canBeRegister(var)) {
				continue;
			}
			final LSInterval interval = getInterval(var);
			interval.extendRangeMaybeCreate(index);
		}
	}

	public void addInstruction(@NotNull IRInstruction instruction, @NotNull Set<IRVar> liveAfter) {
//		System.out.println(getIndex() + ":\t" + instruction);

		switch (instruction) {
		case IRAddConst addConst -> {
			handleSource(addConst.var());
			handleTarget(addConst.var());
		}
		case IRAddrOf addrOf -> {
			handleTarget(addrOf.target());
		}
		case IRAddrOfArray addrOf -> handleTarget(addrOf.addr());
		case IRBinary binary -> {
			final IRVar left = binary.left();
			final IRVar right = binary.right();
			final IRVar target = binary.target();
			handleSource(left);
			handleSource(right);

			final IRBinary.Op op = binary.op();
			if (isX86) {
				switch (op) {
				case Div -> {
					// https://www.felixcloutier.com/x86/idiv
					// (rdx rax) / %reg -> rax
					final int index = getIndex();
					final int rax = 0;
					final int rdx = 2;
					expectRegister(left, rax);
					expectRegister(target, rax);
					getRegisterInterval(rax).startNewRangeIfSmaller(index);
					getRegisterInterval(rdx).startNewRangeIfSmaller(index);
				}
				case Mod -> {
					// https://www.felixcloutier.com/x86/idiv
					// (rdx rax) % %reg -> rdx
					final int index = getIndex();
					final int rax = 0;
					final int rdx = 2;
					expectRegister(left, rax);
					expectRegister(target, rdx);
					getRegisterInterval(rax).startNewRangeIfSmaller(index);
					getRegisterInterval(rdx).startNewRangeIfSmaller(index);
				}
				case ShiftLeft, ShiftRight -> {
					final int index = getIndex();
					final int rcx = 1;
					expectRegister(right, rcx);
					getRegisterInterval(rcx).startNewRangeIfSmaller(index);
				}
				}
			}

			handleTarget(binary.target());
		}
		case IRBranch branch -> handleSource(branch.conditionVar());
		case IRCall call -> {
			for (IRVar arg : call.args()) {
				handleSource(arg);
			}

			final LSCallingConvention targetCallingConvention = callingConventionProvider.getCallingConvention(call.type(), call.getArgumentTypes());

			final int index = getIndex();
			for (int i = 0; i < targetCallingConvention.volatileRegisterCount(); i++) {
				final LSInterval interval = getRegisterInterval(i);
				// can already be larger by handleSource of args
				interval.startNewRangeIfSmaller(index);
			}

			final IRVar target = call.target();
			if (target != null) {
				expectRegister(target, 0);
				final LSInterval interval = getInterval(target);
				interval.extendRange(index + 2);
				interval.addUse(index + 1);
			}
		}
		case IRCast cast -> {
			handleSource(cast.source());
			handleTarget(cast.target());
		}
		case IRComment ignored -> {
		}
		case IRCompare compare -> {
			handleSource(compare.left());
			handleSource(compare.right());
			handleTarget(compare.target());
		}
		case IRCompareConst compare -> {
			handleSource(compare.left());
			handleTarget(compare.target());
		}
		case IRJump ignored -> {
		}
		case IRLabel ignored -> {
		}
		case IRLiteral literal -> handleTarget(literal.target());
		case IRMemLoad load -> {
			handleSource(load.addr());
			handleTarget(load.target());
		}
		case IRMemStore store -> {
			handleSource(store.addr());
			handleSource(store.value());
		}
		case IRMove move -> {
			final IRVar source = move.source();
			handleSource(source);
			final LSInterval interval = handleTarget(move.target());
			if (interval != null && source.scope() == VariableScope.register) {
				interval.setRegisterHint(source.index());
			}
		}
		case IRString literal -> handleTarget(literal.target());
		case IRUnary unary -> {
			handleSource(unary.source());
			handleTarget(unary.target());
		}
		default -> throw new UnsupportedOperationException(instruction.toString());
		}

		extendLiveRanges(liveAfter);

		instructions.add(instruction);

		if (!(instruction instanceof IRBranch)
		    && !(instruction instanceof IRJump)
		    && indices != null) {
			indices.setEnd(getIndex());
		}
	}

	private void expectRegister(IRVar target, int expectedReg) {
		Utils.assertTrue(target.scope() == VariableScope.register);
		Utils.assertTrue(target.index() == expectedReg);
	}

	public void printVarIntervals(List<LSInterval> intervals) {
		final int max = getIndex();
		intervals = new ArrayList<>(intervals);
		intervals.sort(Comparator.comparingInt(LSInterval::getFrom));
		for (LSInterval interval : intervals) {
			final String rangesString = interval.rangesAsString(max, blockToIndex.values());
			println(interval.getName(), rangesString);
		}
	}

	public List<Indices> getBlockIndices() {
		final List<Indices> blockBoundaries = new ArrayList<>(blockToIndex.values());
		blockBoundaries.sort(Comparator.comparingInt(Indices::start));
		return Collections.unmodifiableList(blockBoundaries);
	}

	private void printFixedIntervals() {
		final int max = getIndex();

		for (int reg = 0; reg < fixedIntervals.length; reg++) {
			final LSInterval interval = fixedIntervals[reg];
			if (interval == null) {
				continue;
			}
			final String rangesString = interval.rangesAsString(max, blockToIndex.values());
			println("r" + reg, rangesString);
		}
	}

	private void println(String s1, String s2) {
		System.out.printf("%14s %s\n", s1, s2);
	}

	private void extendLiveRanges(Set<IRVar> liveAfter) {
		final int index = getIndex() + 2;
		for (LSInterval interval : varIntervals) {
			final IRVar var = interval.var();
			if (liveAfter.contains(var)) {
				interval.extendRange(index);
			}
		}
	}

	private void handleSource(@NotNull IRVar var) {
		if (!canBeRegister(var)) {
			return;
		}

		final LSInterval interval = getInterval(var);

		final int index = getIndex();
		interval.extendRange(index + 1);
		interval.addUse(index);
	}

	@Nullable
	private LSInterval handleTarget(@NotNull IRVar var) {
		if (!canBeRegister(var)) {
			return null;
		}

		final LSInterval interval = getInterval(var);

		final int index = getIndex() + 1;
		interval.startNewRange(index);
		interval.addUse(index);
		return interval;
	}

	private boolean canBeRegister(@NotNull IRVar var) {
		if (var.type().isStruct()) {
			return false;
		}
		return var.scope() != VariableScope.global
		       && canBeRegister.canBeRegister(var);
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

	private int getIndex() {
		return instructions.size() * 2;
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
