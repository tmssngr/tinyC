package com.regnis.tinyc;

import java.util.*;
import java.util.function.*;

import org.junit.*;

/**
 * @author Thomas Singer
 */
public class TestUtils {
	public static <E> void assertEquals(List<E> expectedList, List<E> actualList, BiConsumer<E, E> consumer) {
		final Iterator<E> expIt = expectedList.iterator();
		final Iterator<E> actualIt = actualList.iterator();
		while (true) {
			final boolean expHasNext = expIt.hasNext();
			final boolean actualHasNext = actualIt.hasNext();
			if (!expHasNext && !actualHasNext) {
				break;
			}

			final E expected = expHasNext ? expIt.next() : null;
			final E actual = actualHasNext ? actualIt.next() : null;
			if (expected == null || actual == null) {
				Assert.assertEquals(expected, actual);
				return;
			}

			consumer.accept(expected, actual);
		}
	}
}
