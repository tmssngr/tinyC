package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.junit.*;

import static com.regnis.tinyc.linearscanregalloc.LSUse.*;
import static org.junit.Assert.*;

/**
 * @author Thomas Singer
 */
public class LSAlgorithmTest {

	@Test
	public void test1() {
		// 0: a = 1
		// 2: mov r0, a
		final IRVar varA = new IRVar("a", 0, VariableScope.function, Type.I16);
		final LSInterval interval = LSInterval.testVar(varA, List.of(new LSRange(0, 2)), List.of(write(0), read(2)));
		final LSAlgorithm algorithm = new LSAlgorithm(List.of(interval), List.of(), List.of(), 4);

		algorithm.run();
		assertInterval(0, 2, 0, interval);
		assertNull(interval.getNextSplit());
	}

	@Test
	public void test2() {
		//  0: move str, r1
		//  2: move r1, str
		//  4: call r0, strlen, [r1]
		//  6: move length, r0
		//  8: move r1, str
		// 10: move r2, length
		// 12: call _, printStringLength [r1, r2]
		// 14: @printString_ret:
		final IRVar varStr = new IRVar("str", 0, VariableScope.function, Type.I16);
		final IRVar varLength = new IRVar("length", 0, VariableScope.function, Type.I16);
		final LSInterval iStr = LSInterval.testVar(varStr,
		                                           List.of(new LSRange(0, 8)),
		                                           List.of(write(0), read(2), read(8)
		                                           ));
		final LSInterval iLength = LSInterval.testVar(varLength,
		                                              List.of(new LSRange(6, 10)),
		                                              List.of(write(6), read(10)
		                                              ));
		final LSAlgorithm algorithm = new LSAlgorithm(List.of(
				iStr,
				iLength
		), List.of(
				LSInterval.testFixed(0, List.of(new LSRange(4, 6))),
				LSInterval.testFixed(1, List.of(new LSRange(-1, 0), new LSRange(2, 5), new LSRange(8, 12))),
				LSInterval.testFixed(2, List.of(new LSRange(4, 5), new LSRange(10, 13)))
		), List.of(), 4);

		algorithm.run();

		assertInterval(0, 8, 3, iStr);
		assertNull(iStr.getNextSplit());

		assertInterval(6, 10, 2, iLength);
		assertNull(iLength.getNextSplit());
	}

	@Test
	public void test3() {
		// 0: move a, 1
		// 2: call foo
		// 4: move r1, a
		// 6: call bar
		final IRVar varA = new IRVar("a", 0, VariableScope.function, Type.I16);
		final LSInterval interval = LSInterval.testVar(varA,
		                                               List.of(new LSRange(0, 4)),
		                                               List.of(write(0), read(4)
		                                               ));
		final LSAlgorithm algorithm = new LSAlgorithm(List.of(
				interval
		), List.of(
				LSInterval.testFixed(0, List.of(new LSRange(2), new LSRange(6))),
				LSInterval.testFixed(1, List.of(new LSRange(2), new LSRange(4, 7)))
		), List.of(), 2);

		algorithm.run();

		assertInterval(0, 1, 0, interval);

		LSInterval split = interval.getNextSplit();
		assertNotNull(split);
		assertInterval(1, 3, -1, split);

		split = split.getNextSplit();
		assertNotNull(split);
		assertInterval(3, 4, 1, split);
		assertNull(split.getNextSplit());
	}

	@Test
	public void test4() {
		// 0: const a, 1
		// 2: move r1, a
		// 4: call r0, foo(r1)
		// 6: move b, r0
		// 8: add a, b
		// 10: move r0, a
		final IRVar varA = new IRVar("a", 0, VariableScope.function, Type.I16);
		final IRVar varB = new IRVar("b", 1, VariableScope.function, Type.I16);
		final LSInterval iA = LSInterval.testVar(varA,
		                                         List.of(new LSRange(0, 10)),
		                                         List.of(write(0), read(2), write(8), read(10)
		                                         ));
		final LSInterval iB = LSInterval.testVar(varB,
		                                         List.of(new LSRange(6, 8)),
		                                         List.of(write(6), read(8)
		                                         ));
		final LSAlgorithm algorithm = new LSAlgorithm(List.of(
				iA,
				iB
		), List.of(
				LSInterval.testFixed(0, List.of(new LSRange(4, 6), new LSRange(10))),
				LSInterval.testFixed(1, List.of(new LSRange(2, 5)))
		), List.of(), 2);

		algorithm.run();

		assertInterval(0, 3, 1, iA);

		LSInterval split = iA.getNextSplit();
		assertNotNull(split);
		assertInterval(3, 7, -1, split);

		split = split.getNextSplit();
		assertNotNull(split);
		assertInterval(7, 10, 0, split);
		assertNull(split.getNextSplit());

		// iB
		assertInterval(6, 8, 1, iB);
		assertNull(iB.getNextSplit());
	}

	private void assertInterval(int expectedFrom, int expectedTo, int expectedRegister, LSInterval interval) {
		assertEquals(expectedFrom, interval.getFrom());
		assertEquals(expectedTo, interval.getTo());
		assertEquals(expectedRegister, interval.register());
	}
}