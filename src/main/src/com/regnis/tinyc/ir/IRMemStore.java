package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRMemStore(@Nullable IRVar addr, @NotNull IRVar value, @NotNull Location location) implements IRInstruction {

	public static IRMemStore push(@NotNull IRVar var) {
		return new IRMemStore(null, var, Location.DUMMY);
	}

	public IRMemStore {
		if (addr != null) {
			Utils.assertTrue(Objects.equals(value.type(), addr.type().toType()));
		}
	}

	@Override
	public String toString() {
		return addr != null
				? "store [" + addr + "], " + value
				: "push " + value;
	}
}
