package com.regnis.tinyc.cfg;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public class CfgLoopInfos {

	private final Map<String, BlockInfo> blockToInfo = new HashMap<>();
	private final Map<String, LoopInfo> loopHeaderToInfo = new HashMap<>();
	private final List<String> blocksInOrder;
	private final Cfg cfg;

	public CfgLoopInfos(Cfg cfg) {
		this.cfg = cfg;
		detectBackEdges(this.cfg.getRoot(), new HashSet<>());
		detectLoopNodes();
		detectLoopNesting();
		blocksInOrder = detectOrder();

		checkOrder(cfg, blocksInOrder);
	}

	public Map<String, Set<String>> getLoops() {
		final Map<String, Set<String>> map = new HashMap<>();
		for (Map.Entry<String, LoopInfo> entry : loopHeaderToInfo.entrySet()) {
			map.put(entry.getKey(), new HashSet<>(entry.getValue().loopNodes));
		}
		return map;
	}

	public List<String> getInOrder() {
		return List.copyOf(blocksInOrder);
	}

	public List<BlockPath> getBlockPaths() {
		return detectPaths();
	}

	public List<String> getBlocksInOrder2() {
		return detectOrder2();
	}

	public int getLoopLevel(String name) {
		int level = getBlock(name).getLoopLevel();
		if (isLoopHeader(name)) {
			level++;
		}
		return level;
	}

	public List<String> detectOrder3() {
		final List<String> order = new ArrayList<>();
		final List<String> pending = new ArrayList<>();
		pending.add(cfg.getRoot());
		while (!pending.isEmpty()) {
			final String name = pending.removeLast();
			System.out.println(name);

			final BasicBlock block = cfg.get(name);
			final List<String> predecessors = block.predecessors();
			boolean skip = false;
			for (String predecessor : predecessors) {
				if (!order.contains(predecessor)) {
					pending.addFirst(predecessor);
					skip = true;
				}
			}
			if (skip) {
				continue;
			}

			final List<String> successors = block.successors();
			if (successors.isEmpty() && !pending.isEmpty()) {
				pending.addFirst(name);
				continue;
			}

			order.add(name);

			pending.addAll(successors);
		}
		return order;
	}

	private boolean isLoopHeader(String name) {
		return loopHeaderToInfo.containsKey(name);
	}

	private void detectBackEdges(String name, Set<String> visited) {
		if (!visited.add(name)) {
			return;
		}

		final BlockInfo blockInfo = getBlockMaybeCreate(name);

		blockInfo.active = true;

		final List<String> successors = blockInfo.successors();
		for (String successor : successors) {
			final BlockInfo successorInfo = getBlockMaybeCreate(successor);
			if (successorInfo.active) {
				final LoopInfo info = loopHeaderToInfo.computeIfAbsent(successor, k -> new LoopInfo());
				info.loopEnds.add(name);
				continue;
			}

			successorInfo.incomingForwardEdgeCount++;

			detectBackEdges(successor, visited);
		}

		blockInfo.active = false;
	}

	@NotNull
	private BlockInfo getBlockMaybeCreate(String name) {
		BlockInfo blockInfo = blockToInfo.get(name);
		if (blockInfo == null) {
			final BasicBlock block = cfg.get(name);
			blockInfo = new BlockInfo(block);
			blockToInfo.put(name, blockInfo);
		}
		return blockInfo;
	}

	@NotNull
	private BlockInfo getBlock(String name) {
		return Objects.requireNonNull(blockToInfo.get(name));
	}

	private void detectLoopNodes() {
		for (Map.Entry<String, LoopInfo> entry : loopHeaderToInfo.entrySet()) {
			final String loopHeader = entry.getKey();
			final LoopInfo info = entry.getValue();
			for (String loopEnd : info.loopEnds) {
				detectLoopNodes(loopEnd, loopHeader, info.loopNodes);
			}
		}
	}

	private void detectLoopNodes(String name, String loopHeader, Set<String> visited) {
		if (name.equals(loopHeader)) {
			return;
		}

		if (!visited.add(name)) {
			return;
		}

		final BlockInfo block = getBlock(name);
		block.containedInLoops.add(loopHeader);

		final List<String> predecessors = block.predecessors();
		for (String predecessor : predecessors) {
			detectLoopNodes(predecessor, loopHeader, visited);
		}
	}

	private void detectLoopNesting() {
		for (Map.Entry<String, LoopInfo> entry : loopHeaderToInfo.entrySet()) {
			final String loopHeader = entry.getKey();
			final LoopInfo info = entry.getValue();
			final int size = info.loopNodes.size();
			for (Map.Entry<String, LoopInfo> entry2 : loopHeaderToInfo.entrySet()) {
				final LoopInfo info2 = entry2.getValue();
				if (info2 == info) {
					continue;
				}
				if (info2.loopNodes.size() < size) {
					continue;
				}
				if (info2.loopNodes.contains(loopHeader)) {
					info.level++;
				}
			}
		}
	}

	private List<BlockPath> detectPaths() {
		final List<BlockPath> paths = new ArrayList<>();

		final List<BlockPath> pending = new ArrayList<>();
		pending.add(new BlockPath(cfg.getRoot()));
		while (pending.size() > 0) {
			final BlockPath path = pending.removeLast();
			final String name = path.name;
			final BasicBlock block = cfg.get(name);
			final List<String> successors = block.successors();
			if (successors.isEmpty()) {
				paths.add(path);
				continue;
			}

			for (String successor : successors) {
				final BlockPath successorPath = path.resolve(successor);
				if (path.contains(successor)) {
					paths.add(successorPath);
					continue;
				}
				pending.add(successorPath);
			}
		}

		return paths;
	}

	private List<String> detectOrder2() {
		final Map<String, BlockInfo2> nameToBlockInfo = new HashMap<>();
		cfg.allNames().forEach(name -> nameToBlockInfo.put(name, new BlockInfo2()));

		final List<BlockPath> pending = new ArrayList<>();
		pending.add(new BlockPath(cfg.getRoot()));
		while (pending.size() > 0) {
			final BlockPath path = pending.removeLast();
			final String name = path.name;
			final int maxDepth = nameToBlockInfo.get(name).maxDepthFromRoot + 1;
			final BasicBlock block = cfg.get(name);
			final List<String> successors = block.successors();
			for (String successor : successors) {
				final BlockInfo2 info = nameToBlockInfo.get(successor);
				if (path.contains(successor)) {
					markLoopHeader(successor, path, nameToBlockInfo);
					continue;
				}
				if (info.maxDepthFromRoot < maxDepth) {
					info.maxDepthFromRoot = maxDepth;
					pending.add(path.resolve(successor));
				}
			}
		}

		pending.add(new BlockPath(getEnd(nameToBlockInfo)));
		while (pending.size() > 0) {
			final BlockPath path = pending.removeLast();
			final String name = path.name;
			final int maxDepth = nameToBlockInfo.get(name).maxDepthFromEnd + 1;
			final BasicBlock block = cfg.get(name);
			final List<String> predecessors = block.predecessors();
			for (String predecessor : predecessors) {
				final BlockInfo2 info = nameToBlockInfo.get(predecessor);
				if (path.contains(predecessor)) {
					continue;
				}
				if (info.maxDepthFromEnd < maxDepth) {
					info.maxDepthFromEnd = maxDepth;
					pending.add(path.resolve(predecessor));
				}
			}
		}

		final List<String> blocksInOrder = new ArrayList<>();
		final List<String> pendingStack = new ArrayList<>();
		pendingStack.add(cfg.getRoot());
		while (!pendingStack.isEmpty()) {
			final String name = pendingStack.removeLast();
			if (blocksInOrder.contains(name)) {
				continue;
			}
			blocksInOrder.add(name);

			final BasicBlock block = cfg.get(name);
			final List<String> successors = block.successors();
			pendingStack.addAll(successors);
		}
		return blocksInOrder;
	}

	private String getEnd(Map<String, BlockInfo2> map) {
		Map.Entry<String, BlockInfo2> highest = null;
		for (Map.Entry<String, BlockInfo2> entry : map.entrySet()) {
			final BlockInfo2 value = entry.getValue();
			if (value.loopHeaders.isEmpty()) {
				if (highest != null && highest.getValue().maxDepthFromRoot > value.maxDepthFromRoot) {
					continue;
				}

				highest = entry;
			}
		}
		return Objects.requireNonNull(highest).getKey();
	}

	private void markLoopHeader(String loopHeader, BlockPath path, Map<String, BlockInfo2> nameToBlockInfo) {
		BlockPath loopPath = path;
		while (true) {
			nameToBlockInfo.get(loopPath.name).loopHeaders.add(loopHeader);
			if (loopPath.name.equals(loopHeader)) {
				break;
			}
			loopPath = Objects.requireNonNull(loopPath.prev);
		}
	}

	private List<String> detectOrder() {
		final List<String> blocksInOrder = new ArrayList<>();
		final List<String> pendingStack = new ArrayList<>();
		pendingStack.add(cfg.getRoot());
		while (!pendingStack.isEmpty()) {
			final String name = pendingStack.removeLast();
			blocksInOrder.add(name);
			processBlock(name, pendingStack);
		}
		return blocksInOrder;
	}

	private void processBlock(String name, List<String> pendingStack) {
		final BlockInfo block = getBlock(name);
		final List<String> successors = block.successors();
		for (String successor : successors) {
			final BlockInfo successorBlock = getBlock(successor);
			successorBlock.incomingForwardEdgeCount--;
			final boolean isReadyForProcessing = successorBlock.incomingForwardEdgeCount == 0;
			if (isReadyForProcessing) {
				sortIntoStack(successor, pendingStack);
				if (isLoopHeader(successor)) {
					processBlock(successor, pendingStack);
				}
			}
		}
	}

	private void sortIntoStack(String name, List<String> pendingStack) {
		if (pendingStack.isEmpty()) {
			pendingStack.add(name);
			return;
		}

		final int weight = getWeight(name);
		int i = pendingStack.size();
		while (i-- > 0) {
			final String pendingName = pendingStack.get(i);
			final int pendingWeight = getWeight(pendingName);
			if (weight > pendingWeight) {
				break;
			}
		}
		pendingStack.add(i + 1, name);
	}

	private int getWeight(String name) {
		return getBlock(name).getLoopLevel();
	}

	private static void checkOrder(Cfg cfg, List<String> blocksInOrder) {
		for (int i = 0; i < blocksInOrder.size(); i++) {
			final String name = blocksInOrder.get(i);
			final BasicBlock block = cfg.get(name);
			final List<String> successors = block.successors();
			if (successors.size() > 1) {
				boolean found = false;
				for (String successor : successors) {
					if (blocksInOrder.indexOf(successor) == i + 1) {
						found = true;
						break;
					}
				}
				if (!found) {
					System.out.println("Blocks out of order");
					System.out.println(blocksInOrder);
					System.out.println("  " + name + ": " + successors);
					break;
				}
			}
		}
	}

	private static final class BlockInfo2 {
		public final Set<String> loopHeaders = new HashSet<>();

		public int maxDepthFromRoot;
		public int maxDepthFromEnd;

		@Override
		public String toString() {
			return maxDepthFromRoot + " " + maxDepthFromEnd + " " + loopHeaders;
		}
	}

	public record BlockPath(String name, @Nullable BlockPath prev) {
		public BlockPath(String name) {
			this(name, null);
		}

		@Override
		public String toString() {
			final StringBuilder buffer = new StringBuilder();
			toString(buffer);
			return buffer.toString();
		}

		public boolean contains(String name) {
			BlockPath path = this;
			while (path != null) {
				if (path.name.equals(name)) {
					return true;
				}
				path = path.prev;
			}
			return false;
		}

		private void toString(StringBuilder buffer) {
			if (prev != null) {
				prev.toString(buffer);
				buffer.append(" > ");
			}
			buffer.append(name);
		}

		@NotNull
		public BlockPath resolve(String successor) {
			return new BlockPath(successor, this);
		}
	}

	private static final class BlockInfo {

		public final Set<String> containedInLoops = new HashSet<>();
		public final BasicBlock block;

		public boolean active;
		public int incomingForwardEdgeCount;

		public BlockInfo(BasicBlock block) {
			this.block = block;
		}

		public List<String> successors() {
			return block.successors();
		}

		public List<String> predecessors() {
			return block.predecessors();
		}

		public int getLoopLevel() {
			return containedInLoops.size();
		}
	}

	private static final class LoopInfo {

		private final Set<String> loopEnds = new HashSet<>();
		private final Set<String> loopNodes = new HashSet<>();

		private int level = 1;
	}
}
