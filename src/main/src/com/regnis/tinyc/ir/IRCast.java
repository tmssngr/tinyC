package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRCast(@NotNull IRVar target, @NotNull IRVar source, @NotNull Location location) implements IRInstruction {
	@Override
	public String toString() {
		return "cast " + target + ", " + source;
	}
}
