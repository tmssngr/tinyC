package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class LSInterval {

	public static int getFirstIntersection(LSInterval interval1, LSInterval interval2) {
		return LSRange.getFirstIntersection(interval1.ranges, interval2.ranges);
	}

	static LSInterval testVar(@NotNull IRVar var, @NotNull List<LSRange> ranges, @NotNull List<LSUse> uses) {
		return testVar(var, -1, ranges, uses);
	}

	static LSInterval testVar(@NotNull IRVar var, int register, @NotNull List<LSRange> ranges, @NotNull List<LSUse> uses) {
		return new LSInterval(var, register, ranges, uses);
	}

	static LSInterval testFixed(int reg, @NotNull List<LSRange> ranges) {
		return new LSInterval(null, reg, ranges, List.of());
	}

	private final List<LSRange> ranges = new ArrayList<>();
	private final List<LSUse> uses = new ArrayList<>();
	private final IRVar var;

	private LSRange lastRange;
	private int register;
	private int registerHint = -1;
	private LSInterval parentSplit;
	private LSInterval nextSplit;

	public LSInterval(@NotNull IRVar var) {
		this.var = var;
		this.register = -1;
	}

	public LSInterval(int register) {
		Utils.assertTrue(register >= 0);
		this.register = register;
		var = null;
	}

	private LSInterval(@Nullable IRVar var, int register, @NotNull List<LSRange> ranges, @NotNull List<LSUse> uses) {
		Utils.assertTrue(ranges.size() > 0);
		int allowRangeFrom = -1; // argument-ranges can start at -1
		for (LSRange range : ranges) {
			Utils.assertTrue(range.from() >= allowRangeFrom);
			allowRangeFrom = range.to();
		}
		for (LSUse use : uses) {
			Utils.assertTrue(LSRange.contains(use.pos(), ranges, true));
		}
		this.var = var;
		this.register = register;
		this.ranges.addAll(ranges);
		this.lastRange = ranges.getLast();
		this.uses.addAll(uses);
	}

	@Override
	public String toString() {
		return getName() + " " + ranges;
	}

	public String toDebugString() {
		final StringBuilder buffer = new StringBuilder();
		buffer.append(var());
		buffer.append("' ");
		buffer.append(getFrom());
		buffer.append("...");
		buffer.append(getTo());
		if (registerHint >= 0) {
			buffer.append(" (rh=");
			buffer.append(registerHint);
			buffer.append(")");
		}
		return buffer.toString();
	}

	@NotNull
	public String getName() {
		final StringBuilder buffer = new StringBuilder();
		if (var != null) {
			buffer.append(var);
			if (register >= 0) {
				buffer.append("(r");
				buffer.append(register);
				buffer.append(")");
			}
		}
		else {
			buffer.append("r");
			buffer.append(register);
		}
		return buffer.toString();
	}

	@NotNull
	public IRVar var() {
		return var;
	}

	@Nullable
	public IRVar varNullable() {
		return var;
	}

	public int register() {
		return register;
	}

	@NotNull
	public List<LSRange> ranges() {
		return Collections.unmodifiableList(ranges);
	}

	@NotNull
	public List<LSUse> uses() {
		return Collections.unmodifiableList(uses);
	}

	@NotNull
	public String rangesAsString(int max, Collection<LSIntervalFactory.Indices> blockIndices) {
		for (LSIntervalFactory.Indices indices : blockIndices) {
			max = Math.max(max, indices.end() + 1);
		}
		for (LSRange range : ranges) {
			max = Math.max(max, range.to());
		}

		final StringBuilder buffer = new StringBuilder();
		debugPositions(max, buffer);

		for (LSIntervalFactory.Indices index : blockIndices) {
			buffer.setCharAt(index.start(), '|');
		}

		for (LSRange range : ranges) {
			final char ch = var != null ? '=' : '#';
			for (int i = Math.max(range.from(), 0); i < range.to(); i++) {
				buffer.setCharAt(i, ch);
			}
		}
		for (LSUse use : uses) {
			buffer.setCharAt(use.pos(), use.asChar());
		}

		buffer.append("\t");
		buffer.append(ranges);
		if (uses.size() > 0) {
			buffer.append("; ");
			buffer.append(uses);
		}
		return buffer.toString();
	}

	public void add(int from, int to) {
		Utils.assertTrue(from >= 0);
		Utils.assertTrue(from < to);

		if (ranges.size() > 0) {
			final LSRange firstRange = ranges.getFirst();
			if (firstRange.from() == from) {
				Utils.assertTrue(to <= firstRange.to());
				return;
			}

			Utils.assertTrue(to <= firstRange.from());
			if (to == firstRange.from()) {
				firstRange.setFrom(from);
				return;
			}
		}

		final LSRange range = new LSRange(from, to);
		ranges.addFirst(range);
		if (lastRange == null) {
			lastRange = range;
		}
	}

	public int getFrom() {
		if (ranges.isEmpty()) {
			return -1;
		}
		return ranges.getFirst().from();
	}

	public int getTo() {
		return lastRange != null ? lastRange.to() : -1;
	}

	public boolean contains(int pos) {
		return LSRange.contains(pos, ranges, false);
	}

	public void setRegister(int register) {
		this.register = register;
	}

	@NotNull
	public LSInterval truncateAndSplit(int pos) {
		Utils.assertTrue(var != null);
		Utils.assertTrue(nextSplit == null);

		final Pair<List<LSRange>, List<LSRange>> split = LSRange.split(pos, ranges);
		final List<LSRange> firstRanges = split.first();
		Utils.assertTrue(firstRanges.size() > 0);
		final List<LSRange> lastRanges = split.second();
		Utils.assertTrue(lastRanges.size() > 0);

		final int actualSplitPos = lastRanges.getFirst().from();

		this.ranges.clear();
		this.ranges.addAll(firstRanges);
		this.lastRange = firstRanges.getLast();

		final List<LSUse> subUses = new ArrayList<>();
		for (LSUse use : uses) {
			final int usePos = use.pos();
			if (usePos >= actualSplitPos) {
				subUses.add(use);
			}
		}

		for (int i = 0; i < subUses.size(); i++) {
			this.uses.removeLast();
		}

		final LSInterval splitOffInterval = new LSInterval(var, -1, lastRanges, subUses);
		splitOffInterval.parentSplit = this;
		nextSplit = splitOffInterval;
		return splitOffInterval;
	}

	public int getFreeUntil(int pos) {
		Utils.assertTrue(isFixed());
		return LSRange.getFreeUntil(pos, ranges);
	}

	@Nullable
	public LSUse getUsedNext(int pos) {
		Utils.assertTrue(var != null);
		for (LSUse use : uses) {
			final int usePos = use.pos();
			if (usePos >= pos) {
				return use;
			}
		}
		return null;
	}

	public void truncateFirstRangeTo(int pos) {
		Utils.assertTrue(pos >= 0);
		Utils.assertTrue(ranges.size() > 0);
		final LSRange firstRange = ranges.getFirst();
		Utils.assertTrue(pos < firstRange.to());
		firstRange.setFrom(pos);
	}

	public void addReadUse(int pos) {
		Utils.assertTrue(pos >= 0);
		if (var == null) {
			return;
		}
		if (uses.size() > 0) {
			final LSUse first = uses.getFirst();
			if (first.pos() == pos) {
				Utils.assertTrue(first.write());
				return;
			}
			Utils.assertTrue(pos < first.pos());
		}
		uses.addFirst(new LSUse(pos, false));
	}

	public void addWritePos(int pos) {
		Utils.assertTrue(pos >= 0);
		if (var == null) {
			return;
		}
		if (uses.size() > 0) {
			Utils.assertTrue(pos < uses.getFirst().pos());
		}
		uses.addFirst(new LSUse(pos, true));
	}

	public int getRegisterHint() {
		return registerHint;
	}

	public void setRegisterHint(int registerHint) {
		this.registerHint = registerHint;
	}

	@Nullable
	public LSUse getUseBefore(int end) {
		LSUse prev = null;
		for (LSUse use : uses) {
			if (use.pos() >= end) {
				break;
			}
			prev = use;
		}
		return prev;
	}

	@Nullable
	public LSInterval getSubInterval(int pos, boolean read, boolean write) {
		return getSubInterval(this, pos, read, write);
	}

	@Nullable
	public Pair<IRVar, IRVar> getTransitionAt(int pos) {
		Utils.assertTrue(var != null);

		LSInterval prev = this;
		for (LSInterval next = nextSplit; next != null; prev = next, next = prev.nextSplit) {
			final int nextFrom = next.getFrom();
			if (prev.getTo() < nextFrom) {
				continue;
			}
			if (pos < nextFrom) {
				break;
			}
			if (pos == nextFrom) {
				final IRVar from = prev.register >= 0 ? prev.var().asRegister(prev.register) : prev.var();
				final IRVar to = next.register >= 0 ? next.var().asRegister(next.register) : next.var();
				return new Pair<>(from, to);
			}
		}
		return null;
	}

	@Nullable
	public LSInterval getNextSplit() {
		return nextSplit;
	}

	public int getFreeUntil(LSInterval interval) {
		return LSRange.getIntersectionFreeUntil(ranges, interval.ranges);
	}

	private boolean isFixed() {
		return var == null;
	}

	@Nullable
	private static LSInterval getSubInterval(LSInterval interval, int pos, boolean read, boolean write) {
		for (; interval != null; interval = interval.nextSplit) {
			final int from = interval.getFrom();
			if (from == pos && write) {
				return interval;
			}
			if (pos <= from) {
				break;
			}

			final int to = interval.getTo();
			if (pos < to) {
				return interval;
			}

			if (read && pos == to) {
				return interval;
			}
		}
		return null;
	}

	private static void debugPositions(int max, StringBuilder buffer) {
		for (int i = 0; i <= max; i++) {
			buffer.append(i % 10 == 0
					              ? ':'
					              : i % 2 == 0
							              ? '.'
							              : ' ');
		}
	}
}
