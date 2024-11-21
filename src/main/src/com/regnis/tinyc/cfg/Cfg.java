package com.regnis.tinyc.cfg;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ir.*;

import java.util.*;
import java.util.function.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class Cfg {

	private final Map<String, BasicBlock> nameToBlock = new HashMap<>();
	private final String root;

	public Cfg(@NotNull String root) {
		this.root = root;
	}

	@NotNull
	public String getRoot() {
		return root;
	}

	@NotNull
	public BasicBlock get(@NotNull String name) {
		return Objects.requireNonNull(nameToBlock.get(name));
	}

	public void add(@NotNull BasicBlock block) {
		final BasicBlock prev = nameToBlock.put(block.name, block);
		Utils.assertTrue(prev == null, "duplicate definition of block " + block.name);
	}

	public void check() {
		final BasicBlock first = Objects.requireNonNull(nameToBlock.get(root));
		Utils.assertTrue(first.predecessors().isEmpty());

		for (Map.Entry<String, BasicBlock> entry : nameToBlock.entrySet()) {
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

	public void visitInPostOrder(@NotNull Consumer<BasicBlock> consumer) {
		visitInPostOrder(root, new ArrayList<>(), consumer);
	}

	public void setPredecessors() {
		final Map<String, List<String>> blockPredecessors = new HashMap<>();
		blockPredecessors.put(getRoot(), List.of());
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

	public void eliminateCriticalEdges() {
		final Set<CriticalEdge> candidates = new LinkedHashSet<>();
		visitPreOrder(block -> {
			final List<String> successors = block.successors();
			for (String successor : successors) {
				candidates.add(createCriticalEdge(block.name, successor));
			}
		}, null);
		visitPreOrder(block -> {
			final List<String> predecessors = block.predecessors();
			final List<String> successors = block.successors();
			if (predecessors.size() > 1 || successors.size() > 1) {
				return;
			}

			for (String predecessor : predecessors) {
				candidates.remove(createCriticalEdge(predecessor, block.name));
			}
			for (String successor : successors) {
				candidates.remove(createCriticalEdge(block.name, successor));
			}
		}, null);

		for (CriticalEdge criticalEdge : candidates) {
			eliminateCriticalEdge(criticalEdge);
		}
	}

	@NotNull
	private CriticalEdge createCriticalEdge(String predecessor, String successor) {
		return new CriticalEdge(predecessor, successor);
	}

	private void eliminateCriticalEdge(CriticalEdge criticalEdge) {
		final String from = criticalEdge.predecessor;
		final String to = criticalEdge.successor;
		final String name = "@no_critical_edge_" + nameToBlock.size();
		final BasicBlock newBlock = new BasicBlock(name, List.of(new IRJump(to)), List.of(from), List.of(to));
		add(newBlock);
		final BasicBlock fromBlock = get(from);
		fromBlock.replaceJump(to, name);
		fromBlock.replaceSuccessor(to, name);
		get(to).replacePredecessor(from, name);
	}

	private void visitPreOrder(@Nullable Consumer<BasicBlock> consumer, @Nullable BiConsumer<String, String> biConsumer) {
		visitPreOrder(getRoot(), new HashSet<>(), consumer, biConsumer);
	}

	private void visitPreOrder(String name, Set<String> visited, @Nullable Consumer<BasicBlock> consumer, @Nullable BiConsumer<String, String> biConsumer) {
		if (!visited.add(name)) {
			return;
		}

		final BasicBlock block = get(name);
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

	private void visitInPostOrder(@NotNull String name, List<String> visited, @NotNull Consumer<BasicBlock> consumer) {
		if (visited.contains(name)) {
			return;
		}

		visited.add(name);
		final BasicBlock block = nameToBlock.get(name);
		for (String successor : block.successors()) {
			visitInPostOrder(successor, visited, consumer);
		}
		consumer.accept(block);
	}

	private record CriticalEdge(String predecessor, String successor) {
	}
}
