package com.regnis.tinyc;

/**
 * @author Thomas Singer
 */
public class Utils {
	public static void assertTrue(boolean value) {
		if (!value) {
			throw new IllegalStateException();
		}
	}
}
