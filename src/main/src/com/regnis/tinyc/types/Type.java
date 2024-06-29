package com.regnis.tinyc.types;

/**
 * @author Thomas Singer
 */
public record Type(String name) {
	public static final Type VOID = new Type("void");
	public static final Type U8 = new Type("u8");
	public static final Type I16 = new Type("i16");
}
