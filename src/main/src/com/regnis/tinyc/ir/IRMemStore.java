package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRMemStore(@NotNull IRVar addr, @NotNull IRVar value, @NotNull Location location) implements IRInstruction {
	public IRMemStore {
		Utils.assertTrue(addr.type().isPointer());
	}

	@NotNull
	@Override
	public String toString() {
		return toString(false);
	}

	@Override
	public String toString(boolean comment) {
		return "store [" + addr.toString(comment) + "], " + value.toString(comment);
	}
}
