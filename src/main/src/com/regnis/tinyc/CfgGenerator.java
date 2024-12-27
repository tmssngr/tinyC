package com.regnis.tinyc;

import com.regnis.tinyc.cfg.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public class CfgGenerator {

	public static ControlFlowGraph create(@NotNull String name, @NotNull List<IRInstruction> instructions) {
		final CfgGenerator generator = new CfgGenerator(name);
		generator.createBlocks(instructions);
		return new ControlFlowGraph(generator.cfg);
	}

	private final Cfg cfg;
	private final List<IRInstruction> blockInstructions = new ArrayList<>();

	@Nullable private BasicBlock firstBlock;
	@Nullable private String blockName;

	private CfgGenerator(@NotNull String name) {
		cfg = new Cfg(name);
		blockName = name;
	}

	private void createBlocks(List<IRInstruction> instructions) {
		buildBlocks(instructions);
		cfg.setPredecessors();
		cfg.eliminateCriticalEdges();
	}

	private void buildBlocks(List<IRInstruction> instructions) {
		for (IRInstruction instruction : instructions) {
			process(instruction);
		}

		if (blockName != null) {
			addBlock(List.of());
		}
	}

	private void process(IRInstruction instruction) {
		switch (instruction) {
		case IRBranch branch -> {
			clearIfOnlyComments();
			add(branch);
			add(new IRJump(branch.nextLabel()));
			addBlock(List.of(branch.target(), branch.nextLabel()));
			blockName = branch.nextLabel();
		}
		case IRJump jump -> {
			if (blockName != null) {
				clearIfOnlyComments();
				add(jump);
				addBlock(List.of(jump.label()));
				blockName = null;
			}
		}
		case IRLabel label -> {
			final String target = label.label();
			if (blockName != null) {
				clearIfOnlyComments();
				add(new IRJump(target));
				addBlock(List.of(target));
			}
			blockName = target;
		}
		default -> add(instruction);
		}
	}

	private void addBlock(List<String> successors) {
		final String name = Objects.requireNonNull(blockName);
		final BasicBlock block = new BasicBlock(name, blockInstructions, List.of(), successors);
		cfg.add(block);
		if (firstBlock == null) {
			firstBlock = block;
		}
		blockInstructions.clear();
	}

	private void add(IRInstruction instruction) {
		Utils.assertTrue(!(instruction instanceof IRLabel));
		Utils.assertTrue(blockName != null);
		blockInstructions.add(instruction);
	}

	private void clearIfOnlyComments() {
		for (IRInstruction instruction : blockInstructions) {
			if (!(instruction instanceof IRComment)) {
				return;
			}
		}
		blockInstructions.clear();
	}
}
