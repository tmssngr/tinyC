package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
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

	private LSRange latestRange;
	private int register;
	private int registerHint = -1;

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
			Utils.assertTrue(LSRange.contains(use.pos(), ranges));
		}
		this.var = var;
		this.register = register;
		this.ranges.addAll(ranges);
		this.latestRange = ranges.getLast();
		this.uses.addAll(uses);
	}

	@Override
	public String toString() {
		return getName() + " " + ranges;
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
	public String rangesAsString(int max, Collection<LSIntervalFactory.Indices> blockStartIndices) {
		final StringBuilder buffer = new StringBuilder();
		debugPositions(max, buffer);

		for (LSIntervalFactory.Indices index : blockStartIndices) {
			buffer.setCharAt(index.start(), '|');
		}

		for (LSRange range : ranges) {
			for (int i = Math.max(range.from(), 0); i < range.to(); i++) {
				buffer.setCharAt(i, '=');
			}
		}
		for (LSUse use : uses) {
			buffer.setCharAt(use.pos(), use.asChar());
		}

		buffer.append("\t");
		buffer.append(ranges);
		buffer.append("; ");
		buffer.append(uses);
		return buffer.toString();
	}

	public void addUse(int index) {
		Utils.assertTrue(latestRange != null);
		Utils.assertTrue(latestRange.contains(index, false));

		if (isFixed()) {
			return;
		}

		if (uses.size() > 0) {
			final LSUse lastUse = uses.getLast();
			Utils.assertTrue(index > lastUse.pos());
		}

		uses.add(new LSUse(index));
	}

	public void extendRange(int index) {
		if (latestRange == null) {
			Utils.assertTrue(var != null);
			Utils.assertTrue(var.scope() == VariableScope.global);
			startNewRange(index - 1);
		}
		Objects.requireNonNull(latestRange).extend(index);
	}

	public void extendRangeMaybeCreate(int index) {
		if (latestRange != null) {
			latestRange.extend(index + 1);
		}
		else {
			startNewRange(index);
		}
	}

	public void startNewRange(int index) {
		if (latestRange != null) {
			Utils.assertTrue(index >= latestRange.to());
		}
		latestRange = new LSRange(index);
		ranges.add(latestRange);
	}

	public void startNewRangeIfSmaller(int index) {
		if (getTo() <= index) {
			startNewRange(index);
		}
	}

	public int getFrom() {
		return ranges.getFirst().from();
	}

	public int getTo() {
		return latestRange != null ? latestRange.to() : -1;
	}

	public boolean contains(int pos) {
		return LSRange.contains(pos, ranges);
	}

	public void setRegister(int register) {
		this.register = register;
	}

	@NotNull
	public LSInterval truncateAndSplit(int pos) {
		final Pair<List<LSRange>, List<LSRange>> split = LSRange.split(pos, ranges);
		final List<LSRange> firstRanges = split.first();
		Utils.assertTrue(firstRanges.size() > 0);
		final List<LSRange> lastRanges = split.second();
		Utils.assertTrue(lastRanges.size() > 0);

		this.ranges.clear();
		this.ranges.addAll(firstRanges);
		this.latestRange = firstRanges.getLast();

		final List<LSUse> subUses = new ArrayList<>();
		for (LSUse use : uses) {
			final int usePos = use.pos();
			if (usePos >= pos) {
				subUses.add(use);
			}
		}

		for (int i = 0; i < subUses.size(); i++) {
			this.uses.removeLast();
		}

		return new LSInterval(var, register, lastRanges, subUses);
	}

	public int getFreeUntil(int pos) {
		Utils.assertTrue(isFixed());
		return LSRange.getFreeUntil(pos, ranges);
	}

	public int getUsedNext(int pos, int notUsedValue) {
		Utils.assertTrue(var != null);
		for (LSUse use : uses) {
			final int usePos = use.pos();
			if (usePos >= pos) {
				return usePos;
			}
		}
		return notUsedValue;
	}

	public int getRegisterHint() {
		return registerHint;
	}

	public void setRegisterHint(int registerHint) {
		this.registerHint = registerHint;
	}

	private boolean isFixed() {
		return var == null;
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
