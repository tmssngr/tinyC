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

			removeJumpLabel(instructions);
			removeBranchJumpLabel(instructions);

			removeObsoleteLabels(instructions);

			if (initialInstructions.equals(instructions)) {
				return instructions;
			}

			initialInstructions = instructions;
		}
	}

	private static void removeJumpLabel(List<IRInstruction> instructions) {
		new Peephole2Optimization<>(instructions) {
			@Override
			protected void handle(IRInstruction item1, IRInstruction item2) {
				if (item1 instanceof IRJump(String jumpTarget)
				    && item2 instanceof IRLabel(String label)
				    && Objects.equals(jumpTarget, label)) {
					remove();
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

	private static List<IRInstruction> removeObsoleteLabelJump(List<IRInstruction> instructions) {
		final Map<String, String> oldToNewTarget = new HashMap<>();
		final Set<String> obsoleteLabels = new HashSet<>();
		new Peephole2Optimization<>(instructions) {
			@Override
			protected void handle(IRInstruction item1, IRInstruction item2) {
				if (item1 instanceof IRLabel(String label)
				    && item2 instanceof IRJump(String jumpTarget)) {
					final String prev = oldToNewTarget.put(label, jumpTarget);
					Utils.assertTrue(prev == null);
					obsoleteLabels.add(label);
				}
				else if (item1 instanceof IRLabel(String label1)
				         && item2 instanceof IRLabel(String label2)) {
					final String prev = oldToNewTarget.put(label1, label2);
					Utils.assertTrue(prev == null);
					obsoleteLabels.add(label1);
				}
			}
		}.process();

		if (obsoleteLabels.isEmpty()) {
			return instructions;
		}

		final List<IRInstruction> newInstructions = new ArrayList<>(instructions.size());
		boolean skipJump = false;
		for (IRInstruction instruction : instructions) {
			switch (instruction) {
			case IRLabel(String label) -> {
				if (obsoleteLabels.contains(label)) {
					skipJump = true;
					continue;
				}

				skipJump = false;
			}
			case IRJump(String target) -> {
				if (skipJump) {
					skipJump = false;
					continue;
				}

				final String newTarget = getNewTarget(target, oldToNewTarget);
				if (newTarget != null) {
					instruction = new IRJump(newTarget);
				}
			}
			case IRBranch branch -> {
				Utils.assertTrue(!skipJump);
				final String newTarget = getNewTarget(branch.target(), oldToNewTarget);
				if (newTarget != null) {
					instruction = new IRBranch(branch.conditionVar(), branch.jumpOnTrue(), newTarget, "");
				}
			}
			default -> Utils.assertTrue(!skipJump);
			}

			newInstructions.add(instruction);
		}
		return newInstructions;
	}

	@Nullable
	private static String getNewTarget(String label, Map<String, String> map) {
		if (!map.containsKey(label)) {
			return null;
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
