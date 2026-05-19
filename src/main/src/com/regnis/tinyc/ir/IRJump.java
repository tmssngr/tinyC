package com.regnis.tinyc.ir;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRJump(@NotNull String label) implements IRInstruction {
	@NotNull
	@Override
	public String toString() {
		return "jump " + label;
	}
}
