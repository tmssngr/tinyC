package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.junit.*;

import static org.junit.Assert.assertEquals;

/**
 * @author Thomas Singer
 */
public class LSIntervalTest {

	@Test
	public void testSplit() {
		final LSInterval interval = LSInterval.testVar(new IRVar("a", 0, VariableScope.function, Type.I16),
		                                               List.of(new LSRange(1, 20), new LSRange(20, 25)),
		                                               List.of(LSUse.write(1),
		                                                       LSUse.read(6),
		                                                       LSUse.read(20),
		                                                       LSUse.read(24)
		                                               ));
		assertEquals(1, interval.getFrom());
		assertEquals(25, interval.getTo());
		assertEquals(List.of(LSUse.write(1),
		                     LSUse.read(6),
		                     LSUse.read(20),
		                     LSUse.read(24)
		), interval.uses());

		final LSInterval child = interval.truncateAndSplit(18);
		assertEquals(1, interval.getFrom());
		assertEquals(18, interval.getTo());
		assertEquals(List.of(LSUse.write(1),
		                     LSUse.read(6)
		), interval.uses());

		assertEquals(18, child.getFrom());
		assertEquals(25, child.getTo());
		assertEquals(List.of(LSUse.read(20),
		                     LSUse.read(24)
		), child.uses());
	}
}