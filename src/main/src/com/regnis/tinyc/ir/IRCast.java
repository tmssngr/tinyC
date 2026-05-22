package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRCast(@NotNull IRVar target, @NotNull IRVar source, @NotNull Location location) implements IRInstruction {
	@NotNull
	@Override
	public String toString() {
		return toString(false);
	}

	@Override
	public String toString(boolean comment) {
		return "cast " + target.toString(comment) + "(" + target.type() + "), " + source.toString(comment) + "(" + source.type() + ")";
	}
}
