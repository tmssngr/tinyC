package com.regnis.tinyc.cfg;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public class CfgLoopInfos {

	private final Map<String, BlockInfo> blockToInfo = new HashMap<>();
	private final Map<String, LoopInfo> loopHeaderToInfo = new HashMap<>();
	private final List<String> blocksInOrder = new ArrayList<>();
	private final Cfg cfg;

	public CfgLoopInfos(Cfg cfg) {
		this.cfg = cfg;
		detectLoopHeadersAndNodes();
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

	public int getLoopLevel(String name) {
		int level = getBlock(name).getLoopLevel();
		if (isLoopHeader(name)) {
			level++;
		}
		return level;
	}

	private boolean isLoopHeader(String name) {
		return loopHeaderToInfo.containsKey(name);
	}

	private void detectLoopHeadersAndNodes() {
		detectBackEdges(cfg.getRoot(), new HashSet<>());
		detectLoopNodes();
		detectLoopNesting();
		detectOrder();
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

	private void detectOrder() {
		final List<String> pendingStack = new ArrayList<>();
		pendingStack.add(cfg.getRoot());
		while (!pendingStack.isEmpty()) {
			final String name = pendingStack.removeLast();
			blocksInOrder.add(name);
			final BlockInfo block = getBlock(name);
			final List<String> successors = block.successors();
			for (String successor : successors) {
				final BlockInfo successorBlock = getBlock(successor);
				successorBlock.incomingForwardEdgeCount--;
				final boolean isReadyForProcessing = successorBlock.incomingForwardEdgeCount == 0;
				if (isReadyForProcessing) {
					sortIntoStack(successor, pendingStack);
				}
			}
		}
	}

	private void sortIntoStack(String name, List<String> pendingStack) {
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
