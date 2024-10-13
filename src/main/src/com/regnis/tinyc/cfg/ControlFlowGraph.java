package com.regnis.tinyc.cfg;

import com.regnis.tinyc.*;

import java.util.*;
import java.util.function.*;

import org.jetbrains.annotations.*;

/**
 * No record because of additional field `nameToBlock`.
 *
 * @author Thomas Singer
 */
public final class ControlFlowGraph {

	public static void visitInPostOrder(@NotNull String first, @NotNull Map<String, BasicBlock> nameToBlock, @NotNull Consumer<BasicBlock> consumer) {
		visitInPostOrder(first, nameToBlock, new ArrayList<>(), consumer);
	}

	private final Map<String, BasicBlock> nameToBlock;
	private final String name;
	private final List<BasicBlock> blocks;

	public ControlFlowGraph(@NotNull String name, Map<String, BasicBlock> blockMap) {
		this.name = name;
		nameToBlock = new HashMap<>(blockMap);

		blocks = new ArrayList<>();
		visitInPostOrder(name, nameToBlock, block -> {
			if (block.successors().isEmpty()) {
				blocks.add(block);
			}
			else {
				blocks.addFirst(block);
			}
		});

		final BasicBlock first = Objects.requireNonNull(nameToBlock.get(name));

		Utils.assertTrue(first.predecessors().isEmpty());
		// if the method does not return, the last block has one successor
//		Utils.assertTrue(blocks.getLast().successors.isEmpty());

		for (Map.Entry<String, BasicBlock> entry : blockMap.entrySet()) {
			final BasicBlock block = entry.getValue();
			for (String predecessor : block.predecessors()) {
				if (!nameToBlock.containsKey(predecessor)) {
					new Throwable(block.name + " missing predecessor: " + predecessor).printStackTrace();
				}
			}
			for (String successor : block.successors()) {
				if (!nameToBlock.containsKey(successor)) {
					new Throwable(block.name + " missing successor: " + successor).printStackTrace();
				}
			}
		}
	}

	@NotNull
	public String name() {
		return name;
	}

	@NotNull
	public List<BasicBlock> blocks() {
		return Collections.unmodifiableList(blocks);
	}

	@NotNull
	public BasicBlock get(@NotNull String name) {
		return Objects.requireNonNull(nameToBlock.get(name), name);
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
}
