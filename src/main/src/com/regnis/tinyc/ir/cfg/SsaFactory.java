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

	public static IRFunction convert(@NotNull IRFunction function, @NotNull Type pointerIntType) {
		final ControlFlowGraph cfg = CfgGenerator.create(function.name(), function.instructions());
		DetectVarLiveness.process(cfg);
		final Pair<List<IRInstruction>, IRVarInfos> result = convert(cfg, function.varInfos(), pointerIntType);
		return function.derive(result.first(), result.second());
	}

	public static Pair<List<IRInstruction>, IRVarInfos> convert(@NotNull ControlFlowGraph cfgWithLiveness, @NotNull IRVarInfos varInfos, @NotNull Type pointerIntType) {
		final IRLocalVarFactory varFactory = new IRLocalVarFactory(varInfos, pointerIntType);
		final SsaFactory factory = new SsaFactory(cfgWithLiveness, varFactory);
		return factory.convert();
	}

	private final Map<String, Map<IRVar, Phi>> phiNodes = new LinkedHashMap<>();
	private final Map<IRVar, Integer> varToNextIndex = new LinkedHashMap<>();
	private final Map<String, List<IRInstruction>> newInstructions = new HashMap<>();
	private final ControlFlowGraph cfg;
	private final IRLocalVarFactory varFactory;

	private SsaFactory(@NotNull ControlFlowGraph cfgWithLiveness, @NotNull IRLocalVarFactory varFactory) {
		this.cfg = cfgWithLiveness;
		this.varFactory = varFactory;
	}

	private Pair<List<IRInstruction>, IRVarInfos> convert() {
		build();

		while (true) {
			final Pair<IRVar, IRVar> redundantPhiVar = getRedundantPhiVar();
			if (redundantPhiVar == null) {
				break;
			}

			rename(redundantPhiVar.first(), redundantPhiVar.second());
		}

		final List<IRInstruction> instructions = flatten();
		return removeObsoleteVars(instructions);
	}

	private void build() {
		final List<ProcessingBlock> pending = new ArrayList<>();
		pending.add(ProcessingBlock.createFirst(cfg.blocks().getFirst()));

		while (pending.size() > 0) {
			final ProcessingBlock current = pending.removeFirst();
			final String name = current.name;
			final BasicBlock block = cfg.get(name);
			if (newInstructions.containsKey(name)) {
				continue;
			}

			final Map<IRVar, IRVar> liveVars = createInitialMapping(current);

			final List<IRInstruction> instructions = convert(block, liveVars);
			newInstructions.put(block.name, instructions);

			final List<String> successors = block.successors();
			for (String successor : successors) {
				final BasicBlock successorBlock = cfg.get(successor);
				final List<String> successorPredecessors = successorBlock.predecessors();
				final int i = successorPredecessors.indexOf(name);
				Utils.assertTrue(i >= 0);

				Map<IRVar, Phi> phiNodes = this.phiNodes.get(successor);
				if (phiNodes == null) {
					final int predecessorCount = successorPredecessors.size();
					if (predecessorCount < 2) {
						pending.add(createBlock(successor, liveVars));
						continue;
					}

					Utils.assertTrue(successors.size() == 1);
					phiNodes = initializePhiNodes(successorBlock, predecessorCount);
					this.phiNodes.put(successor, phiNodes);
				}

				pending.add(new ProcessingBlock(successor, Map.of()));

				for (Map.Entry<IRVar, Phi> entry : phiNodes.entrySet()) {
					final IRVar var = entry.getKey();
					final IRVar replacement = liveVars.get(var);
					Utils.assertTrue(replacement != null);
					final Phi phi = entry.getValue();
					Utils.assertTrue(phi.input[i] == null);
					phi.input[i] = replacement;
				}
			}
		}
	}

	@NotNull
	private Pair<List<IRInstruction>, IRVarInfos> removeObsoleteVars(List<IRInstruction> instructions) {
		IRVarInfos infos = varFactory.createVarInfos();

		final Set<Integer> usedLocalVars = new HashSet<>();
		new VarUseTracker(new VarUseTracker.Handler() {
			@Override
			public void read(@NotNull IRVar var) {
				written(var);
			}

			@Override
			public void written(@NotNull IRVar var) {
				if (var.scope() == VariableScope.function) {
					usedLocalVars.add(var.index());
				}
			}
		}).process(instructions);
		final Map<IRVar, IRVar> oldToNew = new HashMap<>();
		infos = infos.removeIf(var -> var.scope() == VariableScope.function && !usedLocalVars.contains(var.index()),
		                       infos.global(), oldToNew);

		final IRVarReplacer replacer = new IRVarReplacer() {
			@NotNull
			@Override
			protected IRVar replace(@NotNull IRVar var) {
				return var.scope() != VariableScope.function ? var : oldToNew.get(var);
			}
		};
		instructions = replacer.replace(instructions);

		return new Pair<>(instructions, infos);
	}

	private void rename(IRVar from, IRVar to) {
		final IRVarReplacer replacer = new IRVarReplacer() {
			@NotNull
			@Override
			protected IRVar replace(@NotNull IRVar var) {
				return var == from ? to : var;
			}
		};
		for (Map.Entry<String, List<IRInstruction>> entry : newInstructions.entrySet()) {
			final List<IRInstruction> newInstructions = replacer.replace(entry.getValue());
			entry.setValue(newInstructions);
		}
		for (Map.Entry<String, Map<IRVar, Phi>> entry : phiNodes.entrySet()) {
			for (final Iterator<Map.Entry<IRVar, Phi>> it = entry.getValue().entrySet().iterator(); it.hasNext(); ) {
				final Phi phi = it.next().getValue();
				if (phi.replacement == from) {
					it.remove();
				}
				else {
					phi.replace(from, to);
				}
			}
		}
	}

	@Nullable
	private Pair<IRVar, IRVar> getRedundantPhiVar() {
		for (Map.Entry<String, Map<IRVar, Phi>> entry : phiNodes.entrySet()) {
			final Map<IRVar, Phi> originalVarToPhi = entry.getValue();
			for (Map.Entry<IRVar, Phi> entry2 : originalVarToPhi.entrySet()) {
				final Phi phi = entry2.getValue();
				final Pair<IRVar, IRVar> rename = phi.getRedundantRename();
				if (rename != null) {
					return rename;
				}
			}
		}
		return null;
	}

	@NotNull
	private Map<IRVar, Phi> initializePhiNodes(BasicBlock block, int predecessorCount) {
		final Map<IRVar, Phi> phiNodes = new HashMap<>();
		final List<IRVar> liveBefore = new ArrayList<>(block.getLiveBefore());
		liveBefore.sort(Comparator.comparingInt(IRVar::index));
		for (IRVar var : liveBefore) {
			if (var.scope() == VariableScope.global) {
				continue;
			}

			final IRVar replacementVar = getVarVariant(var);
			final var prev = phiNodes.put(var, new Phi(replacementVar, new IRVar[predecessorCount]));
			Utils.assertTrue(prev == null);
		}
		return phiNodes;
	}

	@NotNull
	private List<IRInstruction> flatten() {
		final List<IRInstruction> instructions = new ArrayList<>();
		boolean isFirst = true;
		for (BasicBlock block : cfg.blocks()) {
			final String name = block.name;
			if (isFirst) {
				isFirst = false;
			}
			else {
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

	@NotNull
	private Map<IRVar, IRVar> createInitialMapping(ProcessingBlock block) {
		final Map<IRVar, IRVar> live = new HashMap<>(block.initialMapping);
		final Map<IRVar, Phi> phiNodes = this.phiNodes.get(block.name);
		if (phiNodes != null) {
			for (Map.Entry<IRVar, Phi> entry : phiNodes.entrySet()) {
				final IRVar var = entry.getKey();
				final IRVar replacement = entry.getValue().replacement;
				live.put(var, replacement);
			}
		}
		return live;
	}

	private ProcessingBlock createBlock(String name, Map<IRVar, IRVar> prevMapping) {
		final BasicBlock block = cfg.get(name);
		final Map<IRVar, IRVar> initialMapping = new HashMap<>();
		final Set<IRVar> liveBefore = block.getLiveBefore();
		for (IRVar var : liveBefore) {
			final IRVar replacement = prevMapping.get(var);
			Utils.assertTrue(replacement != null);
			initialMapping.put(var, replacement);
		}
		return new ProcessingBlock(name, initialMapping);
	}

	private List<IRInstruction> convert(BasicBlock block, Map<IRVar, IRVar> liveVars) {
		final List<IRInstruction> instructions = new ArrayList<>();
		for (IRInstruction instruction : block.instructions()) {
			final IRInstruction newInstruction = convert(instruction, liveVars);
			instructions.add(newInstruction);
		}
		return instructions;
	}

	private IRInstruction convert(IRInstruction instruction, Map<IRVar, IRVar> liveVars) {
		return switch (instruction) {
			case IRAddrOf i -> {
				final IRVar source = source(i.source(), liveVars);
				final IRVar target = target(i.target(), liveVars);
				yield new IRAddrOf(target, source, i.location());
			}
			case IRAddrOfArray i -> {
				final IRVar target = target(i.addr(), liveVars);
				yield new IRAddrOfArray(target, i.array(), i.location());
			}
			case IRBinary i -> {
				final IRVar left = source(i.left(), liveVars);
				final IRValue right = source(i.right(), liveVars);
				final IRVar target = target(i.target(), liveVars);
				yield new IRBinary(target, i.op(), left, right, i.location());
			}
			case IRBranch i -> {
				final IRVar left = source(i.left(), liveVars);
				final IRValue right = source(i.right(), liveVars);
				yield new IRBranch(i.op(), left, right, i.target(), i.nextLabel(), i.location());
			}
			case IRCall i -> {
				final List<IRValue> args = new ArrayList<>();
				for (IRValue arg : i.args()) {
					args.add(source(arg, liveVars));
				}
				IRVar target = i.target();
				if (target != null) {
					target = target(target, liveVars);
				}
				yield new IRCall(target, i.type(), i.name(), args, i.location());
			}
			case IRCast i -> {
				final IRVar source = source(i.source(), liveVars);
				final IRVar target = target(i.target(), liveVars);
				yield new IRCast(target, source, i.location());
			}
			case IRComment i -> i;
			case IRCompare i -> {
				final IRVar left = source(i.left(), liveVars);
				final IRValue right = source(i.right(), liveVars);
				final IRVar target = target(i.target(), liveVars);
				yield new IRCompare(target, i.op(), left, right, i.location());
			}
			case IRJump i -> i;
			case IRLabel i -> i;
			case IRMemLoad i -> {
				final IRVar addr = source(i.addr(), liveVars);
				final IRVar target = target(i.target(), liveVars);
				yield new IRMemLoad(target, addr, i.location());
			}
			case IRMemStore i -> {
				final IRVar addr = source(i.addr(), liveVars);
				final IRVar value = source(i.value(), liveVars);
				yield new IRMemStore(addr, value, i.location());
			}
			case IRMove i -> {
				final IRValue source = source(i.source(), liveVars);
				final IRVar target = target(i.target(), liveVars);
				yield new IRMove(target, source, i.location());
			}
			case IRRetValue i -> {
				final IRVar var = i.value().var();
				if (var != null) {
					yield new IRRetValue(source(var, liveVars), i.location());
				}
				else {
					yield i;
				}
			}
			case IRString i -> {
				final IRVar target = target(i.target(), liveVars);
				yield new IRString(target, i.stringIndex(), i.location());
			}
			case IRUnary i -> {
				final IRVar source = source(i.source(), liveVars);
				final IRVar target = target(i.target(), liveVars);
				yield new IRUnary(i.op(), target, source);
			}
			default -> throw new IllegalStateException();
		};
	}

	@NotNull
	private IRValue source(IRValue value, Map<IRVar, IRVar> live) {
		IRVar var = value.var();
		if (var != null) {
			var = source(var, live);
			value = new IRValue(var);
		}
		return value;
	}

	private IRVar source(IRVar var, Map<IRVar, IRVar> live) {
		if (var.scope() == VariableScope.global) {
			return var;
		}
		final IRVar replacement = live.get(var);
		Utils.assertTrue(replacement != null);
		return replacement;
	}

	private IRVar target(IRVar var, Map<IRVar, IRVar> live) {
		if (var.scope() == VariableScope.global) {
			return var;
		}

		final IRVar replacement = getVarVariant(var);
		live.put(var, replacement);
		return replacement;
	}

	@NotNull
	private IRVar getVarVariant(@NotNull IRVar var) {
		Utils.assertTrue(var.scope() != VariableScope.global);

		final Integer i = varToNextIndex.get(var);
		int index = i != null ? i : 1;
		String name;
		while (true) {
			name = var.name() + '.' + index;
			if (!varFactory.containsVarWithName(name)) {
				break;
			}

			index++;
		}
		final IRVar replacement = varFactory.createVar(var, name);
		varToNextIndex.put(var, index + 1);
		return replacement;
	}

	private record ProcessingBlock(String name, Map<IRVar, IRVar> initialMapping) {
		@NotNull
		private static ProcessingBlock createFirst(BasicBlock block) {
			final Set<IRVar> liveBefore = block.getLiveBefore();
			final Map<IRVar, IRVar> initialMapping = new HashMap<>();
			for (IRVar var : liveBefore) {
				if (var.scope() == VariableScope.global) {
					continue;
				}
				initialMapping.put(var, var);
			}
			return new ProcessingBlock(block.name, initialMapping);
		}
	}

	private record Phi(IRVar replacement, IRVar[] input) {
		@Nullable
		public Pair<IRVar, IRVar> getRedundantRename() {
			final List<IRVar> vars = new ArrayList<>(2);
			vars.add(replacement);
			for (IRVar var : input) {
				if (vars.contains(var)) {
					continue;
				}

				if (vars.size() == 2) {
					return null;
				}

				vars.add(var);
			}
			return new Pair<>(replacement, vars.get(1));
		}

		public void replace(IRVar from, IRVar to) {
			for (int i = 0; i < input.length; i++) {
				if (input[i] == from) {
					input[i] = to;
				}
			}
		}
	}
}
