package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;
import org.junit.*;

import static org.junit.Assert.*;

/**
 * @author Thomas Singer
 */
public class LSRange2Test {

	@Test
	public void testFirstIntersection() {
		testFirstIntersection(-1,
		                      new LSRange2(0, 2, null),
		                      new LSRange2(2, 4, null)
		);
		testFirstIntersection(1,
		                      new LSRange2(0, 2, null),
		                      new LSRange2(1, 4, null)
		);
		testFirstIntersection(4,
		                      new LSRange2(0, 2, 
		                                   new LSRange2(3, 6, null)),
		                      new LSRange2(4, 5, null)
		);
	}

	@Test
	public void testSplit() {
		testSplit(new LSRange2(0, 1, null),
		          new LSRange2(1, 2, null),
		          1,
		          new LSRange2(0, 2, null));

		testSplit(new LSRange2(0, 5, null),
		          new LSRange2(8, 10, null),
		          5,
		          new LSRange2(0, 5,
		                       new LSRange2(8, 10, null)));
		testSplit(new LSRange2(0, 5,
		                       new LSRange2(8, 9, null)),
		          new LSRange2(9, 10, null),
		          9,
		          new LSRange2(0, 5,
		                       new LSRange2(8, 10, null)));
	}

	@Test
	public void testGetFreeUntil() {
		assertEquals(Integer.MAX_VALUE, LSRange.getFreeUntil(0, List.of()));
		assertEquals(2, LSRange.getFreeUntil(0, List.of(new LSRange(2, 3))));
		assertEquals(-1, LSRange.getFreeUntil(2, List.of(new LSRange(2, 3))));

		assertEquals(-1, LSRange.getFreeUntil(2, List.of(new LSRange(2, 3), new LSRange(3, 4))));
		assertEquals(-1, LSRange.getFreeUntil(3, List.of(new LSRange(2, 3), new LSRange(3, 4))));
		assertEquals(Integer.MAX_VALUE, LSRange.getFreeUntil(4, List.of(new LSRange(2, 3), new LSRange(3, 4))));

		assertEquals(-1, LSRange.getFreeUntil(2, List.of(new LSRange(2, 3), new LSRange(4, 5))));
		assertEquals(4, LSRange.getFreeUntil(3, List.of(new LSRange(2, 3), new LSRange(4, 5))));
		assertEquals(Integer.MAX_VALUE, LSRange.getFreeUntil(5, List.of(new LSRange(2, 3), new LSRange(4, 5))));
	}

	private void testSplit(@NotNull LSRange2 expectedBefore, @NotNull LSRange2 expectedAfter, int pos, @NotNull LSRange2 input) {
		final LSRange2 split = input.split(pos);
		assertEqualsRange(expectedBefore, input);
		assertEqualsRange(expectedAfter, split);
	}

	private void testFirstIntersection(int expected, LSRange2 ranges1, LSRange2 ranges2) {
		assertEquals(expected, LSRange2.getFirstIntersection(ranges1, ranges2));
		assertEquals(expected, LSRange2.getFirstIntersection(ranges2, ranges1));
	}

	private static void assertEqualsRange(LSRange2 expected, LSRange2 actual) {
		assertEquals(expected.from(), actual.from());
		assertEquals(expected.to(), actual.to());
		final LSRange2 expectedNext = expected.next();
		final LSRange2 actualNext = actual.next();
		if (expectedNext != null) {
			assertNotNull(actualNext);
			assertEqualsRange(expectedNext, actualNext);
		}
		else {
			assertNull(actualNext);
		}
	}
}