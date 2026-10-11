package com.regnis.tinyc;

import java.util.*;
import java.util.function.*;

import org.junit.*;

import static org.junit.Assert.assertEquals;

/**
 * @author Thomas Singer
 */
public class UtilsTest {

	@Test
	public void testBinarySearch() {
		final List<Integer> list = List.of(10, 20, 30);
		final ToIntFunction<Integer> function = Integer::intValue;
		assertEquals(0, Utils.binarySearch(9, list, function));
		assertEquals(0, Utils.binarySearch(10, list, function));
		assertEquals(1, Utils.binarySearch(11, list, function));
		assertEquals(1, Utils.binarySearch(19, list, function));
		assertEquals(1, Utils.binarySearch(20, list, function));
		assertEquals(2, Utils.binarySearch(29, list, function));
		assertEquals(2, Utils.binarySearch(30, list, function));
		assertEquals(3, Utils.binarySearch(31, list, function));
	}
}