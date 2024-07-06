package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record ExprDeref(@NotNull Expression expression, @Nullable Type type, @NotNull Location location) implements Expression {

	public ExprDeref(@NotNull Expression expression, @NotNull Location location) {
		this(expression, null, location);
	}

	@NotNull
	@Override
	public Type typeNotNull() {
		return Objects.requireNonNull(type);
	}
}
