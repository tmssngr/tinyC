package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRBinary(@NotNull IRVar target, @NotNull Op op, @NotNull IRVar left, @NotNull IRValue right, @NotNull Location location) implements IRInstruction {
	public IRBinary(@NotNull IRVar target, @NotNull Op op, @NotNull IRVar left, @NotNull IRVar right, @NotNull Location location) {
		this(target, op, left, new IRValue(right), location);
	}

	public IRBinary(@NotNull IRVar target, @NotNull Op op, @NotNull IRVar left, int rightValue, @NotNull Location location) {
		this(target, op, left, new IRValue(rightValue, left.type()), location);
	}

	public IRBinary {
		Utils.assertTrue(Objects.equals(target.type(), left.type()), target.type() + " vs. " + left.type());
		if (op == Op.Add && target.type().isPointer()) {
			Utils.assertTrue(right.type().isInt());
		}
		else {
			Utils.assertTrue(Objects.equals(target.type(), right.type()), target.type() + " vs. " + right.type());
		}
	}

	@NotNull
	@Override
	public String toString() {
		return op.toString().toLowerCase() + " " + target + ", " + left + ", " + right;
	}

	public enum Op {
		Add, Sub, Mul, Div, Mod,
		ShiftLeft, ShiftRight,
		And, Or, Xor,
	}
}
