package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record ExprStringLiteral(@NotNull String text, @NotNull Location location) implements Expression {

	@NotNull
	@Override
	public Type typeNotNull() {
		return Type.POINTER_U8;
	}

	@NotNull
	@Override
	public String toUserString() {
		return "string";
	}
}
