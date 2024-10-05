package com.regnis.tinyc.cfg;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class CfgToChainConverter {

	public static List<CfgToChainConverter.Chain> convert(ControlFlowGraph cfg) {
		final CfgToChainConverter builder = new CfgToChainConverter(cfg);
		return builder.build();
	}

	private final Set<String> processed = new HashSet<>();
	private final List<String> pendingStarts = new LinkedList<>();
	private final ControlFlowGraph cfg;
	private final Map<String, Integer> nameToIndex;
	private final int[] loopLevels;
	private final boolean[] loopLevelIncreased;

	public CfgToChainConverter(ControlFlowGraph cfg) {
		this.cfg = cfg;
		nameToIndex = createNameToIndex(cfg);
		loopLevels = new int[nameToIndex.size()];
		loopLevelIncreased = new boolean[nameToIndex.size()];
	}

	@NotNull
	public List<CfgToChainConverter.Chain> build() {
		final List<CfgToChainConverter.Chain> chains = new ArrayList<>();

		pendingStarts.add(cfg.name());

		while (pendingStarts.size() > 0) {
			final String name = pendingStarts.removeFirst();
			if (processed.contains(name)) {
				continue;
			}

			final String lastLoopBlockName = getLastLoopBlockName(name);
			final CfgToChainConverter.Chain chain = lastLoopBlockName != null
					? getBackward(lastLoopBlockName)
					: getForward(name);
			chains.add(chain);
		}

		Utils.assertTrue(processed.size() == nameToIndex.size());

		chains.sort((chain1, chain2) -> {
			final int levels1 = chain1.loopLevelFrom + chain1.loopLevelTo;
			final int levels2 = chain2.loopLevelFrom + chain2.loopLevelTo;
			if (levels1 != levels2) {
				return levels2 - levels1;
			}

			final int length1 = chain1.basicBlocks.size();
			final int length2 = chain2.basicBlocks.size();
			return length2 - length1;
		});
		return chains;
	}

	private CfgToChainConverter.Chain getForward(String name) {
		final List<String> chain = new ArrayList<>();
		while (true) {
			chain.add(name);
			processed.add(name);
			final BasicBlock block = cfg.get(name);
			final List<String> successors = block.successors();
			String next = null;
			for (String successor : successors) {
				if (!processed.contains(successor)) {
					if (next != null) {
						pendingStarts.add(successor);
					}
					else {
						next = successor;
					}
				}
			}
			if (next == null) {
				break;
			}

			final String lastLoopBlockName = getLastLoopBlockName(next);
			if (lastLoopBlockName != null) {
				pendingStarts.add(next);
				break;
			}

			name = next;
		}
		return createChain(chain);
	}

	private CfgToChainConverter.Chain getBackward(String name) {
		Utils.assertTrue(!processed.contains(name));
		final List<String> chain = new ArrayList<>();
		while (true) {
			chain.add(name);
			processed.add(name);
			final BasicBlock block = cfg.get(name);
			final List<String> successors = block.successors();
			for (String successor : successors) {
				if (!processed.contains(successor)) {
					pendingStarts.add(successor);
				}
			}

			final List<String> predecessors = block.predecessors();
			String bestPredecessor = null;
			for (String predecessor : predecessors) {
				if (processed.contains(predecessor)) {
					continue;
				}

				final int predecessorIndex = get(predecessor);
				if (bestPredecessor == null || predecessorIndex < get(bestPredecessor)) {
					bestPredecessor = predecessor;
				}
			}
			if (bestPredecessor == null) {
				break;
			}

			final String lastLoopBlockName = getLastLoopBlockName(bestPredecessor);
			if (lastLoopBlockName != null) {
				break;
			}

			name = bestPredecessor;
		}
		return createChain(chain.reversed());
	}

	@NotNull
	private CfgToChainConverter.Chain createChain(List<String> chain) {
		final int loopLevelFrom = getLoopLevel(chain.getFirst());
		final int loopLevelTo = getLoopLevel(chain.getLast());
		return new CfgToChainConverter.Chain(loopLevelFrom, loopLevelTo, chain);
	}

	@Nullable
	private String getLastLoopBlockName(String name) {
		final int currentIndex = get(name);
		final BasicBlock block = cfg.get(name);
		final List<String> predecessors = block.predecessors();
		for (String predecessor : predecessors) {
			if (!processed.contains(predecessor)) {
				final int predIndex = get(predecessor);
				if (predIndex > currentIndex) {
					increaseLoopLevel(currentIndex, predIndex);
					return predecessor;
				}
			}
		}

		return null;
	}

	private int get(String name) {
		return nameToIndex.get(name);
	}

	private int getLoopLevel(String name) {
		return loopLevels[get(name)];
	}

	private void increaseLoopLevel(int from, int to) {
		Utils.assertTrue(0 <= from);
		Utils.assertTrue(from <= to);
		Utils.assertTrue(to < loopLevels.length);
		if (loopLevelIncreased[from]) {
			return;
		}
		loopLevelIncreased[from] = true;
		for (int i = from; i <= to; i++) {
			loopLevels[i]++;
		}
	}

	@NotNull
	private static Map<String, Integer> createNameToIndex(ControlFlowGraph cfg) {
		final Map<String, Integer> nameToIndex;
		nameToIndex = new HashMap<>();
		final List<BasicBlock> blocks = cfg.blocks();
		for (int i = 0; i < blocks.size(); i++) {
			final BasicBlock block = blocks.get(i);
			nameToIndex.put(block.name, i);
		}
		return nameToIndex;
	}

	public record Chain(int loopLevelFrom, int loopLevelTo, List<String> basicBlocks) {
	}
}
