package com.regnis.tinyc;

import java.util.*;
import java.util.function.*;

import org.junit.*;

/**
 * @author Thomas Singer
 */
public class TestUtils {
	public static <E> void assertEquals(List<E> expectedList, List<E> actualList, BiConsumer<E, E> consumer) {
		Assert.assertEquals(expectedList.size(), actualList.size());
		final Iterator<E> expIt = expectedList.iterator();
		final Iterator<E> actualIt = actualList.iterator();
		while (true) {
			final E expected = expIt.hasNext() ? expIt.next() : null;
			final E actual = actualIt.hasNext() ? actualIt.next() : null;
			if (expected == null || actual == null) {
				Assert.assertEquals(expected, actual);
				return;
			}

			consumer.accept(expected, actual);
		}
	}
}
