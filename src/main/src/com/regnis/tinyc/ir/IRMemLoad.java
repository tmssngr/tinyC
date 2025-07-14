package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRMemLoad(@NotNull IRVar target, @NotNull IRVar addr, @NotNull Location location) implements IRInstruction {
	public IRMemLoad {
		Utils.assertTrue(addr.type().isPointer());
	}

	@Override
	public String toString() {
		return "load " + target + ", [" + addr + "]";
	}
}
