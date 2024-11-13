package com.regnis.tinyc.ir;

import com.regnis.tinyc.ast.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRVarDef(@NotNull String name, int index, @NotNull VariableScope scope, @NotNull Type type, int size) {
	@Override
	public String toString() {
		return index + ": " + name + " (" + type + "/" + size + ")";
	}
}
