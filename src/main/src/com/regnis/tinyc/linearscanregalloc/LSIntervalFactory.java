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
	private final List<LSInterval> fixedIntervals = new ArrayList<>();
	private final Map<Integer, LSInterval> regToFixedIntervals = new HashMap<>();
	private final IRCanBeRegister canBeRegister;
	private final LSArchitecture architecture;

	private Indices indices;

	public LSIntervalFactory(@NotNull IRVarInfos varInfos, @NotNull LSArchitecture architecture) {
		canBeRegister = varInfos;
		this.architecture = architecture;
		addFunctionArgs(varInfos.vars());
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
	public List<LSInterval> getVarIntervals() {
		return Collections.unmodifiableList(varIntervals);
	}

	@NotNull
	public List<LSInterval> getFixedIntervals() {
		return Collections.unmodifiableList(fixedIntervals);
	}

	public void blockStart(String name, @NotNull Set<IRVar> liveBefore) {
		final int index = getIndex();
		indices = new Indices(index);
		blockToIndex.put(name, indices);

		for (IRVar var : liveBefore) {
			if (!canBeRegister(var)) {
				continue;
			}
			final LSInterval interval = getInterval(var);
			interval.extendRangeMaybeCreate(index);
		}
	}

	public void addInstruction(@NotNull IRInstruction instruction, @NotNull Set<IRVar> liveAfter) {
		System.out.println(getIndex() + ":\t" + instruction);

		switch (instruction) {
		case IRAddrOf addrOf -> {
			handleTarget(addrOf.target());
		}
		case IRAddrOfArray addrOf -> handleTarget(addrOf.addr());
		case IRBinary binary -> {
			handleSource(binary.left());
			handleSource(binary.right());

			final IRBinary.Op op = binary.op();
			if (architecture.isX86()) {
				if (op == IRBinary.Op.Div || op == IRBinary.Op.Mod) {
					// https://www.felixcloutier.com/x86/idiv
					// (rdx rax) / %reg -> rax
					// (rdx rax) % %reg -> rdx
					final int index = getIndex();
					final int rax = 0;
					final int rdx = 2;
					getRegisterInterval(rax).startNewRangeIfSmaller(index);
					getRegisterInterval(rdx).startNewRangeIfSmaller(index);
				}
				if (op == IRBinary.Op.ShiftLeft || op == IRBinary.Op.ShiftRight) {
					final int index = getIndex();
					final int rcx = 1;
					getRegisterInterval(rcx).startNewRangeIfSmaller(index);
				}
			}

			handleTarget(binary.target());
		}
		case IRBranch branch -> handleSource(branch.conditionVar());
		case IRCall call -> {
			for (IRVar arg : call.args()) {
				handleSource(arg);
			}

			final int index = getIndex();
			for (int i = 0; i < architecture.callingConvention().volatileRegisterCount(); i++) {
				final LSInterval interval = getRegisterInterval(i);
				// can already be larger by handleSource of args
				interval.startNewRangeIfSmaller(index);
			}

			final IRVar target = call.target();
			if (target != null) {
				Utils.assertTrue(target.scope() == VariableScope.register);
				Utils.assertTrue(target.index() == 0);
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

	public void printVarIntervals(List<LSInterval> intervals) {
		final int max = getIndex();
		intervals = new ArrayList<>(intervals);
		intervals.sort(Comparator.comparingInt(LSInterval::getFrom));
		for (LSInterval interval : intervals) {
			final String rangesString = interval.rangesAsString(max, blockToIndex.values());
			println(interval.getName(), rangesString);
		}
	}

	public Map<String, Indices> getBlockToIndex() {
		return Collections.unmodifiableMap(blockToIndex);
	}

	private void printFixedIntervals() {
		final int max = getIndex();

		final List<Integer> regs = new ArrayList<>(regToFixedIntervals.keySet());
		regs.sort(Integer::compareTo);
		for (int reg : regs) {
			final LSInterval interval = regToFixedIntervals.get(reg);
			final String rangesString = interval.rangesAsString(max, blockToIndex.values());
			println("r" + reg, rangesString);
		}
	}

	private void println(String s1, String s2) {
		System.out.printf("%14s %s\n", s1, s2);
	}

	private void addFunctionArgs(@NotNull List<IRVarDef> defs) {
		Utils.assertTrue(instructions.isEmpty());

		final int firstArgRegister = architecture.callingConvention().firstArgRegister();
		for (IRVarDef def : defs) {
			final IRVar var = def.var();
			if (var.scope() != VariableScope.argument) {
				continue;
			}

			final int index = var.index();
			if (index >= architecture.argRegisterCount()) {
				continue;
			}

			final LSInterval interval = getRegisterInterval(index + firstArgRegister);
			interval.startNewRange(-1);
		}
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
		LSInterval interval = regToFixedIntervals.get(reg);
		if (interval == null) {
			interval = new LSInterval(reg);
			regToFixedIntervals.put(reg, interval);
			fixedIntervals.add(interval);
		}
		return interval;
	}

	private int getIndex() {
		return instructions.size() * 2;
	}

	public static final class Indices {
		private final int start;

		private int end;

		public Indices(int start) {
			this.start = start;
			end = start;
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
