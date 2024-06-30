package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record ExprVarRead(@NotNull String varName, @Nullable Type type, @NotNull Location location) implements Expression {

	public ExprVarRead(String varName, Location location) {
		this(varName, null, location);
	}

	@Override
	public String toString() {
		return varName;
	}

	@NotNull
	@Override
	public Type typeNotNull() {
		return Objects.requireNonNull(type);
	}

	@NotNull
	@Override
	public Expression determineType(@NotNull VariableTypes types) {
		final Type type = types.getVariableType(varName);
		if (type == null) {
			throw new SyntaxException("Unknown variable '" + varName + "'", location);
		}
		return new ExprVarRead(varName, type, location);
	}
}
