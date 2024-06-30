package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

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

	public enum Op {
		Add("+"), Sub("-"), Multiply("*"), Divide("/"),
		Lt("<"), LtEq("<="), Equals("=="), NotEquals("!="), GtEq(">="), Gt(">");

		private final String s;

		Op(String s) {
			this.s = s;
		}
	}
}
