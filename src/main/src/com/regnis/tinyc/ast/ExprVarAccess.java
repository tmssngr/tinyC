package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record ExprVarAccess(@NotNull String varName, int index, @Nullable VariableScope scope, @Nullable Type type, @NotNull Location location) implements Expression {

	public ExprVarAccess(@NotNull String varName, @NotNull Location location) {
		this(varName, 0, null, null, location);
	}

	@NotNull
	@Override
	public String toUserString() {
		return varName;
	}

	@NotNull
	@Override
	public Type typeNotNull() {
		return Objects.requireNonNull(type);
	}

	@NotNull
	public VariableScope scope() {
		return Objects.requireNonNull(scope);
	}
}
