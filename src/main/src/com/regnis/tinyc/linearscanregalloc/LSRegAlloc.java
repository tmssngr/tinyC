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
public final class LSRegAlloc {

	@NotNull
	public static IRFunction process(@NotNull IRFunction function, @NotNull LSArchitecture architecture) {
		return process(function, architecture.isX86(), architecture.registerCount(), architecture);
	}

	@NotNull
	public static IRFunction process(@NotNull IRFunction function, boolean isX86, int registerCount, @NotNull LSCallingConventionProvider callingConventionProvider) {
		final var preprocessorResult = LSPreprocessor.process(function.instructions(), function.varInfos(), function.returnType(), callingConventionProvider, isX86);
		final ControlFlowGraph cfg = CfgGenerator.create(function.name(), preprocessorResult.instructions());
		DetectVarLiveness.process(cfg, function.varInfos().cantBeRegister(), false);
		final List<BasicBlock> blocks = cfg.blocks();

		LSIntervalFactory.printInstructions(preprocessorResult.instructions());

		final IRVarInfos varInfos = preprocessorResult.varInfos();

		final LSIntervalFactory intervalFactory = new LSIntervalFactory(varInfos, callingConventionProvider, registerCount, isX86);
		intervalFactory.handleBlocks(blocks);
		final Map<String, LSIntervalFactory.Indices> blockToIndex = intervalFactory.getBlockToIndex();
		final List<LSIntervalFactory.Indices> blockBoundaries = intervalFactory.getBlockIndices();

		intervalFactory.debugPrint(function.name());

		final List<LSInterval> varIntervals = intervalFactory.getVarIntervalsSorted();
		final LSAlgorithm algorithm = new LSAlgorithm(varIntervals, intervalFactory.getFixedIntervals(), blockBoundaries, registerCount);

		algorithm.run();

		intervalFactory.debugPrint(function.name());

		final LSRegAlloc regAlloc = new LSRegAlloc(varIntervals, registerCount, cfg, blockToIndex, varInfos);
		regAlloc.determineMovesAtBlockEdges(blocks);
		regAlloc.processStackArguments();
		regAlloc.processInstructions(intervalFactory.getInstructions());

		System.out.println("\n" + function.name() + ":");
		LSIntervalFactory.printInstructions(regAlloc.instructions);
		System.out.println();

		return function.derive(regAlloc.instructions, preprocessorResult.varInfos());
	}

	private final List<IRInstruction> instructions = new ArrayList<>();
	private final Map<Integer, List<IRMove>> indexToMoves = new HashMap<>();
	private final Map<IRVar, LSInterval> varToInterval;
	private final int registerCount;
	private final ControlFlowGraph cfg;
	private final Map<String, LSIntervalFactory.Indices> blockToIndex;
	private final IRCanBeRegister canBeRegister;

	private int pos;

	private LSRegAlloc(@NotNull List<LSInterval> varIntervals, int registerCount, ControlFlowGraph cfg, Map<String, LSIntervalFactory.Indices> blockToIndex, IRCanBeRegister canBeRegister) {
		this.varToInterval = new LinkedHashMap<>();
		for (LSInterval interval : varIntervals) {
			varToInterval.put(interval.var(), interval);
		}
		this.registerCount = registerCount;
		this.cfg = cfg;
		this.blockToIndex = blockToIndex;
		this.canBeRegister = canBeRegister;
	}

	private void processStackArguments() {
		// Arguments which are passed on the stack, but an register has been assigned to them immediately
		// need to load the variable into the register.
		for (Map.Entry<IRVar, LSInterval> entry : varToInterval.entrySet()) {
			final IRVar var = entry.getKey();
			if (var.scope() != VariableScope.parameter) {
				continue;
			}

			final LSInterval interval = entry.getValue();
			if (interval.getFrom() > 0) {
				continue;
			}

			final LSUse nextUse = interval.getUsedNext(0);
			if (nextUse == null || nextUse.pos() == 0) {
				continue;
			}

			final int register = interval.register();
			if (register >= 0) {
				add(new IRMove(var.asRegister(register), var, Location.DUMMY));
			}
		}
	}

	private void processInstructions(List<IRInstruction> instructions) {
		for (IRInstruction instruction : instructions) {
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
			var = sourceExpectReg(var);
			add(new IRAddConst(var, addConst.offset()));
		}
		case IRAddrOf addrOf -> {
			IRVar target = addrOf.target();
			target = targetExpectReg(target);
			add(new IRAddrOf(target, addrOf.source(), addrOf.location()));
		}
		case IRAddrOfArray addrOfArray -> {
			IRVar target = addrOfArray.addr();
			target = targetExpectReg(target);
			add(new IRAddrOfArray(target, addrOfArray.array(), addrOfArray.location()));
		}
		case IRBinary binary -> {
			if (binary.op() != IRBinary.Op.Mod) {
				Utils.assertTrue(binary.left().equals(binary.target()));
			}
			final IRVar left = sourceExpectReg(binary.left());
			final IRVar right = sourceExpectReg(binary.right());
			final IRVar target = targetExpectReg(binary.target());
			add(new IRBinary(target, binary.op(), left, right, binary.location()));
		}
		case IRBranch branch -> {
			final IRVar var = sourceExpectReg(branch.conditionVar());
			add(new IRBranch(var, branch.jumpOnTrue(), branch.target(), branch.nextLabel()));
		}
		case IRCall call -> {
			IRVar target = call.target();
			if (target != null) {
				target = targetExpectReg(target);
			}
			final List<IRVar> args = new ArrayList<>();
			for (IRVar arg : call.args()) {
				args.add(source(arg));
			}
			add(new IRCall(target, call.type(), call.name(), args, call.location()));
		}
		case IRCast cast -> {
			final IRVar source = sourceExpectReg(cast.source());
			final IRVar target = targetExpectReg(cast.target());
			add(new IRCast(target, source, cast.location()));
		}
		case IRComment ignored -> add(instruction);
		case IRCompare compare -> {
			IRVar target = compare.target();
			target = targetExpectReg(target);
			final IRVar left = sourceExpectReg(compare.left());
			final IRVar right = sourceExpectReg(compare.right());
			add(new IRCompare(target, compare.op(), left, right, compare.location()));
		}
		case IRCompareConst compare -> {
			IRVar target = compare.target();
			target = targetExpectReg(target);
			final IRVar left = sourceExpectReg(compare.left());
			add(new IRCompareConst(target, compare.op(), left, compare.value(), compare.location()));
		}
		case IRJump ignored -> add(instruction);
		case IRLabel ignored -> add(instruction);
		case IRLiteral literal -> {
			IRVar target = literal.target();
			target = targetExpectReg(target);
			add(new IRLiteral(target, literal.value(), literal.location()));
		}
		case IRMemLoad load -> {
			final IRVar addr = sourceExpectReg(load.addr());
			final IRVar target = targetExpectReg(load.target());
			add(new IRMemLoad(target, addr, load.location()));
		}
		case IRMemStore store -> {
			final IRVar addr = sourceExpectReg(store.addr());
			final IRVar value = sourceExpectReg(store.value());
			add(new IRMemStore(addr, value, store.location()));
		}
		case IRMove move -> {
			IRVar target = move.target();
			target = target(target);
			final IRVar source = source(move.source());

			final boolean sourceIsReg = source.scope() == VariableScope.register;
			final boolean targetIsReg = target.scope() == VariableScope.register;
			Utils.assertTrue(sourceIsReg || targetIsReg);

			boolean skip = source.equals(target);
			if (!skip
			    && sourceIsReg
			    && targetIsReg
			    && source.index() == target.index()) {
				skip = true;
			}
			if (!skip) {
				add(new IRMove(target, source, move.location()));
			}
		}
		case IRString string -> {
			final IRVar target = targetExpectReg(string.target());
			add(new IRString(target, string.stringIndex(), string.location()));
		}
		case IRUnary unary -> {
			final IRVar source = sourceExpectReg(unary.source());
			final IRVar target = targetExpectReg(unary.target());
			add(new IRUnary(unary.op(), target, source));
		}
		default -> throw new UnsupportedOperationException(String.valueOf(instruction));
		}
	}

	private void processMoves() {
		for (Map.Entry<IRVar, LSInterval> entry : varToInterval.entrySet()) {
			final IRVar var = entry.getKey();
			final LSInterval interval = entry.getValue();
			final Pair<IRVar, IRVar> transition = interval.getTransitionAt(pos, var);
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

	private IRVar sourceExpectReg(IRVar source) {
		final IRVar var = convertVar(source, pos, true, false);
		Utils.assertTrue(var.scope() == VariableScope.register, var.name());
		return var;
	}

	private IRVar source(IRVar source) {
		return convertVar(source, pos, true, false);
	}

	private IRVar targetExpectReg(IRVar target) {
		final IRVar var = convertVar(target, pos, false, true);
		Utils.assertTrue(var.scope() == VariableScope.register, var.name());
		return var;
	}

	private IRVar target(IRVar target) {
		return convertVar(target, pos, false, true);
	}

	private IRVar convertVar(IRVar var, int pos, boolean read, boolean write) {
		if (var.scope() == VariableScope.register) {
			return var;
		}

		final LSInterval interval = varToInterval.get(var);
		if (interval == null) {
			return var;
		}

		final LSInterval subInterval = interval.getSubInterval(pos, read, write);
		Utils.assertTrue(subInterval != null);
		final int register = subInterval.register();
		return var.asRegister(register);
	}

	private void add(IRInstruction instruction) {
		instructions.add(instruction);
		System.out.println("\t" + instruction);
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

			final LSInterval interval = varToInterval.get(var);
			if (interval == null) {
				Utils.assertTrue(!canBeRegister.canBeRegister(var));
				continue;
			}

			Utils.assertTrue(canBeRegister.canBeRegister(var));
			final Pair<IRVar, IRVar> transition = interval.getTransitionFromTo(predecessorEndIndex, blockIndex, var);
			if (transition != null) {
				final int from = transition.first().scope() == VariableScope.register ? transition.first().index() : -1;
				final int to = transition.second().scope() == VariableScope.register ? transition.second().index() : -1;
				transfers.add(new LSParallelMove.VarTransfer(var, from, to));
			}
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
}
