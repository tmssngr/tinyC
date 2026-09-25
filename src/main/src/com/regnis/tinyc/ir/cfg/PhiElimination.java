package com.regnis.tinyc.ir.cfg;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class PhiElimination {
	@NotNull
	public static List<IRInstruction> process(@NotNull String name, @NotNull List<IRInstruction> ssaInstructions) {
		return process(CfgGenerator.create(name, ssaInstructions));
	}

	@NotNull
	public static List<IRInstruction> process(@NotNull ControlFlowGraph cfg) {
		final List<IRInstruction> instructions = new ArrayList<>();
		for (BasicBlock block : cfg.blocks()) {
			if (instructions.size() > 0) {
				instructions.add(new IRLabel(block.name));
			}
			getInstructionsWithInlinedPhi(block, cfg, instructions);
		}
		return instructions;
	}

	private static void getInstructionsWithInlinedPhi(@NotNull BasicBlock block, @NotNull ControlFlowGraph cfg, @NotNull List<IRInstruction> instructions) {
		boolean wasBranch = false;
		for (IRInstruction instruction : block.instructions()) {
			switch (instruction) {
			case IRBranch ignored -> wasBranch = true;
			case IRPhi ignored -> {
				continue;
			}
			case IRJump jump -> {
				final Iterator<String> successors = block.successors().iterator();
				Utils.assertTrue(successors.hasNext());
				final String firstSuccessor = successors.next();
				if (successors.hasNext()) {
					Utils.assertTrue(wasBranch);
				}
				else {
					Utils.assertTrue(jump.label().equals(firstSuccessor));
					final BasicBlock successorBlock = cfg.get(firstSuccessor);
					final int i = successorBlock.predecessors().indexOf(block.name);
					Utils.assertTrue(i >= 0);
					final List<IRInstruction> successorInstructions = successorBlock.instructions();
					for (IRInstruction succI : successorInstructions) {
						if (succI instanceof IRPhi phi) {
							instructions.add(new IRMove(phi.target(), phi.sources().get(i)));
						}
						else {
							break;
						}
					}
				}
			}
			default -> {}
			}

			instructions.add(instruction);
		}
	}
}
