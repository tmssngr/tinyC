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

			new Peephole2Optimization<>(instructions) {
				@Override
				protected void handle(IRInstruction item1, IRInstruction item2) {
					if (item1 instanceof IRJump jump
					    && item2 instanceof IRLabel label
					    && jump.label().equals(label.label())) {
						remove();
					}
				}
			}.process();

			removeObsoleteLabels(instructions);

			if (initialInstructions.equals(instructions)) {
				return instructions;
			}

			initialInstructions = instructions;
		}
	}

	private static List<IRInstruction> removeObsoleteLabelJump(List<IRInstruction> instructions) {
		final Map<String, String> oldToNewTarget = new HashMap<>();
		final Set<String> obsoleteLabels = new HashSet<>();
		new Peephole2Optimization<>(instructions) {
			@Override
			protected void handle(IRInstruction item1, IRInstruction item2) {
				if (item1 instanceof IRLabel label
				    && item2 instanceof IRJump jump) {
					final String prev = oldToNewTarget.put(label.label(), jump.label());
					Utils.assertTrue(prev == null);
					obsoleteLabels.add(label.label());
				}
				else if (item1 instanceof IRLabel label1
				         && item2 instanceof IRLabel label2) {
					final String prev = oldToNewTarget.put(label1.label(), label2.label());
					Utils.assertTrue(prev == null);
					obsoleteLabels.add(label1.label());
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
			case IRLabel label -> {
				if (obsoleteLabels.contains(label.label())) {
					skipJump = true;
					continue;
				}

				skipJump = false;
			}
			case IRJump jump -> {
				if (skipJump) {
					skipJump = false;
					continue;
				}

				final String newTarget = getNewTarget(jump.label(), oldToNewTarget);
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
			if (instruction instanceof IRJump jump) {
				targets.add(jump.label());
			}
			else if (instruction instanceof IRBranch branch) {
				targets.add(branch.target());
			}
		}

		for (final Iterator<IRInstruction> it = instructions.iterator(); it.hasNext(); ) {
			final IRInstruction instruction = it.next();
			if (instruction instanceof IRLabel label) {
				if (!targets.contains(label.label())) {
					it.remove();
				}
			}
		}
	}
}
