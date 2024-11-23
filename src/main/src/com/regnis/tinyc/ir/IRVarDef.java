package com.regnis.tinyc.ir;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRVarDef(@NotNull IRVar var, int size) {
	@Override
	public String toString() {
		return var + "/" + size;
	}

	@NotNull
	public String getString() {
		return var.index() + ": " + var.name() + " (" + var.type() + "/" + size() + ")";
	}
}
