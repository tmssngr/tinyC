package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRRetValue(@NotNull IRVar var, @NotNull Location location) implements IRInstruction {
	public IRRetValue(@NotNull IRVar var) {
		this(var, Location.DUMMY);
	}

	@NotNull
	@Override
	public String toString() {
		return toString(false);
	}

	@Override
	public String toString(boolean comment) {
		return "ret " + var.toString(comment);
	}
}
