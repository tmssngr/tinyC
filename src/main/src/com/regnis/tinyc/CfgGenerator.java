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

	public static ControlFlowGraph create(@NotNull String name, @NotNull List<IRInstruction> instructions) {
		final CfgGenerator generator = new CfgGenerator(name);
		generator.createBlocks(instructions);
		return new ControlFlowGraph(name, generator.nameToBlock);
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

	private void createBlocks(List<IRInstruction> instructions) {
		buildBlocks(instructions);
		setPredecessors();

		eliminateCriticalEdges();
	}

	private void eliminateCriticalEdges() {
		final Set<CriticalEdge> candidates = new LinkedHashSet<>();
		visitPreOrder(block -> {
			final List<String> successors = block.successors();
			for (String successor : successors) {
				candidates.add(new CriticalEdge(block.name, successor));
			}
		}, null);
		visitPreOrder(block -> {
			final List<String> predecessors = block.predecessors();
			final List<String> successors = block.successors();
			if (predecessors.size() > 1 || successors.size() > 1) {
				return;
			}

			for (String predecessor : predecessors) {
				candidates.remove(new CriticalEdge(predecessor, block.name));
			}
			for (String successor : successors) {
				candidates.remove(new CriticalEdge(block.name, successor));
			}
		}, null);

		for (CriticalEdge criticalEdge : candidates) {
			eliminateCriticalEdge(criticalEdge.predecessor, criticalEdge.successor);
		}
	}

	private void eliminateCriticalEdge(String from, String to) {
		final String name = "@no_critical_edge_" + nameToBlock.size();
		final BasicBlock newBlock = new BasicBlock(name, List.of(new IRJump(to)), List.of(from), List.of(to));
		Utils.assertTrue(nameToBlock.put(name, newBlock) == null);
		final BasicBlock fromBlock = getBlock(from);
		fromBlock.replaceJump(to, name);
		fromBlock.replaceSuccessor(to, name);
		getBlock(to).replacePredecessor(from, name);
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

	private record CriticalEdge(String predecessor, String successor) {
	}
}
