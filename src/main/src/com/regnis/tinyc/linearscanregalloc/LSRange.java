package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class LSRange {

	public static int getFirstIntersection(@NotNull List<LSRange> ranges1, @NotNull List<LSRange> ranges2) {
		if (ranges1.isEmpty() || ranges2.isEmpty()) {
			return -1;
		}

		int index1 = 0;
		int index2 = 0;
		LSRange range = ranges1.get(index1);
		int from1 = range.from;
		int to1 = range.to;
		range = ranges2.get(index2);
		int from2 = range.from;
		int to2 = range.to;
		while (true) {
			if (from1 == from2) {
				return from1;
			}

			if (from1 < from2) {
				if (to1 > from2) {
					return from2;
				}

				index1++;
				if (index1 == ranges1.size()) {
					return -1;
				}

				range = ranges1.get(index1);
				from1 = range.from;
				to1 = range.to;
			}
			else {
				if (to2 > from1) {
					return from1;
				}

				index2++;
				if (index2 == ranges2.size()) {
					return -1;
				}

				range = ranges2.get(index2);
				from2 = range.from;
				to2 = range.to;
			}
		}
	}

	public static Pair<List<LSRange>, List<LSRange>> split(int pos, List<LSRange> ranges) {
		final List<LSRange> before = new ArrayList<>();
		final List<LSRange> after = new ArrayList<>();
		for (LSRange range : ranges) {
			if (pos >= range.to) {
				before.add(range);
				continue;
			}

			if (pos <= range.from) {
				after.add(range);
				continue;
			}

			before.add(new LSRange(range.from, pos));
			after.add(new LSRange(pos, range.to));
		}
		return new Pair<>(before, after);
	}

	/**
	 * Return -1 if not free at pos; Integer.MAX if after last range
	 */
	public static int getFreeUntil(int pos, List<LSRange> ranges) {
		for (LSRange range : ranges) {
			final int from = range.from;
			if (from > pos) {
				return from;
			}

			if (range.to > pos) {
				return -1;
			}
		}
		return Integer.MAX_VALUE;
	}

	public static boolean contains(int pos, List<LSRange> ranges) {
		for (LSRange range : ranges) {
			if (range.contains(pos, false)) {
				return true;
			}
		}
		return false;
	}

	private final int from;

	private int to;

	public LSRange(int from) {
		this(from, from + 1);
	}

	public LSRange(int from, int to) {
		Utils.assertTrue(to > from);
		this.from = from;
		this.to = to;
	}

	@Override
	public String toString() {
		return "[" + from + "-" + to + ">";
	}

	public int from() {
		return from;
	}

	public int to() {
		return to;
	}

	public void extend(int index) {
		Utils.assertTrue(index >= to);
		to = index;
	}

	public boolean contains(int index, boolean allowTo) {
		if (index < from) {
			return false;
		}
		if (index > to) {
			return false;
		}
		if (index < to) {
			return true;
		}
		return allowTo;
	}
}
