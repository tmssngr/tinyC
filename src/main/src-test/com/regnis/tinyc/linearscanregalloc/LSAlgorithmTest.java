package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;
import org.junit.*;

import static com.regnis.tinyc.linearscanregalloc.LSUse.*;
import static org.junit.Assert.*;

/**
 * @author Thomas Singer
 */
public class LSAlgorithmTest {

	private static final Type Z8_POINTER_INT_TYPE = Type.I16;

	@Test
	public void test1() {
		// 0: a = 1
		// 2: mov r0, a
		final IRVar varA = new IRVar("a", 0, VariableScope.function, Type.I16);
		final LSInterval interval = LSInterval.testVar(varA, List.of(new LSRange(0, 2)), List.of(write(0), read(2)));
		final Map<IRVar, LSInterval> varMap = toVarMap(interval);
		final List<LSInterval> fixedIntervals = List.of();
		{
			final Map<IRVar, LSInterval> intervals = LSAlgorithm.perform(varMap, fixedIntervals, 4, null, LSAlgorithmLogger.DUMMY);

			assertEquals(1, intervals.size());

			final LSInterval split = assertInterval(0, 2, 0, intervals.get(varA));
			assertNull(split);
		}
		{
			final Map<IRVar, LSInterval> intervals = LSAlgorithm.perform(varMap, fixedIntervals, 4, Z8_POINTER_INT_TYPE, LSAlgorithmLogger.DUMMY);

			assertEquals(1, intervals.size());

			final LSInterval split = assertInterval(0, 2, 0, intervals.get(varA));
			assertNull(split);
		}
	}

	@Test
	public void test2() {
		// 0: a = 1
		// 2: b = 2
		// 4: add a, b
		final IRVar varA = new IRVar("a", 0, VariableScope.function, Type.I16);
		final IRVar varB = new IRVar("b", 1, VariableScope.function, Type.I16);
		final LSInterval intervalA = LSInterval.testVar(varA, List.of(new LSRange(0, 4)), List.of(write(0), write(4)));
		final LSInterval intervalB = LSInterval.testVar(varB, List.of(new LSRange(2, 4)), List.of(write(2), read(4)));
		final Map<IRVar, LSInterval> varMap = toVarMap(intervalA, intervalB);
		final List<LSInterval> fixedIntervals = List.of();
		{
			final Map<IRVar, LSInterval> intervals = LSAlgorithm.perform(varMap, fixedIntervals, 4, null, LSAlgorithmLogger.DUMMY);

			assertEquals(2, intervals.size());

			LSInterval split = assertInterval(0, 4, 0, intervals.get(varA));
			assertNull(split);

			split = assertInterval(2, 4, 1, intervals.get(varB));
			//                           ^
			assertNull(split);
		}
		{
			final Map<IRVar, LSInterval> intervals = LSAlgorithm.perform(varMap, fixedIntervals, 4, Z8_POINTER_INT_TYPE, LSAlgorithmLogger.DUMMY);

			assertEquals(2, intervals.size());

			LSInterval split = assertInterval(0, 4, 0, intervals.get(varA));
			assertNull(split);

			split = assertInterval(2, 4, 2, intervals.get(varB));
			//                           ^
			assertNull(split);
		}
	}

	@Test
	public void test3() {
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
		final LSInterval iStr = LSInterval.testVar(varStr, List.of(new LSRange(0, 8)),
		                                           List.of(write(0), read(2), read(8)));
		final LSInterval iLength = LSInterval.testVar(varLength, List.of(new LSRange(6, 10)),
		                                              List.of(write(6), read(10)));
		final Map<IRVar, LSInterval> varMap = toVarMap(iStr, iLength);
		{
			final List<LSInterval> fixedIntervals = List.of(
					LSInterval.testFixed(0, List.of(new LSRange(4, 6))),
					LSInterval.testFixed(1, List.of(new LSRange(-1, 0), new LSRange(2, 5), new LSRange(8, 12))),
					LSInterval.testFixed(2, List.of(new LSRange(4, 5), new LSRange(10, 13)))
			);
			final Map<IRVar, LSInterval> intervals = LSAlgorithm.perform(varMap, fixedIntervals, 4, null, new LSAlgorithmLoggerImpl(List.of()));
			assertEquals(2, intervals.size());

			LSInterval split = assertInterval(0, 8, 3, intervals.get(varStr));
			assertNull(split);

			split = assertInterval(6, 10, 2, intervals.get(varLength));
			assertNull(split);
		}
		{
			final List<LSInterval> fixedIntervals = List.of(
					LSInterval.testFixed(0, List.of(new LSRange(4, 6))),
					LSInterval.testFixed(1, List.of(new LSRange(4, 6))),
					LSInterval.testFixed(2, List.of(new LSRange(-1, 0), new LSRange(2, 5), new LSRange(8, 12))),
					LSInterval.testFixed(3, List.of(new LSRange(-1, 0), new LSRange(2, 5), new LSRange(8, 12))),
					LSInterval.testFixed(4, List.of(new LSRange(4, 5), new LSRange(10, 13))),
					LSInterval.testFixed(5, List.of(new LSRange(4, 5), new LSRange(10, 13)))
			);
			final Map<IRVar, LSInterval> intervals = LSAlgorithm.perform(varMap, fixedIntervals, 8, Z8_POINTER_INT_TYPE, new LSAlgorithmLoggerImpl(List.of()));
			assertEquals(2, intervals.size());

			LSInterval split = assertInterval(0, 8, 3, intervals.get(varStr));
			assertNull(split);

			split = assertInterval(6, 10, 2, intervals.get(varLength));
			assertNull(split);
		}
	}

	@Test
	public void test4() {
		// 0: move a, 1
		// 2: call foo
		// 4: move r1, a
		// 6: call bar
		final IRVar varA = new IRVar("a", 0, VariableScope.function, Type.I16);
		final LSInterval interval = LSInterval.testVar(varA, List.of(new LSRange(0, 4)),
		                                               List.of(write(0), read(4)));
		final Map<IRVar, LSInterval> intervals = LSAlgorithm.perform(toVarMap(interval),
		                                                             List.of(
				                                                             LSInterval.testFixed(0, List.of(new LSRange(2), new LSRange(6))),
				                                                             LSInterval.testFixed(1, List.of(new LSRange(2), new LSRange(4, 7)))
		                                                             ), 2, null, new LSAlgorithmLoggerImpl(List.of()));
		assertEquals(1, intervals.size());

		LSInterval split = assertInterval(0, 1, 0, intervals.get(varA));
		assertNotNull(split);
		split = assertInterval(1, 3, -1, split);
		assertNotNull(split);
		split = assertInterval(3, 4, 1, split);
		assertNull(split);
	}

	@Test
	public void test5() {
		// 0: const a, 1
		// 2: move r1, a
		// 4: call r0, foo(r1)
		// 6: move b, r0
		// 8: add a, b
		// 10: move r0, a
		final IRVar varA = new IRVar("a", 0, VariableScope.function, Type.I16);
		final IRVar varB = new IRVar("b", 1, VariableScope.function, Type.I16);
		final LSInterval iA = LSInterval.testVar(varA, List.of(new LSRange(0, 10)),
		                                         List.of(write(0), read(2), write(8), read(10)));
		final LSInterval iB = LSInterval.testVar(varB, List.of(new LSRange(6, 8)),
		                                         List.of(write(6), read(8)));
		final Map<IRVar, LSInterval> intervals = LSAlgorithm.perform(toVarMap(iA, iB),
		                                                             List.of(
				                                                             LSInterval.testFixed(0, List.of(new LSRange(4, 6), new LSRange(10))),
				                                                             LSInterval.testFixed(1, List.of(new LSRange(2, 5)))
		                                                             ), 2, null, new LSAlgorithmLoggerImpl(List.of()));
		assertEquals(2, intervals.size());

		// iA
		LSInterval split = assertInterval(0, 3, 1, intervals.get(varA));
		assertNotNull(split);
		split = assertInterval(3, 7, -1, split);
		assertNotNull(split);
		split = assertInterval(7, 10, 0, split);
		assertNull(split);

		// iB
		split = assertInterval(6, 8, 1, intervals.get(varB));
		assertNull(split);
	}

	@Test
	public void testSpilling1() {
		//                     a  b  one
		// 0: const one, 1     |  |   w
		// 2: add a, one       x  |   r
		// 4: sub b, one       |  x   r
		// 6: mul a, b         x  r
		// 8: move r0, a       r

		final IRVar varA = new IRVar("a", 0, VariableScope.parameter, Type.I16);
		final IRVar varB = new IRVar("b", 1, VariableScope.parameter, Type.I16);
		final IRVar var1 = new IRVar("one", 2, VariableScope.function, Type.I16);
		final LSInterval iA = LSInterval.testVar(varA, List.of(new LSRange(0, 8)),
		                                         List.of(write(2), write(6), read(8)));
		final LSInterval iB = LSInterval.testVar(varB, List.of(new LSRange(0, 6)),
		                                         List.of(write(4), read(6)));
		final LSInterval i1 = LSInterval.testVar(var1, List.of(new LSRange(0, 4)),
		                                         List.of(write(0), read(2), read(4)));
		final Map<IRVar, LSInterval> intervals = LSAlgorithm.perform(toVarMap(iA, iB, i1), List.of(), 2, null, LSAlgorithmLogger.DUMMY);
		assertEquals(3, intervals.size());

		// iA
		LSInterval split = assertInterval(0, 3, 0, intervals.get(varA));
		assertNotNull(split);
		split = assertInterval(3, 5, -1, split);
		assertNotNull(split);
		split = assertInterval(5, 8, 1, split);
		assertNull(split);

		// iB
		split = assertInterval(0, 3, -1, intervals.get(varB));
		assertNotNull(split);
		split = assertInterval(3, 6, 0, split);
		assertNull(split);

		// i1
		split = assertInterval(0, 4, 1, intervals.get(var1));
		assertNull(split);

		//    move r0(a), a
		// 0: const r1(one), 1
		// 2: add r0(a), r1(one)
		//    move a, r0(a)
		//    move r0(b), b  // parallel move!
		// 4: sub r0(b), r1(one)
		//    move r1(a), a
		// 6: mul r1(a), r0(b)
		// 8: move r0, r1(a)
	}

	@Test
	public void testSpilling2() {
		//                     a  b  one
		// 0: const one, 1     |  |   w
		// 2: add a, one       x  |   r
		// 4: const one, 1     |  |   w
		// 6: sub b, one       |  x   r
		// 8: add a, b         x  r

		final IRVar varA = new IRVar("a", 0, VariableScope.parameter, Type.I16);
		final IRVar varB = new IRVar("b", 1, VariableScope.parameter, Type.I16);
		final IRVar var1 = new IRVar("one", 2, VariableScope.function, Type.I16);
		final LSInterval iA = LSInterval.testVar(varA, List.of(new LSRange(0, 8)),
		                                         List.of(write(2), write(8)));
		final LSInterval iB = LSInterval.testVar(varB, List.of(new LSRange(0, 8)),
		                                         List.of(write(6), read(8)));
		final LSInterval i1 = LSInterval.testVar(var1, List.of(new LSRange(0, 6)),
		                                         List.of(write(0), read(2), write(4), read(6)));
		final Map<IRVar, LSInterval> intervals = LSAlgorithm.perform(toVarMap(iA, i1, iB), List.of(), 2, null, LSAlgorithmLogger.DUMMY);
		assertEquals(3, intervals.size());

		LSInterval split = assertInterval(0, 5, 0, intervals.get(varA));
		assertNotNull(split);
		split = assertInterval(5, 7, -1, split);
		assertNotNull(split);
		split = assertInterval(7, 8, 1, split);
		assertNull(split);

		// iB
		split = assertInterval(0, 5, -1, intervals.get(varB));
		assertNotNull(split);
		split = assertInterval(5, 8, 0, split);
		assertNull(split);

		// i1
		split = assertInterval(0, 6, 1, intervals.get(var1));
		assertNull(split);

		// move r0(a), a
		// 0: const r1(one), 1
		// 2: add r0(a), r1(one)
		// 4: const r1(one), 1
		// move a, r0(a)
		// move r0(b), b
		// 6: sub r0(b), r1(one)
		// move r1(a), a
		// 8: add r1(a), r0(b)
	}

	@Test
	public void testSpilling3() {
		//                    tmp  a   b   c
		//  0: const tmp = 1   w
		//  2: const a = 2     |   w
		//  4: a += tmp        r   x
		//  6: const b = 3         |   w
		//  8: const c = 4         |   |   w
		// 10: a += c              x   |   r
		// 12: a += b              x   r
		// 14: const tmp = 2   w   |
		// 16: a += tmp        r   x

		final IRVar varT = new IRVar("tmp", 0, VariableScope.function, Type.I16);
		final IRVar varA = new IRVar("a", 1, VariableScope.function, Type.I16);
		final IRVar varB = new IRVar("b", 2, VariableScope.function, Type.I16);
		final IRVar varC = new IRVar("c", 3, VariableScope.function, Type.I16);
		final LSInterval iT = LSInterval.testVar(varT, List.of(new LSRange(0, 4), new LSRange(14, 16)),
		                                         List.of(write(0), read(4), write(14), read(16)));
		final LSInterval iA = LSInterval.testVar(varA, List.of(new LSRange(2, 16)),
		                                         List.of(write(2), write(4), write(10), write(12), write(16)));
		final LSInterval iB = LSInterval.testVar(varB, List.of(new LSRange(6, 12)),
		                                         List.of(write(6), read(12)));
		final LSInterval iC = LSInterval.testVar(varC, List.of(new LSRange(8, 10)),
		                                         List.of(write(8), read(10)));
		final Map<IRVar, LSInterval> intervals = LSAlgorithm.perform(toVarMap(iT, iA, iB, iC), List.of(), 2, null, LSAlgorithmLogger.DUMMY);
		assertEquals(4, intervals.size());

		// iT
		LSInterval split = assertInterval(0, 16, 0, intervals.get(varT));
		assertNull(split);

		// iA
		split = assertInterval(2, 16, 1, intervals.get(varA));
		assertNull(split);

		// iB
		split = assertInterval(6, 8, 0, intervals.get(varB));
		assertNotNull(split);
		split = assertInterval(8, 11, -1, split);
		assertNotNull(split);
		split = assertInterval(11, 12, 0, split);
		assertNull(split);

		// iC
		split = assertInterval(8, 10, 0, intervals.get(varC));
		assertNull(split);
	}

	@Test
	public void testSpilling4() {
		//                    a   b   c   d
		//  0: const a, 1     w
		//  2: const b, 10    |   w
		//  4: add c, a, 1    r   |   w
		//  6: const d, 3         |   |   w
		//  8: add sum, c, d      |   r   r
		// 10: and a, d, 1    w   |       r
		// 12: lt flag, d, a  r   |       r
		// 14: if b               r
		final IRVar varA = new IRVar("a", 0, VariableScope.function, Type.I16);
		final IRVar varB = new IRVar("b", 1, VariableScope.function, Type.I16);
		final IRVar varC = new IRVar("c", 2, VariableScope.function, Type.I16);
		final IRVar varD = new IRVar("d", 3, VariableScope.function, Type.I16);
		final LSInterval iA = LSInterval.testVar(varA, List.of(new LSRange(0, 4), new LSRange(10, 12)),
		                                         List.of(write(0), read(4), write(10), read(12)));
		final LSInterval iB = LSInterval.testVar(varB, List.of(new LSRange(2, 14)),
		                                         List.of(write(2), read(14)));
		final LSInterval iC = LSInterval.testVar(varC, List.of(new LSRange(4, 8)),
		                                         List.of(write(4), read(8)));
		final LSInterval iD = LSInterval.testVar(varD, List.of(new LSRange(6, 12)),
		                                         List.of(write(6), read(8), read(12)));
		final Map<IRVar, LSInterval> intervals = LSAlgorithm.perform(toVarMap(iA, iB, iC, iD), List.of(), 2, null, LSAlgorithmLogger.DUMMY);
		assertEquals(4, intervals.size());

		// iA
		LSInterval split = assertInterval(0, 4, 0, intervals.get(varA));
		assertNotNull(split);
		split = assertInterval(10, 12, 0, split);
		assertNull(split);

		// iB
		split = assertInterval(2, 6, 1, intervals.get(varB));
		assertNotNull(split);
		split = assertInterval(6, 13, -1, split);
		assertNotNull(split);
		split = assertInterval(13, 14, 0, split);
		assertNull(split);

		// iC
		split = assertInterval(4, 8, 0, intervals.get(varC));
		assertNull(split);

		// iD
		split = assertInterval(6, 12, 1, intervals.get(varD));
		assertNull(split);
	}

	private Map<IRVar, LSInterval> toVarMap(LSInterval... intervals) {
		final Map<IRVar, LSInterval> varToInterval = new LinkedHashMap<>();
		for (LSInterval interval : intervals) {
			varToInterval.put(interval.var(), interval);
		}
		return varToInterval;
	}

	@Nullable
	private LSInterval assertInterval(int expectedFrom, int expectedTo, int expectedRegister, LSInterval interval) {
		assertEquals(expectedFrom, interval.getFrom());
		assertEquals(expectedTo, interval.getTo());
		assertEquals(expectedRegister, interval.register());
		return interval.getNextSplit();
	}
}
