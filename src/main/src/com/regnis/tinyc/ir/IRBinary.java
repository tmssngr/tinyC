package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRBinary(@NotNull IRVar target, @NotNull Op op, @NotNull IRVar left, @NotNull IRVar right, @NotNull Location location) implements IRInstruction {
	public IRBinary(@NotNull IRVar target, @NotNull Op op, @NotNull IRVar left, @NotNull IRVar right) {
		this(target, op, left, right, Location.DUMMY);
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
		return toString(false);
	}

	@Override
	public String toString(boolean comment) {
		final StringBuilder builder = new StringBuilder();
		builder.append(op.toString().toLowerCase());
		builder.append(" ");
		builder.append(target.toString(comment));
//		if (!Objects.equals(target, left)) {
			builder.append(", ");
			builder.append(left.toString(comment));
//		}
		builder.append(", ");
		builder.append(right.toString(comment));
		return builder.toString();
	}

	public enum Op {
		Add, Sub, Mul, Div, Mod,
		ShiftLeft, ShiftRight,
		And, Or, Xor,
	}
}
