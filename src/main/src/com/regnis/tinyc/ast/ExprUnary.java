package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record ExprUnary(@NotNull Op op, @NotNull Expression expression, @Nullable Type type, @NotNull Location location) implements Expression {

	public ExprUnary(@NotNull Op op, @NotNull Expression expression, @NotNull Location location) {
		this(op, expression, null, location);
	}

	@NotNull
	@Override
	public Type typeNotNull() {
		return Objects.requireNonNull(type);
	}

	public enum Op {
		Deref("*");

		private final String s;

		Op(String s) {
			this.s = s;
		}

		@Override
		public String toString() {
			return s;
		}
	}
}
