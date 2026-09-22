package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRRetValue(@NotNull IRValue value, @NotNull Location location) implements IRInstruction {
	public IRRetValue(@NotNull IRValue value) {
		this(value, Location.DUMMY);
	}

	public IRRetValue(@NotNull IRVar var) {
		this(var, Location.DUMMY);
	}

	public IRRetValue(@NotNull IRVar var, @NotNull Location location) {
		this(new IRValue(var), location);
	}

	public IRRetValue(int value, @NotNull Type type) {
		this(value, type, Location.DUMMY);
	}

	public IRRetValue(int value, @NotNull Type type, @NotNull Location location) {
		this(new IRValue(value, type), location);
	}

	@NotNull
	@Override
	public String toString() {
		return toString(false);
	}

	@Override
	public String toString(boolean comment) {
		return "ret " + value.toString(comment);
	}
}
