package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRRetValue(@NotNull IRVar var, @NotNull Location location) implements IRInstruction {
	@Override
	public String toString() {
		return "ret " + var;
	}
}
