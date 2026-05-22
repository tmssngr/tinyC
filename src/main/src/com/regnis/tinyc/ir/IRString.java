package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRString(@NotNull IRVar target, int stringIndex, @NotNull Location location) implements IRInstruction {
	@NotNull
	@Override
	public String toString() {
		return toString(false);
	}

	@Override
	public String toString(boolean comment) {
		return "const " + target.toString(comment) + ", [string-" + stringIndex + "]";
	}
}
