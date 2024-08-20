package com.regnis.tinyc.ir;

import com.regnis.tinyc.ast.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRVar(@NotNull String name, int index, @NotNull VariableScope scope, @NotNull Type type) {
	@Override
	public String toString() {
		return name + "(" + index + "@" + scope + "," + type + ")";
	}
}