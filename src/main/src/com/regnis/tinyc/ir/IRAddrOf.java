package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRAddrOf(@NotNull IRVar target, @NotNull IRVar source, @NotNull Location location) implements IRInstruction {
	public IRAddrOf(@NotNull IRVar target, @NotNull IRVar source) {
		this(target, source, Location.DUMMY);
	}

	public IRAddrOf {
		Utils.assertTrue(target.type().isPointer());
		// we don't verify more detailed, because we use it for pointer arithmetics,
		// e.g. pointer to structs will be turned into a pointer to a struct member (with the help of an offset)
	}

	@NotNull
	@Override
	public String toString() {
		return toString(false);
	}

	@Override
	public String toString(boolean comment) {
		return "addrof " + target.toString(comment) + ", " + source.toString(comment);
	}
}
