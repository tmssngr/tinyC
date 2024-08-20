package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRAddrOf(@NotNull IRVar target, @NotNull IRVar source, @NotNull Location location) implements IRInstruction {
	public IRAddrOf {
		Utils.assertTrue(target.type().isPointer());
		// we don't verify more detailed, because we use it for pointer arithmetics,
		// e.g. pointer to structs will be turned into a pointer to a struct member (with the help of an offset)
	}

	@Override
	public String toString() {
		return "addrof " + target + ", " + source;
	}
}
