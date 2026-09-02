package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRMove(@NotNull IRVar target, @NotNull IRValue source, @NotNull Location location) implements IRInstruction {
	public IRMove(@NotNull IRVar target, @NotNull IRVar source) {
		this(target, source, Location.DUMMY);
	}

	public IRMove(@NotNull IRVar target, @NotNull IRVar source, @NotNull Location location) {
		this(target, new IRValue(source, 0, source.type()), location);
	}

	public IRMove(@NotNull IRVar target, int value) {
		this(target, value, Location.DUMMY);
	}

	public IRMove(@NotNull IRVar target, int value, @NotNull Location location) {
		this(target, new IRValue(null, value, target.type()), location);
	}

	public IRMove {
		Utils.assertTrue(Objects.equals(target.type(), source.type()));
	}

	@NotNull
	@Override
	public String toString() {
		if (source.var() != null) {
			return "move " + target.toString() + ", " + source.toString();
		}
		return "const " + target.toString() + ", " + source.toString();
	}
}
