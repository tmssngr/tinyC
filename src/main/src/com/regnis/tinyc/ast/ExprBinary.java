package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record ExprBinary(@NotNull Op op, @Nullable Type type, @NotNull Expression left, @NotNull Expression right, @NotNull Location location) implements Expression {
	public ExprBinary {
		if (type != null) {
			final Type leftType = left.typeNotNull();
			final Type rightType = right.typeNotNull();
			if (op.kind == OpKind.Relational) {
				Utils.assertTrue(Objects.equals(leftType, rightType), leftType + " vs. " + rightType);
				Utils.assertTrue(Objects.equals(type, Type.BOOL), String.valueOf(type));
			}
			else {
				Utils.assertTrue(Objects.equals(type, leftType), type + " vs. " + leftType);
				Utils.assertTrue(Objects.equals(type, rightType), type + " vs. " + rightType);
			}
		}
	}

	public ExprBinary(@NotNull Op op, @NotNull Expression left, @NotNull Expression right, @NotNull Location location) {
		this(op, null, left, right, location);
	}

	@NotNull
	@Override
	public String toUserString() {
		return left.toUserString() + " " + op.s + " " + right.toUserString();
	}

	@NotNull
	@Override
	public Type typeNotNull() {
		return Objects.requireNonNull(type);
	}

	public enum OpKind {
		Arithmetic, Relational, Logic, Assign
	}

	public enum Op {
		Add("+", OpKind.Arithmetic), Sub("-", OpKind.Arithmetic), Multiply("*", OpKind.Arithmetic), Divide("/", OpKind.Arithmetic), Mod("%", OpKind.Arithmetic), ShiftLeft("<<", OpKind.Arithmetic), ShiftRight(">>", OpKind.Arithmetic),
		And("&", OpKind.Arithmetic), Or("|", OpKind.Arithmetic), Xor("^", OpKind.Arithmetic),
		Lt("<", OpKind.Relational), LtEq("<=", OpKind.Relational), Equals("==", OpKind.Relational), NotEquals("!=", OpKind.Relational), GtEq(">=", OpKind.Relational), Gt(">", OpKind.Relational),
		AndLog("&&", OpKind.Logic), OrLog("||", OpKind.Logic),
		Assign("=", OpKind.Assign);

		private final String s;
		public final OpKind kind;

		Op(String s, OpKind kind) {
			this.s = s;
			this.kind = kind;
		}

		@Override
		public String toString() {
			return s;
		}
	}
}
