package com.regnis.tinyc.ir;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRComment(@NotNull String comment) implements IRInstruction {
	@Override
	public String toString() {
		return "; " + comment;
	}
}
