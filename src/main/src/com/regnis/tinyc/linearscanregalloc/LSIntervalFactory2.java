package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.cfg.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class LSIntervalFactory2 {

	private final List<IRInstruction> instructions = new ArrayList<>();
	private final Map<String, BlockIndices> blockToIndex = new HashMap<>();
	private final List<LSInterval2> varIntervals = new ArrayList<>();
	private final Map<IRVar, LSInterval2> varToInterval = new HashMap<>();
	private final LSInterval2[] fixedIntervals;
	private final IRCanBeRegister canBeRegister;
	private final LSCallingConventionProvider callingConventionProvider;
	private final boolean isX86;

	private BlockIndices indices;
	private int blockStart;
	private int pos;

	public LSIntervalFactory2(@NotNull IRCanBeRegister canBeRegister, @NotNull LSCallingConventionProvider callingConventionProvider, int registerCount, boolean isX86) {
		this.canBeRegister = canBeRegister;
		this.callingConventionProvider = callingConventionProvider;
		this.isX86 = isX86;

		fixedIntervals = new LSInterval2[registerCount];
	}

	@NotNull
	public List<IRInstruction> getInstructions() {
		return Collections.unmodifiableList(instructions);
	}

	@NotNull
	public List<LSInterval2> getVarIntervalsSorted() {
		final List<LSInterval2> varIntervals = new ArrayList<>(this.varIntervals);
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
	public List<LSInterval2> getFixedIntervals() {
		final List<LSInterval2> fixedIntervals = new ArrayList<>();
		for (LSInterval2 interval : this.fixedIntervals) {
			if (interval != null) {
				fixedIntervals.add(interval);
			}
		}
		return Collections.unmodifiableList(fixedIntervals);
	}

	public Map<String, LSIntervalFactory2.BlockIndices> getBlockToIndex() {
		return Collections.unmodifiableMap(blockToIndex);
	}

	public void handleBlocks(List<BasicBlock> blocks) {
		record Block(String name, List<IRInstruction> instructions, Set<IRVar> liveAfter) {
		}

		final List<Block> blocksWithLabels = new ArrayList<>();
		pos = 0;
		for (BasicBlock block : blocks) {
			List<IRInstruction> instructions = block.instructions();
			final String name = block.name;
			if (name.startsWith("@")) {
				instructions = new ArrayList<>(instructions);
				instructions.addFirst(new IRLabel(name));
			}
			blocksWithLabels.add(new Block(name, instructions, block.getLiveAfter()));
			pos += 2 * instructions.size();
		}

		for (Block block : blocksWithLabels.reversed()) {
			handleBlock(block.name, block.instructions, block.liveAfter);
		}

		Utils.assertTrue(pos == 0);
	}

	public void handleBlock(String name, List<IRInstruction> instructions, Set<IRVar> liveAfter) {
		final Set<IRVar> live = new HashSet<>(liveAfter);

		blockStart = pos - 2 * instructions.size();
		Utils.assertTrue(blockStart >= 0);

		final List<IRVar> liveSorted = new ArrayList<>(live);
		liveSorted.sort(Comparator.comparing(IRVar::scope).thenComparingInt(IRVar::index));
		for (IRVar var : liveSorted) {
			final LSInterval2 interval = getInterval(var);
			interval.add(blockStart, pos);
		}

		int end = -1;
		for (IRInstruction instruction : instructions.reversed()) {
			if (!(instruction instanceof IRBranch)
			    && !(instruction instanceof IRJump)
			    && end < 0) {
				end = pos;
			}
			pos -= 2;
			handleInstruction(instruction, live);
		}

		Utils.assertTrue(blockStart == pos);

		blockToIndex.put(name, new BlockIndices(blockStart, end));
	}

	private void handleInstruction(@NotNull IRInstruction instruction, @NotNull Set<IRVar> live) {
		switch (instruction) {
		case IRAddConst addConst -> {
			final IRVar var = addConst.var();
			handleTarget(var, live);
			handleSource(var, live);
		}
		case IRAddrOf addrOf -> {
			handleTarget(addrOf.target(), live);
		}
		case IRAddrOfArray addrOf -> handleTarget(addrOf.addr(), live);
		case IRBinary binary -> {
			final IRVar target = binary.target();
			final IRVar left = binary.left();
			final IRVar right = binary.right();

			if (isX86) {
				final int rax = 0;
				final int rcx = 1;
				final int rdx = 2;

				switch (binary.op()) {
				case Div -> {
					// https://www.felixcloutier.com/x86/idiv
					// (rdx rax) / %reg -> rax
					expectRegister(left, rax);
					expectRegister(target, rax);

					getRegisterInterval(rdx).add(pos, pos + 1);
				}
				case Mod -> {
					// https://www.felixcloutier.com/x86/idiv
					// (rdx rax) % %reg -> rdx
					expectRegister(left, rax);
					expectRegister(target, rdx);

					getRegisterInterval(rax).add(pos, pos + 1);
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
				final LSInterval2 interval = getRegisterInterval(i);
				interval.add(pos, pos + 1);
			}

			for (IRVar arg : call.args()) {
				handleSource(arg, live);
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

	private void expectRegister(IRVar var, int expectedReg) {
		Utils.assertTrue(var.scope() == VariableScope.register);
		Utils.assertTrue(var.index() == expectedReg);
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
				handleSource(source, live);
				return;
			}
		}

		final LSInterval2 interval = handleTarget(target, live);
		if (source.scope() == VariableScope.global) {
			return;
		}

		if (source.scope() == VariableScope.register) {
			interval.setRegisterHint(source.index());
		}
		handleSource(source, live);
	}

	private void handleSource(IRVar var, Set<IRVar> live) {
		Utils.assertTrue(var.scope() != VariableScope.global);
		if (var.scope() != VariableScope.register) {
			live.add(var);
		}
		final LSInterval2 interval = getInterval(var);
		if (pos > blockStart) {
			interval.add(blockStart, pos);
		}
		interval.addReadUse(pos);
	}

	@NotNull
	private LSInterval2 handleTarget(IRVar var, Set<IRVar> live) {
		Utils.assertTrue(var.scope() != VariableScope.global);
		if (var.scope() != VariableScope.register) {
			Utils.assertTrue(canBeRegister.canBeRegister(var));
			live.remove(var);
		}

		final LSInterval2 interval = getInterval(var);
		// no range yet?
		if (interval.getFrom() < 0) {
			Utils.assertTrue(var.scope() == VariableScope.register);
			Utils.assertTrue(var.index() == 0);
			interval.add(pos, pos + 1);
			return interval;
		}

		interval.setWritePos(pos);
		interval.addWritePos(pos);
		return interval;
	}

	@NotNull
	private LSInterval2 getInterval(@NotNull IRVar var) {
		if (var.scope() == VariableScope.register) {
			return getRegisterInterval(var.index());
		}

		LSInterval2 interval = varToInterval.get(var);
		if (interval == null) {
			interval = new LSInterval2(var);
			varToInterval.put(var, interval);
			varIntervals.add(interval);
		}
		return interval;
	}

	@NotNull
	private LSInterval2 getRegisterInterval(int reg) {
		LSInterval2 interval = fixedIntervals[reg];
		if (interval == null) {
			interval = new LSInterval2(reg);
			fixedIntervals[reg] = interval;
		}
		return interval;
	}

	public record BlockIndices(int start, int end) {
	}
}
