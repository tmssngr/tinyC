package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record ExprCast(@NotNull Expression expression, @NotNull Type expressionType, @NotNull Type type, @NotNull Location location) implements Expression {

	@NotNull
	@Override
	public String toUserString() {
		return "(" + expressionType + " -> " + type + ")";
	}

	@NotNull
	@Override
	public Type typeNotNull() {
		return type;
	}
}
