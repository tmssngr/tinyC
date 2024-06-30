package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record ExprFuncCall(@NotNull String name, @Nullable Type type, @NotNull List<Expression> argExpressions, @NotNull Location location) implements Expression {

	public ExprFuncCall(@NotNull String name, @NotNull List<Expression> argExpressions, @NotNull Location location) {
		this(name, null, argExpressions, location);
	}

	@Override
	public String toString() {
		return name + "(" + argExpressions + ")";
	}

	@NotNull
	@Override
	public Type typeNotNull() {
		return Objects.requireNonNull(type);
	}
}
