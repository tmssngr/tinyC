package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record StmtVarDeclaration(@NotNull String typeString, @Nullable Type type, @NotNull String varName, @NotNull Expression expression, @NotNull Location location) implements Statement {

	public StmtVarDeclaration(@NotNull String typeString, @NotNull String varName, @NotNull Expression expression, @NotNull Location location) {
		this(typeString, null, varName, expression, location);
	}

	@Override
	public String toString() {
		return typeString + " " + varName + " = " + expression;
	}

	@NotNull
	public Type type() {
		return Objects.requireNonNull(type);
	}
}