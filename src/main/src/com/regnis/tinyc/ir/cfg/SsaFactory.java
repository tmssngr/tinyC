package com.regnis.tinyc.ir.cfg;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class SsaFactory {

	public static Pair<List<IRInstruction>, IRVarInfos> convert(@NotNull ControlFlowGraph cfgWithLiveness, @NotNull IRVarInfos varInfos) {
		final SsaFactory factory = new SsaFactory(cfgWithLiveness, varInfos);
		final List<IRInstruction> instructions = factory.convert();
		return new Pair<>(instructions, factory.varFactory.createVarInfos());
	}

	private final Map<String, Map<IRVar, Phi>> phiNodes = new HashMap<>();
	private final Map<IRVar, VarReplacement> varMapping = new HashMap<>();
	private final Map<String, List<IRInstruction>> newInstructions = new HashMap<>();
	private final ControlFlowGraph cfg;
	private final IRLocalVarFactory varFactory;

	private SsaFactory(@NotNull ControlFlowGraph cfgWithLiveness, @NotNull IRVarInfos varInfos) {
		this.cfg = cfgWithLiveness;
		varFactory = new IRLocalVarFactory(varInfos);
		initializePhiNodes();
	}

	private List<IRInstruction> convert() {
		final BasicBlock first = cfg.blocks().getFirst();
		final List<String> pending = new ArrayList<>();
		pending.add(first.name);

		while (pending.size() > 0) {
			final String name = pending.removeFirst();
			final BasicBlock block = cfg.get(name);
			if (newInstructions.containsKey(name)) {
				continue;
			}

			final List<IRInstruction> instructions = convert(block);
			newInstructions.put(block.name, instructions);

			final List<String> successors = block.successors();
			pending.addAll(successors);

			for (String successor : successors) {
				final Map<IRVar, Phi> phiNodes = this.phiNodes.get(successor);
				if (phiNodes == null) {
					continue;
				}

				final BasicBlock successorBlock = cfg.get(successor);
				final int i = successorBlock.predecessors().indexOf(name);
				Utils.assertTrue(i >= 0);

				for (Map.Entry<IRVar, Phi> entry : phiNodes.entrySet()) {
					final IRVar var = entry.getKey();
					final VarReplacement replacement = varMapping.get(var);
					final Phi phi = entry.getValue();
					Utils.assertTrue(phi.input[i] == null);
					phi.input[i] = replacement != null ? replacement.current() : var;
				}
			}
		}

		final List<IRInstruction> instructions = new ArrayList<>();
		for (BasicBlock block : cfg.blocks()) {
			final String name = block.name;
			if (block != first) {
				instructions.add(new IRLabel(name));
			}
			final Map<IRVar, Phi> phiNodes = this.phiNodes.get(name);
			if (phiNodes != null) {
				final List<IRVar> sortedVars = new ArrayList<>(phiNodes.keySet());
				sortedVars.sort(Comparator.comparingInt(IRVar::index));
				for (IRVar var : sortedVars) {
					final Phi phi = phiNodes.get(var);
					instructions.add(new IRPhi(phi.replacement, List.of(phi.input)));
				}
			}
			instructions.addAll(newInstructions.get(name));
		}
		return instructions;
	}

	private List<IRInstruction> convert(BasicBlock block) {
		final List<IRInstruction> instructions = new ArrayList<>();
		for (IRInstruction instruction : block.instructions()) {
			instructions.add(convert(instruction));
		}
		return instructions;
	}

	private IRInstruction convert(IRInstruction instruction) {
		return switch (instruction) {
			case IRAddrOf i -> {
				final IRVar source = source(i.source());
				final IRVar target = target(i.target());
				yield new IRAddrOf(target, source, i.location());
			}
			case IRAddrOfArray i -> {
				final IRVar target = target(i.addr());
				yield new IRAddrOfArray(target, i.array(), i.location());
			}
			case IRBinary i -> {
				final IRVar left = source(i.left());
				final IRValue right = source(i.right());
				final IRVar target = target(i.target());
				yield new IRBinary(target, i.op(), left, right, i.location());
			}
			case IRBranch i -> {
				final IRVar left = source(i.left());
				final IRValue right = source(i.right());
				yield new IRBranch(i.op(), left, right, i.target(), i.nextLabel(), i.location());
			}
			case IRCall i -> {
				final List<IRValue> args = new ArrayList<>();
				for (IRValue arg : i.args()) {
					args.add(source(arg));
				}
				IRVar target = i.target();
				if (target != null) {
					target = target(target);
				}
				yield new IRCall(target, i.type(), i.name(), args, i.location());
			}
			case IRCast i -> {
				final IRVar source = source(i.source());
				final IRVar target = target(i.target());
				yield new IRCast(target, source, i.location());
			}
			case IRComment i -> i;
			case IRCompare i -> {
				final IRVar left = source(i.left());
				final IRValue right = source(i.right());
				final IRVar target = target(i.target());
				yield new IRCompare(target, i.op(), left, right, i.location());
			}
			case IRJump i -> i;
			case IRLabel i -> i;
			case IRMemLoad i -> {
				final IRVar addr = source(i.addr());
				final IRVar target = target(i.target());
				yield new IRMemLoad(target, addr, i.location());
			}
			case IRMemStore i -> {
				final IRVar addr = source(i.addr());
				final IRVar value = source(i.value());
				yield new IRMemStore(addr, value, i.location());
			}
			case IRMove i -> {
				final IRValue source = source(i.source());
				final IRVar target = target(i.target());
				yield new IRMove(target, source, i.location());
			}
			case IRRetValue i -> {
				final IRVar var = source(i.var());
				yield new IRRetValue(var, i.location());
			}
			case IRString i -> {
				final IRVar target = target(i.target());
				yield new IRString(target, i.stringIndex(), i.location());
			}
			case IRUnary i -> {
				final IRVar source = source(i.source());
				final IRVar target = target(i.target());
				yield new IRUnary(i.op(), target, source);
			}
			default -> throw new IllegalStateException();
		};
	}

	@NotNull
	private IRValue source(IRValue value) {
		IRVar var = value.var();
		if (var != null) {
			var = source(var);
			value = new IRValue(var);
		}
		return value;
	}

	private IRVar source(IRVar var) {
		final VarReplacement replacement = varMapping.get(var);
		return replacement != null ? replacement.current : var;
	}

	private IRVar target(IRVar var) {
		if (var.scope() == VariableScope.global) {
			return var;
		}

		final VarReplacement replacement = varMapping.get(var);
		int nextIndex = 1;
		if (replacement != null) {
			nextIndex = replacement.nextIndex;
		}
		final String name = var.name() + '.' + nextIndex;
		final IRVar replacedVar = varFactory.createVar(var, name);
		varMapping.put(var, new VarReplacement(replacedVar, nextIndex + 1));
		return replacedVar;
	}

	private void initializePhiNodes() {
		for (BasicBlock block : cfg.blocks()) {
			final int predecessorCount = block.predecessors().size();
			if (predecessorCount > 1) {
				final Map<IRVar, Phi> phiNodes = new HashMap<>();
				for (IRVar var : block.getLiveBefore()) {
					if (var.scope() == VariableScope.global) {
						continue;
					}

					final IRVar replacementVar = target(var);
					final var prev = phiNodes.put(var, new Phi(replacementVar, new IRVar[predecessorCount]));
					Utils.assertTrue(prev == null);
				}
				final var prev = this.phiNodes.put(block.name, phiNodes);
				Utils.assertTrue(prev == null);
			}
		}
	}

	private record Phi(IRVar replacement, IRVar[] input) {
	}

	private record VarReplacement(@NotNull IRVar current, int nextIndex) {
	}
}
