package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRMemLoad(@NotNull IRVar target, @NotNull IRVar addr, @NotNull Location location) implements IRInstruction {
	public IRMemLoad(@NotNull IRVar target, @NotNull IRVar addr) {
		this(target, addr, Location.DUMMY);
	}

	public IRMemLoad {
		Utils.assertTrue(addr.type().isPointer());
	}

	@NotNull
	@Override
	public String toString() {
		return toString(false);
	}

	@Override
	public String toString(boolean comment) {
		return "load " + target.toString(comment) + ", [" + addr.toString(comment) + "]";
	}
}
