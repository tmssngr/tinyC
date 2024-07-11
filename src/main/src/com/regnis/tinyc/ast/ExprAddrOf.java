package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record ExprAddrOf(@NotNull String varName, @Nullable Type type, @Nullable Expression arrayIndex, @NotNull Location location) implements Expression {

	public ExprAddrOf(@NotNull String varName, @Nullable Expression arrayIndex, @NotNull Location location) {
		this(varName, null, arrayIndex, location);
	}

	@NotNull
	@Override
	public Type typeNotNull() {
		return Objects.requireNonNull(type);
	}
}
