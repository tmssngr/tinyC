package com.regnis.tinyc.ast;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record Type(String name) {
	public static final Type VOID = new Type("void");
	public static final Type U8 = new Type("u8");
	public static final Type I16 = new Type("i16");

	public static int getSize(@NotNull Type type) {
		if (type == VOID) {
			return 0;
		}
		if (type == U8) {
			return 1;
		}
		if (type == I16) {
			return 2;
		}
		throw new IllegalStateException("Unknown type " + type);
	}
}
