package com.regnis.tinyc.ir;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRGlobalVar(@NotNull String name, int index, int size) {
	@Override
	public String toString() {
		return index + ": " + name + " (" + size + ")";
	}
}
