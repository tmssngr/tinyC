package com.regnis.tinyc;

import com.regnis.tinyc.cfg.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public class CfgGenerator {

	@NotNull
	public static ControlFlowGraph create(@NotNull IRFunction function) {
		Utils.assertTrue(function.asmLines().isEmpty());
		final List<BasicBlock> blocks = createBlocks(function.name(), function.instructions());
		final ControlFlowGraph cfg = new ControlFlowGraph(function, blocks);
		DetectVarLiveness.process(cfg);
		return cfg;
	}

	@NotNull
	static List<BasicBlock> createBlocks(@NotNull String name, @NotNull List<IRInstruction> instructions) {
		final CfgGenerator generator = new CfgGenerator(name);
		return generator.createBlocks(instructions);
	}

	private final List<BasicBlock> blocks = new ArrayList<>();
	private final List<IRInstruction> blockInstructions = new ArrayList<>();

	@Nullable private String blockName;

	private CfgGenerator(@NotNull String name) {
		blockName = name;
	}

	private List<BasicBlock> createBlocks(List<IRInstruction> instructions) {
		for (IRInstruction instruction : instructions) {
			process(instruction);
		}

		if (blockName != null) {
			addBlock(List.of());
		}

		final Map<String, List<String>> blockPredecessors = new HashMap<>();
		final Set<String> used = new HashSet<>();
		visitBlocksInExecutionOrder(used, blockPredecessors);

		final List<BasicBlock> blocks = new ArrayList<>();
		for (BasicBlock block : this.blocks) {
			if (used.contains(block.name)) {
				final List<String> predecessors = blockPredecessors.get(block.name);
				blocks.add(new BasicBlock(block.name, block.instructions, List.copyOf(predecessors), block.successors));
			}
		}
		return blocks;
	}

	private void visitBlocksInExecutionOrder(Set<String> used, Map<String, List<String>> blockPredecessors) {
		final Map<String, BasicBlock> nameToBlock = new HashMap<>();
		for (BasicBlock block : blocks) {
			final BasicBlock prev = nameToBlock.put(block.name, block);
			Utils.assertTrue(prev == null);
		}

		final BasicBlock first = blocks.getFirst();
		blockPredecessors.put(first.name, List.of());
		used.add(first.name);

		final List<BasicBlock> pending = new ArrayList<>();
		pending.add(first);
		while (!pending.isEmpty()) {
			final BasicBlock block = pending.removeLast();
			final String name = block.name;
			for (String successor : block.successors) {
				final List<String> predecessors = blockPredecessors.computeIfAbsent(successor, unused -> new LinkedList<>());
				Utils.assertTrue(!predecessors.contains(name));
				predecessors.add(name);
				if (used.add(successor)) {
					pending.add(nameToBlock.get(successor));
				}
			}
		}
	}

	private void process(IRInstruction instruction) {
		switch (instruction) {
		case IRBranch branch -> {
			clearIfOnlyComments();
			add(branch);
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
		blocks.add(new BasicBlock(Objects.requireNonNull(blockName), blockInstructions, List.of(), successors));
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
