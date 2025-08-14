package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class LSRange2 {

	public static int getFirstIntersection(LSRange2 range1, LSRange2 range2) {
		if (range1 == null || range2 == null) {
			return -1;
		}

		while (range1.to() <= range2.from()) {
			range1 = range1.next();
			if (range1 == null) {
				return -1;
			}
		}

		while (range2.to() <= range1.from()) {
			range2 = range2.next();
			if (range2 == null) {
				return -1;
			}
		}

		return Math.max(range1.from(), range2.from());
	}

	private int from;
	private int to;
	@Nullable private LSRange2 next;

	public LSRange2(int from, int to, @Nullable LSRange2 next) {
		Utils.assertTrue(from < to);
		this.from = from;
		this.to = to;
		this.next = next;
	}

	@Override
	public String toString() {
		final StringBuilder buffer = new StringBuilder();
		toString(buffer);
		return buffer.toString();
	}

	public void toString(StringBuilder buffer) {
		buffer.append("[");
		buffer.append(from);
		buffer.append("-");
		buffer.append(to);
		buffer.append(">");
	}

	public int from() {
		return from;
	}

	public int to() {
		return to;
	}

	@Nullable
	public LSRange2 next() {
		return next;
	}

	public void setFrom(int from) {
		Utils.assertTrue(from >= 0);
		Utils.assertTrue(from < this.to);
		this.from = from;
	}

	public LSRange2 split(int pos) {
		return split(this, pos);
	}

	private static LSRange2 split(LSRange2 range, int pos) {
		LSRange2 prev = null;
		while (range != null) {
			if (pos <= range.from()) {
				Utils.assertTrue(prev != null);
				prev.next = null;
				return range;
			}

			final int to = range.to();
			final LSRange2 next = range.next();
			if (pos < to) {
				range.to = pos;
				range.next = null;
				return new LSRange2(pos, to, next);
			}

			prev = range;
			range = next;
		}
		throw new IllegalStateException("");
	}
}
