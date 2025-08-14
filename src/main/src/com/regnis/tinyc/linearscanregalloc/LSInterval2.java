package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class LSInterval2 {

	public static int getFirstIntersection(LSInterval2 interval1, LSInterval2 interval2) {
		return LSRange2.getFirstIntersection(interval1.firstRange, interval2.firstRange);
	}

	private final List<LSUse2> uses = new ArrayList<>();
	private final IRVar var;

	private LSRange2 firstRange;
	private LSRange2 lastRange;
	private int register;
	private int registerHint = -1;

	public LSInterval2(@NotNull IRVar var) {
		this.var = var;
		this.register = -1;
	}

	public LSInterval2(int register) {
		Utils.assertTrue(register >= 0);
		this.register = register;
		var = null;
	}

	private LSInterval2(int register, @Nullable IRVar var) {
		this.register = register;
		this.var = var;
	}

	@Override
	public String toString() {
		final StringBuilder buffer = new StringBuilder();
		if (var != null) {
			buffer.append("'");
			buffer.append(var.name());
			buffer.append("'");
		}
		else {
			buffer.append("r");
			buffer.append(register);
		}

		if (firstRange != null) {
			buffer.append(": ");
			LSRange2 range = firstRange;
			do {
				range.toString(buffer);
				range = range.next();
				if (range != null) {
					buffer.append(", ");
				}
			}
			while (range != null);
		}
		return buffer.toString();
	}

	@Nullable
	public LSRange2 getFirstRange() {
		return firstRange;
	}

	public int getFrom() {
		return firstRange != null ? firstRange.from() : -1;
	}

	public int getTo() {
		return lastRange != null ? lastRange.to() : -1;
	}

	public void add(int from, int to) {
		Utils.assertTrue(from >= 0);
		Utils.assertTrue(from < to);

		if (firstRange != null) {
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

		firstRange = new LSRange2(from, to, firstRange);
		if (lastRange == null) {
			lastRange = firstRange;
		}
	}

	public void setWritePos(int pos) {
		Utils.assertTrue(pos >= 0);
		Utils.assertTrue(firstRange != null);
		Utils.assertTrue(pos < firstRange.to());
		firstRange.setFrom(pos);
	}

	@NotNull
	public IRVar var() {
		return var;
	}

	@NotNull
	public List<LSUse2> uses() {
		return Collections.unmodifiableList(uses);
	}

	@Nullable
	public IRVar varNullable() {
		return var;
	}

	public int register() {
		return register;
	}

	public void setRegister(int register) {
		this.register = register;
	}

	public int getRegisterHint() {
		return registerHint;
	}

	public void setRegisterHint(int registerHint) {
		this.registerHint = registerHint;
	}

	public boolean contains(int pos) {
		for (LSRange2 range = firstRange; range != null; range = range.next()) {
			if (pos >= range.from()) {
				return pos < range.to();
			}
		}
		return false;
	}

	public int getFreeUntil(int pos) {
		for (LSRange2 range = firstRange; range != null; range = range.next()) {
			if (pos < range.from()) {
				return range.from();
			}
			if (pos < range.to()) {
				return pos;
			}
		}
		return Integer.MAX_VALUE;
	}

	public LSInterval2 truncateAndSplit(int pos) {
		Utils.assertTrue(pos > getFrom());
		Utils.assertTrue(pos < getTo());
		final LSRange2 newRange = firstRange.split(pos);
		determineLastRange();

		final LSInterval2 newInterval = new LSInterval2(register, var);
		newInterval.firstRange = newRange;
		newInterval.determineLastRange();

		final Iterator<LSUse2> usesIt = uses.iterator();
		while (usesIt.hasNext()) {
			final LSUse2 use = usesIt.next();
			if (use.pos() < pos) {
				continue;
			}

			newInterval.uses.add(use);
			usesIt.remove();
		}

		return newInterval;
	}

	public void addReadUse(int pos) {
		Utils.assertTrue(pos >= 0);
		if (uses.size() > 0) {
			final LSUse2 first = uses.getFirst();
			if (first.pos() == pos) {
				Utils.assertTrue(first.write());
				return;
			}
			Utils.assertTrue(pos < first.pos());
		}
		uses.addFirst(new LSUse2(pos, false, true));
	}

	public void addWritePos(int pos) {
		Utils.assertTrue(pos >= 0);
		if (uses.size() > 0) {
			Utils.assertTrue(pos < uses.getFirst().pos());
		}
		uses.addFirst(new LSUse2(pos, true, true));
	}

	public int getUsedNext(int i, int value) {
		// todo
		return -1;
	}

	private void determineLastRange() {
		for (LSRange2 range = firstRange; range != null; range = range.next()) {
			lastRange = range;
		}
	}
}
