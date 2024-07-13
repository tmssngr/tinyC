package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record ExprBoolLiteral(boolean value, @NotNull Location location) implements Expression {
	@NotNull
	@Override
	public Type typeNotNull() {
		return Objects.requireNonNull(Type.BOOL);
	}

	@NotNull
	@Override
	public String toUserString() {
		return String.valueOf(value);
	}
}
