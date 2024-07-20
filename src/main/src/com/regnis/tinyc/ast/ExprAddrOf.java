package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record ExprAddrOf(@NotNull String varName, int index, @Nullable Type type, @Nullable Expression arrayIndex, @NotNull Location location) implements Expression {

	public ExprAddrOf(@NotNull String varName, @Nullable Expression arrayIndex, @NotNull Location location) {
		this(varName, 0, null, arrayIndex, location);
	}

	@NotNull
	@Override
	public Type typeNotNull() {
		return Objects.requireNonNull(type);
	}

	@NotNull
	@Override
	public String toUserString() {
		return arrayIndex != null
				? "addr-of " + varName + "[...]"
				: "addr-of " + varName;
	}
}
