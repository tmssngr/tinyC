package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRLiteral(@NotNull IRVar target, int value, @NotNull Location location) implements IRInstruction {
	public IRLiteral(@NotNull IRVar target, int value) {
		this(target, value, Location.DUMMY);
	}

	@NotNull
	@Override
	public String toString() {
		return "const " + target + ", " + value;
	}
}
