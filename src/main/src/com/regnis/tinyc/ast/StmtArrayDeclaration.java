package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record StmtArrayDeclaration(@NotNull String typeString, @Nullable Type type, @NotNull String varName, int size, @NotNull Location location) implements StmtDeclaration {
	public StmtArrayDeclaration {
		Utils.assertTrue(size > 0);
	}

	public StmtArrayDeclaration(@NotNull String typeString, @NotNull String varName, int size, @NotNull Location location) {
		this(typeString, null, varName, size, location);
	}

	@Override
	public String toString() {
		return typeString + " " + varName + "[" + size + "]";
	}

	@NotNull
	public Type type() {
		return Objects.requireNonNull(type);
	}
}