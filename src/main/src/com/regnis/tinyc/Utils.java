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
}
