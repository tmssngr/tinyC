package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record ExprVarAccess(@NotNull String varName, @Nullable Type type, @Nullable Expression arrayIndex, @NotNull Location location) implements Expression {

	public static ExprVarAccess scalar(@NotNull String varName, @NotNull Location location) {
		return new ExprVarAccess(varName, null, null, location);
	}

	public static ExprVarAccess array(@NotNull String varName, @NotNull Expression index, @NotNull Location location) {
		return new ExprVarAccess(varName, null, index, location);
	}

	@NotNull
	@Override
	public String toUserString() {
		if (arrayIndex != null) {
			return varName + "[...]";
		}
		return varName;
	}

	@NotNull
	@Override
	public Type typeNotNull() {
		return Objects.requireNonNull(type);
	}
}
