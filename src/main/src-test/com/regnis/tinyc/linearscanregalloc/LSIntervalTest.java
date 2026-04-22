package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;
import org.junit.*;

import static org.junit.Assert.*;

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

	@Test
	public void testSplit2() {
		final LSInterval interval = LSInterval.testVar(new IRVar("strlen", 0, VariableScope.parameter, Type.POINTER_U8),
		                                               List.of(new LSRange(0, 12), new LSRange(20, 34)),
		                                               List.of(LSUse.write(0),
		                                                       LSUse.read(12),
		                                                       LSUse.write(20),
		                                                       LSUse.read(34)
		                                               ));
		assertEquals(0, interval.getFrom());
		assertEquals(34, interval.getTo());
		assertEquals(List.of(LSUse.write(0),
		                     LSUse.read(12),
		                     LSUse.write(20),
		                     LSUse.read(34)
		), interval.uses());

		final LSInterval child = interval.truncateAndSplit(12);
		assertEquals(0, interval.getFrom());
		assertEquals(12, interval.getTo());
		assertEquals(List.of(LSUse.write(0),
		                     LSUse.read(12)
		), interval.uses());

		assertEquals(20, child.getFrom());
		assertEquals(34, child.getTo());
		assertEquals(List.of(LSUse.write(20),
		                     LSUse.read(34)
		), child.uses());
	}

	@Test
	public void testGetSubInterval() {
		final LSInterval i0 = LSInterval.testVar(new IRVar("a", 0, VariableScope.function, Type.I64),
		                                         List.of(new LSRange(0, 14)),
		                                         List.of(new LSUse(0, true), new LSUse(6, false), new LSUse(14, false)));
		final LSInterval i1 = i0.truncateAndSplit(7);
		final LSInterval i2 = i1.truncateAndSplit(13);
		int i = 0;
		assertGetSubInterval(null, i0, i, i0);
		for (i++; i < 7; i++) {
			assertGetSubInterval(i0, i0, i, i0);
		}
		assertGetSubInterval(i0, i1, i, i0);
		for (i++; i < 13; i++) {
			assertGetSubInterval(i1, i1, i, i0);
		}
		assertGetSubInterval(i1, i2, i, i0);
		i++;
		assertGetSubInterval(i2, null, i, i0);
		i++;
		assertGetSubInterval(null, null, i, i0);
	}

	@Test
	public void testGetTransitionAt() {
		final IRVar var = new IRVar("tmp.ptrToSpace", 0, VariableScope.function, Type.pointer(Type.I16));
		final LSInterval i0 = LSInterval.testVar(var,
		                                         List.of(new LSRange(6, 16), new LSRange(22, 36)),
		                                         List.of(new LSUse(6, true), new LSUse(16, false),
		                                                 new LSUse(22, true), new LSUse(36, false)));
		int i = 0;
		for (; i < 38; i++) {
			assertGetTransitionAt(null, i, i0);
		}

		final LSInterval i1 = i0.truncateAndSplit(19);

		for (i = 0; i < 38; i++) {
			assertGetTransitionAt(null, i, i0);
		}

		i1.setRegister(1);
		final LSInterval i2 = i1.truncateAndSplit(25);
		i2.setRegister(2);

		for (i = 0; i < 25; i++) {
			assertGetTransitionAt(null, i, i0);
		}
		assertGetTransitionAt(new Pair<>(var.asRegister(1), var.asRegister(2)), i, i0);
		i++;
		for (; i < 38; i++) {
			assertGetTransitionAt(null, i, i0);
		}
	}

	private void assertGetSubInterval(@Nullable LSInterval expectedReadInterval, @Nullable LSInterval expectedWriteInterval, int pos, LSInterval i0) {
		assertSame(expectedReadInterval, i0.getSubInterval(pos, true, false));
		assertSame(expectedWriteInterval, i0.getSubInterval(pos, false, true));
	}

	private void assertGetTransitionAt(@Nullable Pair<IRVar, IRVar> expectedTransition, int pos, LSInterval i0) {
		assertEquals(expectedTransition, i0.getTransitionAt(pos));
	}
}