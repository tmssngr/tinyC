package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record ExprCast(@NotNull String typeString, @NotNull Expression expression, @Nullable Type type, @NotNull Location location) implements Expression {

	@NotNull
	public static ExprCast cast(@NotNull String typeString, @NotNull Expression expression, @NotNull Location location) {
		return new ExprCast(typeString, expression, null, location);
	}

	@NotNull
	public static ExprCast autocast(@NotNull Expression expression, @NotNull Type type) {
		return new ExprCast("autocast", expression, type, expression.location());
	}

	@NotNull
	@Override
	public String toUserString() {
		return "(" + typeString + ")";
	}

	@NotNull
	@Override
	public Type typeNotNull() {
		return Objects.requireNonNull(type);
	}
}
