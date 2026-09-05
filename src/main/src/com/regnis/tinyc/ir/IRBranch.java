package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRBranch(@NotNull IRCompare.Op op, @NotNull IRVar left, @NotNull IRValue right, @NotNull String target, @NotNull String nextLabel, @NotNull Location location) implements IRInstruction {
	public IRBranch(@NotNull IRCompare.Op op, @NotNull IRVar left, @NotNull IRValue right, @NotNull String target,
	                @NotNull String nextLabel) {
		this(op, left, right, target, nextLabel, Location.DUMMY);
	}

	public IRBranch(@NotNull IRCompare.Op op, @NotNull IRVar left, @NotNull IRVar right, @NotNull String target, @NotNull String nextLabel, @NotNull Location location) {
		this(op, left, new IRValue(right), target, nextLabel, location);
	}

	public IRBranch(@NotNull IRCompare.Op op, @NotNull IRVar left, int rightValue, @NotNull String target, @NotNull String nextLabel, @NotNull Location location) {
		this(op, left, new IRValue(rightValue, left.type()), target, nextLabel, location);
	}

	public IRBranch(@NotNull IRCompare.Op op, @NotNull IRVar left, @NotNull IRVar right, @NotNull String target, @NotNull String nextLabel) {
		this(op, left, right, target, nextLabel, Location.DUMMY);
	}

	public IRBranch(@NotNull IRVar var, boolean jumpOnTrue, @NotNull String target, @NotNull String nextLabel) {
		this(var, jumpOnTrue, target, nextLabel, Location.DUMMY);
	}

	public IRBranch(@NotNull IRVar var, boolean jumpOnTrue, @NotNull String target, @NotNull String nextLabel, Location location) {
		this(jumpOnTrue ? IRCompare.Op.NotEquals : IRCompare.Op.Equals, var, new IRValue(0, Type.BOOL), target, nextLabel, location);
	}

	public IRBranch {
		Utils.assertTrue(Objects.equals(left.type(), right.type()), left.type() + " vs. " + right.type());
		Utils.assertTrue(target.length() > 0);
	}

	@NotNull
	@Override
	public String toString() {
		return toString(false);
	}

	@Override
	public String toString(boolean comment) {
		final StringBuilder buffer = new StringBuilder();
		buffer.append("branch ");
		buffer.append(left.toString(comment));
		buffer.append(" ");
		buffer.append(op.toString().toLowerCase());
		buffer.append(" ");
		buffer.append(right.toString(comment));
		buffer.append(": ");
		buffer.append(target);
		if (nextLabel.length() > 0) {
			buffer.append(", ");
			buffer.append(nextLabel);
		}
		return buffer.toString();
	}
}
