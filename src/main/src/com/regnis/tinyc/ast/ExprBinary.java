package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;
import com.regnis.tinyc.types.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record ExprBinary(@NotNull Op op, @Nullable Type type, @NotNull Expression left, @NotNull Expression right, @NotNull Location location) implements Expression {
	public ExprBinary(@NotNull Op op, @NotNull Expression left, @NotNull Expression right, @NotNull Location location) {
		this(op, null, left, right, location);
	}

	@Override
	public String toString() {
		return left + " " + op.s + " " + right;
	}

	@NotNull
	@Override
	public Type typeNotNull() {
		return Objects.requireNonNull(type);
	}

	@NotNull
	@Override
	public Expression determineType(@NotNull VariableTypes types) {
		Expression left = this.left.determineType(types);
		Expression right = this.right.determineType(types);
		final Type leftType = left.typeNotNull();
		final Type rightType = right.typeNotNull();

		Type type;
		if (op == Op.Add || op == Op.Sub || op == Op.Multiply || op == Op.Divide) {
			type = leftType;
			if (leftType != rightType) {
				if (leftType == Type.U8) {
					left = new ExprCast(left, leftType, rightType, left.location());
					type = rightType;
				}
				else {
					right = new ExprCast(right, rightType, leftType, right.location());
				}
			}
		}
		else {
			type = Type.U8;
			if (leftType != rightType) {
				if (leftType == Type.U8) {
					left = new ExprCast(left, leftType, rightType, left.location());
				}
				else {
					right = new ExprCast(right, rightType, leftType, right.location());
				}
			}
		}
		return new ExprBinary(op, type, left, right, location);
	}

	public Op op() {
		return op;
	}

	public Expression left() {
		return left;
	}

	public Expression right() {
		return right;
	}

	public enum Op {
		Add("+"), Sub("-"), Multiply("*"), Divide("/"),
		Lt("<"), LtEq("<="), Equals("=="), NotEquals("!="), GtEq(">="), Gt(">");

		private final String s;

		Op(String s) {
			this.s = s;
		}
	}
}
