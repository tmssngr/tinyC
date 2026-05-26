package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRCast(@NotNull IRVar target, @NotNull IRVar source, @NotNull Location location) implements IRInstruction {
	public IRCast(@NotNull IRVar target, @NotNull IRVar source, @NotNull Location location) {
		Utils.assertTrue(target.type().isInt());
		this.target = target;
		this.source = source;
		this.location = location;
	}

	public IRCast(@NotNull IRVar target, @NotNull IRVar source) {
		this(target, source, Location.DUMMY);
	}

	@NotNull
	@Override
	public String toString() {
		return "cast " + target + "(" + target.type() + "), " + source + "(" + source.type() + ")";
	}
}
