package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record ExprArrayAccess(@NotNull String varName, @Nullable Type type, @NotNull Expression index, @NotNull Location location) implements Expression {
	public ExprArrayAccess(@NotNull String varName, @NotNull Expression index, @NotNull Location location) {
		this(varName, null, index, location);
	}

	@NotNull
	@Override
	public Type typeNotNull() {
		return Objects.requireNonNull(type);
	}
}
