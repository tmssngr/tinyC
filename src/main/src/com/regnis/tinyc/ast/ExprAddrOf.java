package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record ExprAddrOf(@NotNull String varName, @Nullable Type type, @NotNull Location location) implements Expression {

	public ExprAddrOf(String varName, Location location) {
		this(varName, null, location);
	}

	@NotNull
	@Override
	public Type typeNotNull() {
		return Objects.requireNonNull(type);
	}
}
