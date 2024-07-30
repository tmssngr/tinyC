package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record ExprArrayAccess(@NotNull ExprVarAccess varAccess, @Nullable Type type, @NotNull Expression index) implements Expression {
	public ExprArrayAccess(@NotNull ExprVarAccess varAccess, @NotNull Expression index) {
		this(varAccess, null, index);
	}

	@NotNull
	@Override
	public Type typeNotNull() {
		return Objects.requireNonNull(type);
	}

	@NotNull
	@Override
	public Location location() {
		return index.location();
	}

	@NotNull
	@Override
	public String toUserString() {
		return "[...]";
	}
}
