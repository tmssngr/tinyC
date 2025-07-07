package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;
import jdk.jshell.execution.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record Type(@NotNull String name, @Nullable Type toType, @NotNull Category category) {
	public static final Type VOID = new Type("void", null, Category.Other);
	public static final Type BOOL = new Type("bool", null, Category.Other);
	public static final Type U8 = new Type("u8", null, Category.Integer);
	public static final Type I16 = new Type("i16", null, Category.Integer);
	public static final Type I32 = new Type("i32", null, Category.Integer);
	public static final Type I64 = new Type("i64", null, Category.Integer);
	public static final Type POINTER_U8 = Type.pointer(Type.U8);

	public Type {
		if (category == Category.Pointer) {
			Utils.assertTrue(toType != null);
		}
		else {
			Utils.assertTrue(toType == null);
		}
	}

	public static Type pointer(@NotNull Type toType) {
		return new Type(toType.name + "*", toType, Category.Pointer);
	}

	public static Type struct(@NotNull String name) {
		return new Type(name, null, Category.Struct);
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
		return category == Category.Pointer;
	}

	public boolean isInt() {
		return category == Category.Integer;
	}

	public boolean isStruct() {
		return category == Category.Struct;
	}

	private enum Category {
		Integer, Pointer, Struct, Other
	}
}
