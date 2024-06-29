package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;
import com.regnis.tinyc.types.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record ExprCast(@NotNull Expression expression, @NotNull Type expressionType, @NotNull Type type, @NotNull Location location) implements Expression {

	@Override
	public String toString() {
		return "(" + expressionType + " -> " + type + ")";
	}

	@NotNull
	@Override
	public Type typeNotNull() {
		return type;
	}

	@NotNull
	@Override
	public Expression determineType(@NotNull VariableTypes types) {
		return this;
	}
}
