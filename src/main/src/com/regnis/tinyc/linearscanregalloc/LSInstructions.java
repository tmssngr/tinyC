package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.cfg.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class LSInstructions {
	private final List<IRInstruction> instructions = new ArrayList<>();
	private final Map<String, Indices> blockToIndex = new HashMap<>();
	private final Map<Integer, Pair<List<IRVar>, Integer>> posToLiveVars = new HashMap<>();

	private int pos;

	public LSInstructions() {
	}

	public void handleBlocks(List<BasicBlock> blocks) {
		record Block(String name, List<IRInstruction> instructions, Set<IRVar> liveAfter) {
		}

		final List<Block> blocksWithLabels = new ArrayList<>();
		pos = 0;
		blocks.forEach(block -> {
			final String name = block.name;
			final List<IRInstruction> instructions = getInstructionsWithLabel(name, block.instructions());
			blocksWithLabels.add(new Block(name, instructions, block.getLiveAfter()));
			pos += 2 * instructions.size();
		});

		for (Block block : blocksWithLabels.reversed()) {
			handleBlock(block.name, block.instructions, block.liveAfter);
		}
	}

	@NotNull
	public Pair<List<IRVar>, Integer> getLiveVarsAndBlockStartAt(int pos) {
		return posToLiveVars.get(pos);
	}

	public List<Indices> getBlockIndices() {
		final List<Indices> blockBoundaries = new ArrayList<>(blockToIndex.values());
		blockBoundaries.sort(Comparator.comparingInt(Indices::start));
		return Collections.unmodifiableList(blockBoundaries);
	}

	public Map<String, Indices> getBlockToIndex() {
		return Collections.unmodifiableMap(blockToIndex);
	}

	public List<IRInstruction> getInstructions() {
		return Collections.unmodifiableList(instructions);
	}

	@NotNull
	private List<IRInstruction> getInstructionsWithLabel(String name, List<IRInstruction> instructions) {
		if (name.startsWith("@")) {
			instructions = new ArrayList<>(instructions);
			instructions.addFirst(new IRLabel(name));
		}
		return instructions;
	}

	private void handleBlock(String name, List<IRInstruction> instructions, Set<IRVar> liveAfter) {
		final Set<IRVar> live = new HashSet<>(liveAfter);

		final int blockStart = pos - 2 * instructions.size();
		Utils.assertTrue(blockStart >= 0);

		final List<IRVar> liveSorted = new ArrayList<>(live);
		liveSorted.sort(Comparator.comparing(IRVar::scope).thenComparingInt(IRVar::index));
		posToLiveVars.put(pos - 2, new Pair<>(Collections.unmodifiableList(liveSorted), blockStart));

		int end = -1;
		for (IRInstruction instruction : instructions.reversed()) {
			if (!(instruction instanceof IRBranch)
			    && !(instruction instanceof IRJump)
			    && end < 0) {
				end = pos;
			}
			pos -= 2;
			this.instructions.addFirst(instruction);
		}

		Utils.assertTrue(blockStart == pos);

		final IndicesImpl indices = new IndicesImpl(blockStart);
		indices.setEnd(Math.max(end, 0));
		blockToIndex.put(name, indices);
	}

	public void debugPrint(@NotNull String name) {
		System.out.println(name);

		int pos = 0;
		for (IRInstruction instruction : instructions) {
			System.out.printf("%03d %s %s\n",
			                  pos,
			                  instruction instanceof IRLabel ? "" : "    ",
			                  instruction.toString());
			pos += 2;
		}
	}

	public interface Indices {
		int start();

		int end();
	}

	private static final class IndicesImpl implements Indices {
		private final int start;

		private int end;

		public IndicesImpl(int start) {
			this.start = start;
			end = start;
		}

		@Override
		public String toString() {
			return "[" + start + "-" + end + ")";
		}

		public int start() {
			return start;
		}

		public int end() {
			return end;
		}

		public void setEnd(int end) {
			Utils.assertTrue(end >= this.end);
			this.end = end;
		}
	}
}
