package com.regnis.tinyc.ir;

import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRValue(@Nullable IRVar var, int value, @NotNull Type type) {
	@NotNull
	public static List<IRValue> toValues(@NotNull IRVar... vars) {
		final List<IRValue> values = new ArrayList<>();
		for (IRVar var : vars) {
			values.add(new IRValue(var));
		}
		return values;
	}

	public IRValue(@NotNull IRVar var) {
		this(var, 0, var.type());
	}

	public IRValue(int value, @NotNull Type type) {
		this(null, value, type);
	}

	@NotNull
	@Override
	public String toString() {
		return toString(false);
	}

	@NotNull
	public String toString(boolean comment) {
		if (var != null) {
			return var.toString(comment);
		}
		return String.valueOf(value);
	}
}
