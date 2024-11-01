package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRAddrOfArray(@NotNull IRVar addr, @NotNull IRVar array, @NotNull Location location) implements IRInstruction {
	@Override
	public String toString() {
		return "addrof " + addr + ", [" + array + "]";
	}
}
