package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record ExprMemberAccess(@NotNull Expression expression, @NotNull String member, @Nullable Type type, @NotNull Location location) implements Expression {
	@NotNull
	@Override
	public String toUserString() {
		return "." + member;
	}

	@NotNull
	@Override
	public Type typeNotNull() {
		return Objects.requireNonNull(type);
	}
}
