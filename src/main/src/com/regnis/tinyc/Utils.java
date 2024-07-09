package com.regnis.tinyc;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public class Utils {
	public static void assertTrue(boolean value) {
		if (!value) {
			throw new IllegalStateException();
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
}
