package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record Type(@NotNull String name, @Nullable Type toType, @NotNull Category category, long min, long max) {
	public static final Type VOID = createOtherType("void");
	public static final Type BOOL = createOtherType("bool");
	public static final Type U8 = createIntegerType("u8", 0, 0xFF);
	public static final Type I16 = createIntegerType("i16", -32768, 0x7fff);
	public static final Type I32 = createIntegerType("i32", Integer.MIN_VALUE, Integer.MAX_VALUE);
	public static final Type I64 = createIntegerType("i64", Long.MIN_VALUE, Long.MAX_VALUE);
	public static final Type POINTER_U8 = Type.pointer(Type.U8);

	public static Type pointer(@NotNull Type toType) {
		return new Type(toType.name + "*", toType, Category.Pointer, 0, 0);
	}

	public static Type struct(@NotNull String name) {
		return new Type(name, null, Category.Struct, 0, 0);
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

	public Type {
		if (category == Category.Pointer) {
			Utils.assertTrue(toType != null);
		}
		else {
			Utils.assertTrue(toType == null);
		}
	}

	@NotNull
	@Override
	public String toString() {
		return name;
	}

	public boolean isPointer() {
		return category == Category.Pointer;
	}

	public boolean isInt() {
		return category == Category.Integer;
	}

	public boolean isStruct() {
		return category == Category.Struct;
	}

	@NotNull
	private static Type createOtherType(String name) {
		return new Type(name, null, Category.Other, 0, 0);
	}

	@NotNull
	private static Type createIntegerType(String name, long min, long max) {
		return new Type(name, null, Category.Integer, min, max);
	}

	private enum Category {
		Integer, Pointer, Struct, Other
	}
}
