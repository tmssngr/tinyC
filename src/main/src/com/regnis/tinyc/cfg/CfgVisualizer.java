package com.regnis.tinyc.cfg;

import java.util.*;

/**
 * @author Thomas Singer
 */
public final class CfgVisualizer {
	public static String visualize(List<BasicBlock> blocks) {
		final List<String> names = new ArrayList<>(blocks.size());
		final Map<String, Integer> nameToIndex = new HashMap<>();
		for (BasicBlock block : blocks) {
			nameToIndex.put(block.name, names.size());
			names.add(block.name);
		}

		final Map<Integer, List<Arrow>> lengthToArrows = new HashMap<>();
		for (BasicBlock block : blocks) {
			final int from = nameToIndex.get(block.name);
			for (String successor : block.successors()) {
				final int to = nameToIndex.get(successor);
				final Arrow arrow = new Arrow(from, to);
				final int length = arrow.length();
				final List<Arrow> arrows = lengthToArrows.computeIfAbsent(length, k -> new ArrayList<>());
				arrows.add(arrow);
			}
		}

		final List<Integer> lengths = new ArrayList<>(lengthToArrows.keySet());
		lengths.sort((o1, o2) -> {
			final boolean positive1 = o1 > 0;
			final boolean positive2 = o2 > 0;
			if (positive1 != positive2) {
				return positive1 ? 1 : -1;
			}
			return Math.abs(o1) - Math.abs(o2);
		});
		for (List<Arrow> arrows : lengthToArrows.values()) {
			//noinspection ComparatorCombinators
			arrows.sort((a1, a2) -> {
				final int leftDiff = a1.min() - a2.min();
				if (leftDiff != 0) {
					return leftDiff;
				}
				return a1.max() - a2.max();
			});
		}

		final List<Level> levels = new ArrayList<>();
		int firstPositiveLevel = -1;
		int firstPositiveLevelLength = 0;
		for (int length : lengths) {
			if (firstPositiveLevel < 0 && length > 0) {
				firstPositiveLevel = levels.size();
				firstPositiveLevelLength = length;
			}
			final List<Arrow> pending = new ArrayList<>(lengthToArrows.get(length));
			while (!pending.isEmpty()) {
				final Level level = new Level();
				levels.add(level);
				int max = -1;
				for (final Iterator<Arrow> it = pending.iterator(); it.hasNext(); ) {
					final Arrow arrow = it.next();
					final int min = arrow.min();
					if (min < max) {
						continue;
					}

					level.arrows.add(arrow);
					max = arrow.max();
					it.remove();

				}
			}
		}

		final int[] blockLeft = new int[names.size()];
		final int[] blockRight = new int[names.size()];
		int left = 0;
		for (int i = 0; i < names.size(); i++) {
			final String name = names.get(i);
			blockLeft[i] = left;
			final int right = left + name.length();
			blockRight[i] = right - 1;
			left = right + 4;
		}

		final List<String> lines = new ArrayList<>();
		final StringBuilder buffer = new StringBuilder();

		for (int i = firstPositiveLevel; i-- > 0; ) {
			final Level level = levels.get(i);
			buffer.setLength(0);
			for (Arrow arrow : level.arrows) {
				int pos = blockLeft[arrow.min()];
				while (buffer.length() < pos) {
					buffer.append(' ');
				}
				pos = blockRight[arrow.max()];
				while (buffer.length() < pos) {
					buffer.append('-');
				}
			}
			lines.add(buffer.toString());
		}

		{
			final boolean[] froms = new boolean[names.size()];
			final boolean[] tos = new boolean[names.size()];
			for (int i = 0; i < firstPositiveLevel; i++) {
				final Level level = levels.get(i);
				for (Arrow arrow : level.arrows) {
					froms[arrow.from] = true;
					tos[arrow.to] = true;
				}
			}

			buffer.setLength(0);
			for (int i = 0; i < names.size(); i++) {
				if (tos[i]) {
					final int pos = blockLeft[i];
					while (buffer.length() < pos) {
						buffer.append(' ');
					}
					buffer.append('v');
				}
				if (froms[i]) {
					final int pos = blockRight[i];
					while (buffer.length() < pos) {
						buffer.append(' ');
					}
					buffer.append('|');
				}
			}
			if (buffer.length() > 0) {
				lines.add(buffer.toString());
			}
		}

		{
			Iterator<Arrow> arrowIt = Collections.emptyIterator();
			if (firstPositiveLevelLength == 1) {
				final List<Arrow> arrows = levels.get(firstPositiveLevel).arrows;
				arrowIt = arrows.iterator();
				firstPositiveLevel++;
			}
			Arrow arrow = null;
			buffer.setLength(0);
			for (int i = 0; i < names.size(); i++) {
				final String name = names.get(i);
				if (arrow == null && arrowIt.hasNext()) {
					arrow = arrowIt.next();
				}
				final int pos = blockLeft[i];
				while (buffer.length() < pos) {
					buffer.append(' ');
				}
				buffer.append(name);

				if (arrow != null && i == arrow.from) {
					buffer.append(" -> ");
					arrow = null;
				}
			}
			lines.add(buffer.toString());
		}

		{
			final boolean[] froms = new boolean[names.size()];
			final boolean[] tos = new boolean[names.size()];
			for (int i = firstPositiveLevel; i < levels.size(); i++) {
				final Level level = levels.get(i);
				for (Arrow arrow : level.arrows) {
					froms[arrow.from] = true;
					tos[arrow.to] = true;
				}
			}

			buffer.setLength(0);
			for (int i = 0; i < names.size(); i++) {
				if (tos[i]) {
					final int pos = blockLeft[i];
					while (buffer.length() < pos) {
						buffer.append(' ');
					}
					buffer.append('^');
				}
				if (froms[i]) {
					final int pos = blockRight[i];
					while (buffer.length() < pos) {
						buffer.append(' ');
					}
					buffer.append('|');
				}
			}
			if (buffer.length() > 0) {
				lines.add(buffer.toString());
			}
		}

		for (int i = firstPositiveLevel; i < levels.size(); i++) {
			final Level level = levels.get(i);
			buffer.setLength(0);
			for (Arrow arrow : level.arrows) {
				int pos = blockRight[arrow.min()];
				while (buffer.length() < pos) {
					buffer.append(' ');
				}
				pos = blockLeft[arrow.max()];
				while (buffer.length() < pos) {
					buffer.append('-');
				}
			}
			lines.add(buffer.toString());
		}

		buffer.setLength(0);
		for (String line : lines) {
			if (buffer.length() > 0) {
				buffer.append('\n');
			}
			buffer.append(line);
		}
		return buffer.toString();
	}

	private record Arrow(int from, int to) {
		int length() {
			return to - from;
		}

		int min() {
			return Math.min(from, to);
		}

		int max() {
			return Math.max(from, to);
		}
	}

	private static final class Level {
		public final List<Arrow> arrows = new ArrayList<>();
		public final List<Integer> verticalLinesAt = new ArrayList<>();
	}
}
