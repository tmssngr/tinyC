package com.regnis.tinyc.ir;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRLabel(@NotNull String label, int loopLevel) implements IRInstruction {
	@Override
	public String toString() {
		return label + ":";
	}
}
