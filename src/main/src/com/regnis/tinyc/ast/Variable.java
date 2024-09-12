package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record Variable(@NotNull String name, int index, @NotNull VariableScope scope, @NotNull Type type, int arraySize, @NotNull Location location) {
	public boolean isArray() {
		return arraySize > 0;
	}
}
