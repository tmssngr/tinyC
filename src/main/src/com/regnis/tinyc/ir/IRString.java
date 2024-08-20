package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRString(@NotNull IRVar target, int stringIndex, @NotNull Location location) implements IRInstruction {
	@Override
	public String toString() {
		return "const " + target + ", [string-" + stringIndex + "]";
	}
}
