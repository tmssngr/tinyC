package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;
import com.regnis.tinyc.types.*;

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

	@Override
	public String toString() {
		return String.valueOf(value);
	}

	@NotNull
	@Override
	public Type typeNotNull() {
		return Objects.requireNonNull(type);
	}

	@NotNull
	@Override
	public Expression determineType(@NotNull VariableTypes types) {
		return this;
	}
}
