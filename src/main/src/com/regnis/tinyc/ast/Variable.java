package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record Variable(@NotNull String name, @NotNull Type type, int index, int arraySize, @NotNull Location location) {
	public boolean isScalar() {
		return arraySize == 0;
	}
}
