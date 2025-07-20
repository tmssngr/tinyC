package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.cfg.*;
import com.regnis.tinyc.ir.*;

import java.util.*;
import java.util.function.*;
import java.util.function.Function;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class LSRegAlloc {

	private static final boolean DEBUG = false;

	@NotNull
	public static List<IRInstruction> process(@NotNull IRFunction function, @NotNull LSArchitecture architecture) {
		return process(function, architecture.isX86(), architecture.registerCount(), architecture, architecture);
	}

	@NotNull
	public static List<IRInstruction> process(@NotNull IRFunction function, boolean isX86, int registerCount, @NotNull LSCallingConventionProvider callingConventionProvider, @NotNull LSTypeRegisterCountProvider typeRegisterCountProvider) {
		final var preprocessorResult = LSPreprocessor.process(function, callingConventionProvider, isX86);
		final ControlFlowGraph cfg = CfgGenerator.create(function.name(), preprocessorResult.instructions());
		DetectVarLiveness.process(cfg, false);
		final List<BasicBlock> blocks = cfg.blocks();

		final IRVarInfos varInfos = preprocessorResult.varInfos();
		final LSCallingConvention callingConvention = callingConventionProvider.getCallingConvention(function.returnType(), varInfos.getArgumentTypes());

		final LSIntervalFactory intervalFactory = new LSIntervalFactory(varInfos, callingConventionProvider, typeRegisterCountProvider, registerCount, isX86);
		intervalFactory.addFunctionArgs(varInfos, callingConvention.argRegisters());
		for (BasicBlock block : blocks) {
			prepareBlock(block, intervalFactory);
		}
		intervalFactory.sortIntervals();
		final Map<String, LSIntervalFactory.Indices> blockToIndex = intervalFactory.getBlockToIndex();

//		intervalFactory.debugPrint(function.name());

		final LSAlgorithm algorithm = new LSAlgorithm(intervalFactory.getVarIntervals(), intervalFactory.getFixedIntervals(), typeRegisterCountProvider, registerCount);
		final Map<IRVar, LSVarRegisters> registerVarIntervals = algorithm.run();

		final Function<IRVar, IRVar> localCopyToGlobalOriginal = preprocessorResult.localCopyToGlobalOriginal();
		final LSRegAlloc regAlloc = new LSRegAlloc(registerVarIntervals, localCopyToGlobalOriginal, registerCount, cfg, blockToIndex);
		regAlloc.determineMovesAtBlockEdges(blocks);
		regAlloc.processInstructions(intervalFactory.getInstructions());

/*
		System.out.println("\n" + function.name() + ":");
		IRInstruction.debugPrint(regAlloc.instructions);
		System.out.println();
*/

		return regAlloc.instructions;
	}

	private final List<IRInstruction> instructions = new ArrayList<>();
	private final Map<Integer, List<IRMove>> indexToMoves = new HashMap<>();
	private final Map<IRVar, LSVarRegisters> varToRegisters;
	private final Function<IRVar, IRVar> localCopyToOriginal;
	private final int registerCount;
	private final ControlFlowGraph cfg;
	private final Map<String, LSIntervalFactory.Indices> blockToIndex;
	private final boolean assertRegister;

	private int pos;

	private LSRegAlloc(@NotNull Map<IRVar, LSVarRegisters> varToRegisters, Function<IRVar, IRVar> localCopyToOriginal, int registerCount, ControlFlowGraph cfg, Map<String, LSIntervalFactory.Indices> blockToIndex) {
		this.varToRegisters = varToRegisters;
		this.localCopyToOriginal = localCopyToOriginal;
		this.registerCount = registerCount;
		this.cfg = cfg;
		this.blockToIndex = blockToIndex;
		assertRegister = false;
	}

	private void processInstructions(List<IRInstruction> instructions) {
		for (IRInstruction instruction : instructions) {
			if (DEBUG
			    && !(instruction instanceof IRComment)
			    && !(instruction instanceof IRJump)) {
				add(new IRComment(instruction.toString()));
			}
			processMoves();
			processInstruction(instruction);
			pos++;
			processMoves();
			pos++;
		}
	}

	private void processInstruction(IRInstruction instruction) {
		switch (instruction) {
		case IRAddConst addConst -> {
			IRVar var = addConst.var();
			var = sourceRegister(var);
			add(new IRAddConst(var, addConst.offset()));
		}
		case IRAddrOf addrOf -> {
			IRVar target = addrOf.target();
			target = targetRegister(target);
			add(new IRAddrOf(target, addrOf.source(), addrOf.location()));
		}
		case IRAddrOfArray addrOfArray -> {
			IRVar target = addrOfArray.addr();
			target = targetRegister(target);
			add(new IRAddrOfArray(target, addrOfArray.array(), addrOfArray.location()));
		}
		case IRBinary binary -> {
			if (binary.op() != IRBinary.Op.Mod) {
				Utils.assertTrue(binary.left().equals(binary.target()));
			}
			final IRVar left = sourceRegister(binary.left());
			final IRVar right = sourceRegister(binary.right());
			final IRVar target = targetRegister(binary.target());
			add(new IRBinary(target, binary.op(), left, right, binary.location()));
		}
		case IRBranch branch -> {
			final IRVar var = sourceRegister(branch.conditionVar());
			add(new IRBranch(var, branch.jumpOnTrue(), branch.target(), branch.nextLabel()));
		}
		case IRCall call -> {
			IRVar target = call.target();
			if (target != null) {
				target = targetRegister(target);
			}
			final List<IRVar> args = new ArrayList<>();
			for (IRVar arg : call.args()) {
				args.add(source(arg));
			}
			add(new IRCall(target, call.type(), call.name(), args, call.location()));
		}
		case IRCast cast -> {
			final IRVar source = sourceRegister(cast.source());
			final IRVar target = targetRegister(cast.target());
			add(new IRCast(target, source, cast.location()));
		}
		case IRComment ignored -> add(instruction);
		case IRCompare compare -> {
			IRVar target = compare.target();
			target = targetRegister(target);
			final IRVar left = sourceRegister(compare.left());
			final IRVar right = sourceRegister(compare.right());
			add(new IRCompare(target, compare.op(), left, right, compare.location()));
		}
		case IRCompareConst compare -> {
			IRVar target = compare.target();
			target = targetRegister(target);
			final IRVar left = sourceRegister(compare.left());
			add(new IRCompareConst(target, compare.op(), left, compare.value(), compare.location()));
		}
		case IRJump ignored -> add(instruction);
		case IRLabel ignored -> add(instruction);
		case IRLiteral literal -> {
			IRVar target = literal.target();
			target = targetRegister(target);
			add(new IRLiteral(target, literal.value(), literal.location()));
		}
		case IRMemLoad load -> {
			final IRVar addr = sourceRegister(load.addr());
			final IRVar target = targetRegister(load.target());
			add(new IRMemLoad(target, addr, load.location()));
		}
		case IRMemStore store -> {
			final IRVar addr = sourceRegister(store.addr());
			final IRVar value = sourceRegister(store.value());
			add(new IRMemStore(addr, value, store.location()));
		}
		case IRMove move -> {
			IRVar target = move.target();
			target = target(target);
			final IRVar source = source(move.source());
			if (assertRegister) {
				Utils.assertTrue(source.scope() == VariableScope.register
				                 || target.scope() == VariableScope.register);
			}
			boolean skip = source.equals(target);
			if (!skip
			    && source.scope() == VariableScope.register
			    && target.scope() == VariableScope.register
			    && source.index() == target.index()) {
				skip = true;
			}
			if (!skip) {
				add(new IRMove(target, source, move.location()));
			}
		}
		case IRString string -> {
			final IRVar target = targetRegister(string.target());
			add(new IRString(target, string.stringIndex(), string.location()));
		}
		case IRUnary unary -> {
			final IRVar source = sourceRegister(unary.source());
			final IRVar target = targetRegister(unary.target());
			add(new IRUnary(unary.op(), target, source));
		}
		default -> throw new UnsupportedOperationException(String.valueOf(instruction));
		}
	}

	private void processMoves() {
		for (LSVarRegisters varRegisters : varToRegisters.values()) {
			final Pair<IRVar, IRVar> transition = varRegisters.getTransitionAt(pos);
			if (transition != null) {
				final IRVar from = transition.first();
				final IRVar to = transition.second();
				add(new IRMove(to, from, Location.DUMMY));
			}
		}

		final List<IRMove> moves = indexToMoves.get(pos);
		if (moves != null) {
			for (IRMove move : moves) {
				add(move);
			}
		}
	}

	private IRVar sourceRegister(IRVar source) {
		final IRVar var = source(source);
		if (assertRegister) {
			Utils.assertTrue(var.scope() == VariableScope.register);
		}
		return var;
	}

	private IRVar source(IRVar source) {
		return convertVar(source, pos);
	}

	private IRVar targetRegister(IRVar target) {
		final IRVar var = target(target);
		if (assertRegister) {
			Utils.assertTrue(var.scope() == VariableScope.register);
		}
		return var;
	}

	private IRVar target(IRVar target) {
		return convertVar(target, pos + 1);
	}

	private IRVar convertVar(IRVar var, int pos) {
		if (var.scope() == VariableScope.register) {
			return var;
		}

		final LSVarRegisters registers = varToRegisters.get(var);
		if (registers == null) {
			return var;
		}

		final int registerOrState = registers.getRegisterOrState(pos);
		Utils.assertTrue(registerOrState >= LSVarRegisters.NOT_REGISTER);
		if (registerOrState == LSVarRegisters.NOT_REGISTER) {
			final IRVar result = localCopyToOriginal.apply(var);
			return result != null ? result : var;
		}
		return var.asRegister(registerOrState);
	}

	private void add(IRInstruction instruction) {
		instructions.add(instruction);
//		System.out.println("\t" + instruction);
	}

	private void determineMovesAtBlockEdges(List<BasicBlock> blocks) {
		for (BasicBlock block : blocks) {
			final List<String> predecessors = block.predecessors();
			final Set<IRVar> liveBefore = block.getLiveBefore();
			if (predecessors.isEmpty() || liveBefore.isEmpty()) {
				continue;
			}

			for (String predecessor : predecessors) {
				final BasicBlock predecessorBlock = cfg.get(predecessor);
				determineMovesAtBlockEdge(predecessorBlock, block, liveBefore);
			}
		}
	}

	private void determineMovesAtBlockEdge(BasicBlock predecessor, BasicBlock block, Set<IRVar> liveBefore) {
		final int predecessorEndIndex = blockToIndex.get(predecessor.name).end();
		final int blockIndex = blockToIndex.get(block.name).start();

		final List<LSParallelMove.VarTransfer> transfers = new ArrayList<>();
		for (IRVar var : liveBefore) {
			if (var.scope() == VariableScope.register) {
				continue;
			}

			final LSVarRegisters registers = varToRegisters.get(var);
			final int varInReg = registers.getRegisterOrState(blockIndex);
			final int predecessorIndex = predecessorEndIndex + 1;
			final int varOutReg = registers.getRegisterOrState(predecessorIndex);
			transfers.add(new LSParallelMove.VarTransfer(var, varOutReg, varInReg));
		}

		if (transfers.isEmpty()) {
			return;
		}

		transfers.sort((t1, t2) -> {
			final IRVar var1 = t1.var();
			final IRVar var2 = t2.var();
			final Comparator<String> comparator = Comparator.naturalOrder();
			int order = comparator.compare(var1.name(), var2.name());
			if (order == 0) {
				order = t1.var().index() - var2.index();
			}
			return order;
		});

		final List<IRMove> moves = new ArrayList<>();
		LSParallelMove.transfer(transfers, registerCount, transfer -> {
			final IRVar var = transfer.var();
			final IRVar source = deriveVar(var, transfer.from());
			final IRVar target = deriveVar(var, transfer.to());
			moves.add(new IRMove(target, source, Location.DUMMY));
		});
		if (moves.isEmpty()) {
			return;
		}

		final int moveIndex;
		if (block.predecessors().size() > 1) {
			Utils.assertTrue(predecessor.successors().size() == 1);
			moveIndex = predecessorEndIndex;
		}
		else {
			moveIndex = blockIndex + 1;
		}
		indexToMoves.put(moveIndex, moves);
	}

	private static IRVar deriveVar(IRVar var, int reg) {
		return reg < 0 ? var : var.asRegister(reg);
	}

	private static void prepareBlock(BasicBlock block, LSIntervalFactory intervals) {
		intervals.blockStart(block.name, block.getLiveBefore());

		if (block.name.startsWith("@")) {
			final Set<IRVar> live = block.getLiveBefore();
			intervals.addInstruction(new IRLabel(block.name), live);
		}

		final List<IRInstruction> instructions = block.instructions();
		for (int i = 0; i < instructions.size(); i++) {
			final IRInstruction instruction = instructions.get(i);
			final Set<IRVar> liveAfter = block.getLiveAfter(i);
			intervals.addInstruction(instruction, liveAfter);
		}
	}
}
