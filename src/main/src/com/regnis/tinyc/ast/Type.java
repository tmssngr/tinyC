package com.regnis.tinyc.ast;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record Type(@NotNull String name, @Nullable Type toType, boolean isInt) {
	public static final Type VOID = new Type("void", null, false);
	public static final Type U8 = new Type("u8", null, true);
	public static final Type I16 = new Type("i16", null, true);
	public static final Type I32 = new Type("i32", null, true);
	public static final Type I64 = new Type("i64", null, true);

	public static Type pointer(@NotNull Type toType) {
		return new Type("*", toType, false);
	}

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
		if (type == I32) {
			return 4;
		}
		if (type == I64) {
			return 8;
		}
		throw new IllegalStateException("Unknown type " + type);
	}

	public boolean isPointer() {
		return toType != null;
	}

	public boolean isInt() {
		return isInt;
	}
}
