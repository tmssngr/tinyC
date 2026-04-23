package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record ExprIntLiteral(int value, @Nullable Type type, @NotNull Location location) implements Expression {

	public static ExprIntLiteral autoType(int value, @NotNull Location location) {
		final Type type = Type.integerTypeFor(value);
		return new ExprIntLiteral(value, type, location);
	}

	@NotNull
	@Override
	public String toUserString() {
		return String.valueOf(value);
	}

	@NotNull
	@Override
	public Type typeNotNull() {
		return Objects.requireNonNull(type);
	}
}
