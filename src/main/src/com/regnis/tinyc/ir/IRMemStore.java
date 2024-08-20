package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRMemStore(@NotNull IRVar addr, @NotNull IRVar value, @NotNull Location location) implements IRInstruction {
	public IRMemStore {
		Utils.assertTrue(Objects.equals(value.type(), addr.type().toType()));
	}

	@Override
	public String toString() {
		return "store [" + addr + "], " + value;
	}
}
