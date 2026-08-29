package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public class IROptimizer {

	public static List<IRInstruction> optimize(List<IRInstruction> initialInstructions) {
		while (true) {
			final List<IRInstruction> instructions = removeObsoleteLabelJump(initialInstructions);

			removeJumpJump(instructions);
			removeJumpLabel(instructions, false);
			flipBranchLabel(instructions);
			removeBranchJumpLabel(instructions);

			removeObsoleteLabels(instructions);

			if (initialInstructions.equals(instructions)) {
				return instructions;
			}

			initialInstructions = instructions;
		}
	}

	public static IRProgram branchAndLabelOptimizations(IRProgram program) {
		final List<IRFunction> functions = new ArrayList<>();
		for (IRFunction function : program.functions()) {
			final List<IRInstruction> instructions = branchAndLabelOptimizations(function.instructions());
			functions.add(new IRFunction(function.name(), function.label(), function.returnType(), function.varInfos(), instructions));
		}
		return new IRProgram(functions, program.asmFunctions(), program.varInfos(), program.stringLiterals());
	}

	public static List<IRInstruction> branchAndLabelOptimizations(List<IRInstruction> initialInstructions) {
		while (true) {
			final List<IRInstruction> instructions = removeObsoleteLabelJump(initialInstructions);

			removeJumpJump(instructions);
			removeJumpLabel(instructions, true);
			flipBranchLabel(instructions);
			removeBranchJumpLabel(instructions);

			if (initialInstructions.equals(instructions)) {
				return instructions;
			}

			initialInstructions = instructions;
		}
	}

	static List<IRInstruction> removeObsoleteLabelJump(List<IRInstruction> instructions) {
		final Map<String, String> oldToNewTarget = new HashMap<>();
		final Set<String> obsoleteLabels = new HashSet<>();
		IRInstruction prevInstruction = null;
		for (IRInstruction instruction : instructions) {
			if (prevInstruction instanceof IRLabel(String label)
			    && instruction instanceof IRJump(String jumpTarget)) {
				final String prev = oldToNewTarget.put(label, jumpTarget);
				Utils.assertTrue(prev == null);
				obsoleteLabels.add(label);
			}
			else if (prevInstruction instanceof IRLabel(String label1)
			         && instruction instanceof IRLabel(String label2)) {
				final String prev = oldToNewTarget.put(label1, label2);
				Utils.assertTrue(prev == null);
				obsoleteLabels.add(label1);
			}
			prevInstruction = instruction;
		}

		final List<IRInstruction> newInstructions = new ArrayList<>(instructions.size());
		for (IRInstruction instruction : instructions) {
			switch (instruction) {
			case IRLabel(String label) -> {
				if (!obsoleteLabels.contains(label)) {
					newInstructions.add(instruction);
				}
			}
			case IRJump(String target) -> {
				final String newTarget = getNewTarget(target, oldToNewTarget);
				newInstructions.add(new IRJump(newTarget));
			}
			case IRBranch branch -> {
				final String newTarget = getNewTarget(branch.target(), oldToNewTarget);
				final String newNextLabel = getNewTarget(branch.nextLabel(), oldToNewTarget);
				newInstructions.add(new IRBranch(branch.conditionVar(), branch.jumpOnTrue(), newTarget, newNextLabel));
			}
			default -> newInstructions.add(instruction);
			}
		}
		return newInstructions;
	}

	private static void removeJumpJump(List<IRInstruction> instructions) {
		new Peephole2Optimization<>(instructions) {
			@Override
			protected void handle(IRInstruction item1, IRInstruction item2) {
				if (item1 instanceof IRJump
				    && item2 instanceof IRJump) {
					removeNext();
				}
			}
		}.process();
	}

	private static void removeJumpLabel(List<IRInstruction> instructions, boolean ignoreJumpAfterRet) {
		new Peephole2Optimization<>(instructions) {
			private boolean skip;

			@Override
			protected void handle(IRInstruction item1, IRInstruction item2) {
				if (skip) {
					skip = false;
					return;
				}

				if (ignoreJumpAfterRet && item1 instanceof IRRetValue) {
					skip = true;
					return;
				}

				if (item1 instanceof IRJump(String jumpTarget)
				    && item2 instanceof IRLabel(String label)
				    && Objects.equals(jumpTarget, label)) {
					remove();
				}
			}
		}.process();
	}

	private static void flipBranchLabel(List<IRInstruction> instructions) {
		new Peephole2Optimization<>(instructions) {
			@Override
			protected void handle(IRInstruction item1, IRInstruction item2) {
				if (item1 instanceof IRBranch branch
				    && item2 instanceof IRLabel(String label)
				    && Objects.equals(branch.target(), label)) {
					remove();
					insert(new IRBranch(branch.conditionVar(), !branch.jumpOnTrue(), branch.nextLabel(), label));
				}
			}
		}.process();
	}

	private static void removeBranchJumpLabel(List<IRInstruction> instructions) {
		new Peephole3Optimization<>(instructions) {
			@Override
			protected void handle(IRInstruction item1, IRInstruction item2, IRInstruction item3) {
				if (item1 instanceof IRBranch branch
				    && item2 instanceof IRJump(String jumpTarget)
				    && item3 instanceof IRLabel(String label)
				    && Objects.equals(branch.target(), label)) {
					remove();
					remove();
					insert(new IRBranch(branch.conditionVar(), !branch.jumpOnTrue(), jumpTarget, branch.target()));
				}
			}
		}.process();
	}

	@NotNull
	private static String getNewTarget(String label, Map<String, String> map) {
		if (!map.containsKey(label)) {
			return label;
		}

		while (true) {
			final String target = map.get(label);
			if (target == null) {
				return label;
			}

			label = target;
		}
	}

	private static void removeObsoleteLabels(List<IRInstruction> instructions) {
		final Set<String> targets = new HashSet<>();
		for (IRInstruction instruction : instructions) {
			if (instruction instanceof IRJump(String jumpTarget)) {
				targets.add(jumpTarget);
			}
			else if (instruction instanceof IRBranch branch) {
				targets.add(branch.target());
			}
		}

		for (final Iterator<IRInstruction> it = instructions.iterator(); it.hasNext(); ) {
			final IRInstruction instruction = it.next();
			if (instruction instanceof IRLabel(String label)) {
				if (!targets.contains(label)) {
					it.remove();
				}
			}
		}
	}
}
