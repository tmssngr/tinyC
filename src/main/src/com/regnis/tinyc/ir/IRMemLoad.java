package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRMemLoad(@NotNull IRVar target, @NotNull IRVar addr, @NotNull Location location) implements IRInstruction {
	public IRMemLoad {
		Utils.assertTrue(Objects.equals(target.type(), addr.type().toType()));
	}

	@Override
	public String toString() {
		return "load " + target + ", [" + addr + "]";
	}
}
