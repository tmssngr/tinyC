package com.regnis.tinyc.ir;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRLocalVar(@NotNull String name, int index, boolean isArg, int size) {
	@Override
	public String toString() {
		return index + ": " + name;
	}
}
