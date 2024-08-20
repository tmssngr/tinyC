package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import java.util.List;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRCall(@Nullable IRVar target, @NotNull String name, @NotNull List<IRVar> args, @NotNull Location location) implements IRInstruction {
	@Override
	public String toString() {
		if (target == null) {
			return "call _, " + name + " " + args;
		}
		return "call " + target + ", " + name + ", " + args;
	}
}
