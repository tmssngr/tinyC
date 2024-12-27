package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;

import java.util.*;

import org.junit.*;

import static org.junit.Assert.assertEquals;

/**
 * @author Thomas Singer
 */
public class LSRangeTest {

	public static void assertEqualsRanges(List<LSRange> expected, List<LSRange> actual) {
		TestUtils.assertEquals(expected, actual, LSRangeTest::assertEqualsRange);
	}

	@Test
	public void testFirstIntersection() {
		testFirstIntersection(-1,
		                      List.of(
				                      new LSRange(0, 2)
		                      ),
		                      List.of(
				                      new LSRange(2, 4)
		                      ));
		testFirstIntersection(1,
		                      List.of(
				                      new LSRange(0, 2)
		                      ),
		                      List.of(
				                      new LSRange(1, 4)
		                      ));
		testFirstIntersection(4,
		                      List.of(
				                      new LSRange(0, 2), new LSRange(3, 6)
		                      ),
		                      List.of(
				                      new LSRange(4, 5)
		                      ));
	}

	@Test
	public void testSplit() {
		testSplit(List.of(), List.of(), 0, List.of());
		testSplit(List.of(),
		          List.of(new LSRange(0, 2)),
		          0,
		          List.of(new LSRange(0, 2)));
		testSplit(List.of(new LSRange(0, 2)),
		          List.of(),
		          2,
		          List.of(new LSRange(0, 2)));
		testSplit(List.of(new LSRange(0, 1)),
		          List.of(new LSRange(1, 2)),
		          1,
		          List.of(new LSRange(0, 2)));

		testSplit(List.of(new LSRange(0, 5)),
		          List.of(new LSRange(8, 10)),
		          5,
		          List.of(new LSRange(0, 5), new LSRange(8, 10)));
		testSplit(List.of(new LSRange(0, 5), new LSRange(8, 9)),
		          List.of(new LSRange(9, 10)),
		          9,
		          List.of(new LSRange(0, 5), new LSRange(8, 10)));
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

	private void testSplit(List<LSRange> expectedBefore, List<LSRange> expectedAfter, int pos, List<LSRange> input) {
		final Pair<List<LSRange>, List<LSRange>> split = LSRange.split(pos, input);
		assertEqualsRanges(expectedBefore, split.first());
		assertEqualsRanges(expectedAfter, split.second());
	}

	private void testFirstIntersection(int expected, List<LSRange> ranges1, List<LSRange> ranges2) {
		assertEquals(expected, LSRange.getFirstIntersection(ranges1, ranges2));
		assertEquals(expected, LSRange.getFirstIntersection(ranges2, ranges1));
	}

	private static void assertEqualsRange(LSRange expected, LSRange actual) {
		assertEquals(expected.from(), actual.from());
		assertEquals(expected.to(), actual.to());
	}
}