package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record ExprIntLiteral(int value, @Nullable Type type, @NotNull Location location) implements Expression {
	public ExprIntLiteral(int value, @NotNull Location location) {
		this(value, value >= 0 && value < 256
				? Type.U8
				: Type.I16, location);
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
