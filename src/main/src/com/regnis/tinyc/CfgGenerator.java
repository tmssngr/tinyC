package com.regnis.tinyc;

import com.regnis.tinyc.cfg.*;
import com.regnis.tinyc.ir.*;

import java.util.*;
import java.util.function.*;

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

	public static void visitInPostOrder(@NotNull String first, @NotNull List<BasicBlock> blocks, @NotNull Consumer<BasicBlock> consumer) {
		visitInPostOrder(first, createNameToBlock(blocks), consumer);
	}

	@NotNull
	static List<BasicBlock> createBlocks(@NotNull String name, @NotNull List<IRInstruction> instructions) {
		final CfgGenerator generator = new CfgGenerator(name);
		return generator.createBlocks(instructions);
	}

	private final Map<String, BasicBlock> nameToBlock = new HashMap<>();
	private final List<IRInstruction> blockInstructions = new ArrayList<>();
	private final String name;

	@Nullable private BasicBlock firstBlock;
	@Nullable private String blockName;

	private CfgGenerator(@NotNull String name) {
		this.name = name;
		blockName = name;
	}

	private List<BasicBlock> createBlocks(List<IRInstruction> instructions) {
		buildBlocks(instructions);
		setPredecessors();

		return linearizeInPostOrderTraversal();
	}

	@NotNull
	private BasicBlock getBlock(String name) {
		return Objects.requireNonNull(nameToBlock.get(name));
	}

	private void buildBlocks(List<IRInstruction> instructions) {
		for (IRInstruction instruction : instructions) {
			process(instruction);
		}

		if (blockName != null) {
			addBlock(List.of());
		}
	}

	private List<BasicBlock> linearizeInPostOrderTraversal() {
		final List<BasicBlock> blocks = new ArrayList<>();
		visitInPostOrder(name, nameToBlock, block -> {
			if (block.successors().isEmpty()) {
				blocks.add(block);
			}
			else {
				blocks.addFirst(block);
			}
		});
		return blocks;
	}

	private void setPredecessors() {
		final Map<String, List<String>> blockPredecessors = new HashMap<>();
		blockPredecessors.put(this.name, List.of());
		visitPreOrder(null, (name, successor) -> {
			final List<String> predecessors = blockPredecessors.computeIfAbsent(successor, unused -> new LinkedList<>());
			Utils.assertTrue(!predecessors.contains(name));
			predecessors.add(name);
		});

		visitPreOrder(block -> {
			final List<String> predecessors = Objects.requireNonNull(blockPredecessors.get(block.name));
			block.setPredecessors(predecessors);
		}, null);
	}

	private void visitPreOrder(@Nullable Consumer<BasicBlock> consumer, @Nullable BiConsumer<String, String> biConsumer) {
		visitPreOrder(name, new HashSet<>(), consumer, biConsumer);
	}

	private void visitPreOrder(String name, Set<String> visited, @Nullable Consumer<BasicBlock> consumer, @Nullable BiConsumer<String, String> biConsumer) {
		if (!visited.add(name)) {
			return;
		}

		final BasicBlock block = getBlock(name);
		if (consumer != null) {
			consumer.accept(block);
		}
		for (String successor : block.successors()) {
			if (biConsumer != null) {
				biConsumer.accept(name, successor);
			}
			visitPreOrder(successor, visited, consumer, biConsumer);
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
		final String name = Objects.requireNonNull(blockName);
		final BasicBlock block = new BasicBlock(name, blockInstructions, List.of(), successors);
		final BasicBlock prev = nameToBlock.put(name, block);
		Utils.assertTrue(prev == null, "duplicate definition of block " + name);
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

	private static void visitInPostOrder(@NotNull String first, @NotNull Map<String, BasicBlock> nameToBlock, @NotNull Consumer<BasicBlock> consumer) {
		visitInPostOrder(first, nameToBlock, new ArrayList<>(), consumer);
	}

	private static void visitInPostOrder(@NotNull String name, @NotNull Map<String, BasicBlock> nameToBlock, List<String> visited, @NotNull Consumer<BasicBlock> consumer) {
		if (visited.contains(name)) {
			return;
		}

		visited.add(name);
		final BasicBlock block = nameToBlock.get(name);
		for (String successor : block.successors()) {
			visitInPostOrder(successor, nameToBlock, visited, consumer);
		}
		consumer.accept(block);
	}

	@NotNull
	private static Map<String, BasicBlock> createNameToBlock(List<BasicBlock> blocks) {
		final Map<String, BasicBlock> nameToBlock = new HashMap<>();
		for (BasicBlock block : blocks) {
			final BasicBlock prev = nameToBlock.put(block.name, block);
			Utils.assertTrue(prev == null);
		}
		return nameToBlock;
	}
}
