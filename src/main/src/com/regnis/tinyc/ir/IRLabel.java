package com.regnis.tinyc.ir;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRLabel(@NotNull String label) implements IRInstruction {
	@NotNull
	@Override
	public String toString() {
		return label + ":";
	}

	@Override
	public String toString(boolean comment) {
		return toString();
	}
}
