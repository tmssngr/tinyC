package com.regnis.tinyc;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public class Utils {
	public static void assertTrue(boolean value) {
		assertTrue(value, "");
	}

	public static void assertTrue(boolean value, String msg) {
		if (!value) {
			throw new IllegalStateException(msg);
		}
	}

	@Nullable
	public static <E> E getLastOrNull(List<E> list) {
		if (list.isEmpty()) {
			return null;
		}
		return list.getLast();
	}

	public static String toHex(long value, int digits) {
		final StringBuilder buffer = new StringBuilder();
		toHex(value, digits, buffer);
		return buffer.toString();
	}

	public static void toHex(long value, int digits, StringBuilder buffer) {
		if (digits < 1) {
			return;
		}

		if (digits > 1) {
			toHex(value >> 4, digits - 1, buffer);
		}
		buffer.append("0123456789abcdef".charAt((int)value & 0xF));
	}

	public static String escape(String text) {
		final StringBuilder buffer = new StringBuilder();
		buffer.append('"');
		for (int i = 0; i < text.length(); i++) {
			final char chr = text.charAt(i);
			switch (chr) {
			case 0 -> buffer.append("\\0");
			case '\n' -> buffer.append("\\n");
			case '"' -> buffer.append("\\\"");
			case '\\' -> buffer.append("\\\\");
			default -> {
				if (chr < 0x20 || chr >= 0x80) {
					buffer.append("\\u");
					toHex(chr, 4, buffer);
				}
				else {
					buffer.append(chr);
				}
			}
			}
		}
		buffer.append('"');
		return buffer.toString();
	}
}
