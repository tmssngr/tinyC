package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record ExprVarAccess(@NotNull String varName, @Nullable Type type, @NotNull Location location) implements Expression {

	public ExprVarAccess(String varName, Location location) {
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
}
