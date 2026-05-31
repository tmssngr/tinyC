package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRMove(@NotNull IRVar target, @NotNull IRVar source, @NotNull Location location) implements IRInstruction {
	public IRMove(@NotNull IRVar target, @NotNull IRVar source) {
		this(target, source, Location.DUMMY);
	}

	public IRMove {
		Utils.assertTrue(Objects.equals(target.type(), source.type()));
	}

	@NotNull
	@Override
	public String toString() {
		return toString(false);
	}

	@Override
	public String toString(boolean comment) {
		return "move " + target.toString(comment) + ", " + source.toString(comment);
	}
}
