package com.regnis.tinyc.ast;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record Type(@NotNull String name, @Nullable Type toType, boolean isInt) {
	public static final Type VOID = new Type("void", null, false);
	public static final Type BOOL = new Type("bool", null, false);
	public static final Type U8 = new Type("u8", null, true);
	public static final Type I16 = new Type("i16", null, true);
	public static final Type I32 = new Type("i32", null, true);
	public static final Type I64 = new Type("i64", null, true);
	public static final Type POINTER_U8 = Type.pointer(Type.U8);

	public static Type pointer(@NotNull Type toType) {
		return new Type(toType.name + "*", toType, false);
	}

	public static Type struct(@NotNull String name) {
		return new Type(name, null, false);
	}

	public static int getSize(@NotNull Type type) {
		if (type == VOID) {
			return 0;
		}
		if (type == U8 || type == BOOL) {
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

	@Nullable
	public static Type getDefaultType(@NotNull String type) {
		return switch (type) {
			case "void" -> VOID;
			case "bool" -> BOOL;
			case "u8" -> U8;
			case "i16" -> I16;
			case "i32" -> I32;
			case "i64" -> I64;
			default -> null;
		};
	}

	@Override
	public String toString() {
		return name;
	}

	public boolean isPointer() {
		return toType != null;
	}

	public boolean isInt() {
		return isInt;
	}
}
