package com.regnis.tinyc.cfg;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class SsaFactory {

	private final Map<IRVar, Integer> varToNextIndex = new HashMap<>();
	private final Map<String, SsaBB> blockNameToSsaBB = new HashMap<>();
	private final IRLocalVarFactory varFactory;
	private final ControlFlowGraph cfg;

	private SsaBB ssaBB;

	public SsaFactory(@NotNull ControlFlowGraph cfg, @NotNull IRVarInfos infos) {
		this.cfg = cfg;
		varFactory = new IRLocalVarFactory(infos);
	}

	public ControlFlowGraph perform() {
		final List<BasicBlock> blocks = cfg.blocks();
		for (BasicBlock block : blocks) {
			process(block);
		}

		final List<IRInstruction> instructions = new ArrayList<>();
		return CfgGenerator.create(cfg.name(), instructions);
	}

	private void process(BasicBlock block) {
		ssaBB = new SsaBB(block.name);
		blockNameToSsaBB.put(block.name, ssaBB);

		for (IRInstruction instruction : block.instructions()) {
			ssaBB.instructions.add(process(instruction));
		}
	}

	private IRInstruction process(IRInstruction instruction) {
		return switch (instruction) {
//		case IRAddrOf addrOf -> consumer.handle(instruction, addrOf.target(), List.of(addrOf.source()));
//		case IRAddrOfArray addrOfArray -> consumer.handle(instruction, addrOfArray.addr(), List.of());
		case IRBinary binary -> {
			final IRVar left = replaceSource(binary.left());
			final IRVar right = replaceSource(binary.right());
			final IRVar target = replaceTarget(binary.target());
			yield new IRBinary(target, binary.op(), left, right, binary.location());
		}
//		case IRBranch branch -> consumer.handle(instruction, null, List.of(branch.conditionVar()));
//		case IRCall call -> consumer.handle(instruction, call.target(), call.args());
//		case IRCast cast -> consumer.handle(instruction, cast.target(), List.of(cast.source()));
//		case IRComment ignored -> consumer.handle(instruction, null, List.of());
//		case IRCompare compare -> consumer.handle(instruction, compare.target(), List.of(compare.left(), compare.right()));
			case IRJump jump -> jump;
			case IRLabel label -> label;
			case IRLiteral literal -> {
				final IRVar target = replaceTarget(literal.target());
				yield new IRLiteral(target, literal.value(), literal.location());
			}
//		case IRMemLoad load -> consumer.handle(instruction, load.target(), List.of(load.addr()));
//		case IRMemStore store -> consumer.handle(instruction, null, List.of(store.addr(), store.value()));
//		case IRMove copy -> consumer.handle(instruction, copy.target(), List.of(copy.source()));
//		case IRRetValue retValue -> consumer.handle(instruction, null, List.of(retValue.var()));
//		case IRString string -> consumer.handle(instruction, string.target(), List.of());
//		case IRUnary unary -> consumer.handle(instruction, unary.target(), List.of(unary.source()));
			default -> throw new UnsupportedOperationException(instruction.toString());
		};
	}

	private IRVar replaceSource(IRVar var) {
		final VariableScope scope = var.scope();
		if (scope == VariableScope.global) {
			return var;
		}

		Utils.assertTrue(scope == VariableScope.function || scope == VariableScope.parameter);
		final IRVar ssaVar = ssaBB.varToSsaVar.get(var);
		if (ssaVar == null) {
			throw new UnsupportedOperationException();
		}
		return ssaVar;
	}

	private IRVar replaceTarget(IRVar var) {
		final VariableScope scope = var.scope();
		if (scope == VariableScope.global) {
			return var;
		}

		Utils.assertTrue(scope == VariableScope.function || scope == VariableScope.parameter);
		final int index = nextIndexOf(var);
		final IRVar ssaVar = varFactory.createVar(var, var.name() + "." + index);
		ssaBB.varToSsaVar.put(var, ssaVar);
		return ssaVar;
	}

	private int nextIndexOf(IRVar var) {
		final Integer nextIndex = varToNextIndex.get(var);
		int index = 0;
		if (nextIndex != null) {
			index = nextIndex;
		}
		varToNextIndex.put(var, index + 1);
		return index;
	}

	private static final class SsaBB {
		private final List<IRInstruction> instructions = new ArrayList<>();
		private final Map<IRVar, IRVar> varToSsaVar = new HashMap<>();
		private final String name;

		public SsaBB(String name) {
			this.name = name;
		}
	}
}
