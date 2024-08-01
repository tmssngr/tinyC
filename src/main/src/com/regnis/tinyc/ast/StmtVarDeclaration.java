package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record StmtVarDeclaration(@NotNull String typeString, @NotNull String varName, int index, @Nullable VariableScope scope, @Nullable Type type, @Nullable Expression expression, @NotNull Location location) implements StmtDeclaration {

	public StmtVarDeclaration(@NotNull String typeString, @NotNull String varName, @Nullable Expression expression, @NotNull Location location) {
		this(typeString, varName, 0, null, null, expression, location);
	}

	@Override
	public String toString() {
		return typeString + " " + varName + " = " + expression;
	}

	@NotNull
	public Type type() {
		return Objects.requireNonNull(type);
	}

	@NotNull
	public VariableScope scope() {
		return Objects.requireNonNull(scope);
	}
}
