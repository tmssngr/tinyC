package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.junit.*;

import static org.junit.Assert.*;

/**
 * @author Thomas Singer
 */
public class LSIntervalFactoryTest {

	static void assertEqualIntervals(List<LSInterval> expected, List<LSInterval> actual) {
		TestUtils.assertEquals(expected, actual,
		                       LSIntervalFactoryTest::assertEqualInterval);
	}

	static void assertEqualInterval(LSInterval expected, LSInterval actual) {
		assertEquals(expected.varNullable(), actual.varNullable());
		assertEquals(expected.register(), actual.register());
		LSRangeTest.assertEqualsRanges(expected.ranges(), actual.ranges());
		assertEquals(expected.uses(), actual.uses());
	}

	@Test
	public void testFunctionArgs() {
		final IRVar a = new IRVar("a", 0, VariableScope.argument, Type.I16);
		final IRVar b = new IRVar("b", 1, VariableScope.argument, Type.BOOL);
		final IRVar c = new IRVar("c", 2, VariableScope.argument, Type.I64);
		final IRVar d = new IRVar("d", 3, VariableScope.function, Type.I64);

		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(), Set.of(), null);
		final IRVarInfos varInfos = new IRVarInfos(List.of(
				new IRVarDef(a, 2),
				new IRVarDef(b, 1),
				new IRVarDef(c, 8),
				new IRVarDef(d, 8)
		), Set.of(), globalVarInfos);
		final LSIntervalFactory intervals = new LSIntervalFactory(varInfos, (targetType, argTypes) -> {
			throw new UnsupportedOperationException();
		}, 4, false);
		intervals.addFunctionArgs(varInfos, List.of(1, 2));
		assertEquals(List.of(), intervals.getInstructions());
		assertEqualIntervals(List.of(), intervals.getVarIntervalsSorted());
		assertEqualIntervals(List.of(
				LSInterval.testFixed(1,
				                     List.of(new LSRange(-1, 0))
				),
				LSInterval.testFixed(2,
				                     List.of(new LSRange(-1, 0))
				)
		), intervals.getFixedIntervals());
		assertEquals(List.of(), intervals.getInstructions());
		Map<String, LSIntervalFactory.Indices> blockToIndex = intervals.getBlockToIndex();
		assertTrue(blockToIndex.isEmpty());

		final LinkedHashSet<IRVar> live = new LinkedHashSet<>(List.of(
				c
		));
		// ====================================================================
		intervals.blockStart("start", live);
		// ====================================================================
		assertEquals(List.of(), intervals.getInstructions());
		assertEqualIntervals(List.of(
				LSInterval.testVar(c,
				                   List.of(new LSRange(0, 1)),
				                   List.of()
				)
		), intervals.getVarIntervalsSorted());
		// remains the same
		assertEqualIntervals(List.of(
				LSInterval.testFixed(1,
				                     List.of(new LSRange(-1, 0))
				),
				LSInterval.testFixed(2,
				                     List.of(new LSRange(-1, 0))
				)
		), intervals.getFixedIntervals());

		blockToIndex = intervals.getBlockToIndex();
		assertEquals(1, blockToIndex.size());
		assertEquals(0, blockToIndex.get("start").start());
		assertEquals(0, blockToIndex.get("start").end());

		// ====================================================================
		// 0
		intervals.addInstruction(new IRMove(a, a.asRegister(1), Location.DUMMY), live);
		// ====================================================================
		assertEquals(List.of(
				new IRMove(a, a.asRegister(1), Location.DUMMY)
		), intervals.getInstructions());
		assertEqualIntervals(List.of(
				LSInterval.testVar(c,
				                   List.of(new LSRange(0, 2)),
				                   List.of()
				),
				LSInterval.testVar(a,
				                   List.of(new LSRange(1)),
				                   List.of(LSUse.write(1))
				)
		), intervals.getVarIntervalsSorted());
		assertEqualIntervals(List.of(
				LSInterval.testFixed(1,
				                     List.of(new LSRange(-1, 1))
				),
				LSInterval.testFixed(2,
				                     List.of(new LSRange(-1))
				)
		), intervals.getFixedIntervals());

		blockToIndex = intervals.getBlockToIndex();
		assertEquals(1, blockToIndex.size());
		assertEquals(0, blockToIndex.get("start").start());
		assertEquals(2, blockToIndex.get("start").end());

		live.add(a);

		// ====================================================================
		// 2
		intervals.addInstruction(new IRMove(b, b.asRegister(2), Location.DUMMY), live);
		// ====================================================================
		assertEquals(List.of(
				new IRMove(a, a.asRegister(1), Location.DUMMY),
				new IRMove(b, b.asRegister(2), Location.DUMMY)
		), intervals.getInstructions());
		assertEqualIntervals(List.of(
				LSInterval.testVar(c,
				                   List.of(new LSRange(0, 4)),
				                   List.of()
				),
				LSInterval.testVar(a,
				                   List.of(new LSRange(1, 4)),
				                   List.of(LSUse.write(1))
				),
				LSInterval.testVar(b,
				                   List.of(new LSRange(3)),
				                   List.of(LSUse.write(3))
				)
		), intervals.getVarIntervalsSorted());
		assertEqualIntervals(List.of(
				LSInterval.testFixed(1,
				                     List.of(new LSRange(-1, 1))
				),
				LSInterval.testFixed(2,
				                     List.of(new LSRange(-1, 3))
				)
		), intervals.getFixedIntervals());

		blockToIndex = intervals.getBlockToIndex();
		assertEquals(1, blockToIndex.size());
		assertEquals(0, blockToIndex.get("start").start());
		assertEquals(4, blockToIndex.get("start").end());
	}

	@Test
	public void testCall() {
		final IRVar a = new IRVar("a", 0, VariableScope.function, Type.I64);

		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(), Set.of(), null);
		final IRVarInfos varInfos = new IRVarInfos(List.of(
				new IRVarDef(a, 8)
		), Set.of(), globalVarInfos);
		final LSIntervalFactory intervals = new LSIntervalFactory(varInfos, (targetType, argTypes) -> {
			assertEquals(Type.VOID, targetType);
			assertEquals(List.of(Type.I64), argTypes);
			return new LSCallingConvention(List.of(), 4);
		}, 5, false);
		intervals.addFunctionArgs(varInfos, List.of());
		assertEquals(List.of(), intervals.getInstructions());
		assertEqualIntervals(List.of(), intervals.getVarIntervalsSorted());
		assertEqualIntervals(List.of(), intervals.getFixedIntervals());
		assertEquals(List.of(), intervals.getInstructions());
		assertTrue(intervals.getBlockToIndex().isEmpty());

		final LinkedHashSet<IRVar> liveAfter = new LinkedHashSet<>(List.of());
		liveAfter.add(a);
		// ====================================================================
		// 0
		intervals.addInstruction(new IRLiteral(a, 10, Location.DUMMY), liveAfter);
		// ====================================================================
		assertEquals(List.of(
				new IRLiteral(a, 10, Location.DUMMY)
		), intervals.getInstructions());
		assertEqualIntervals(List.of(
				LSInterval.testVar(a,
				                   List.of(new LSRange(1)),
				                   List.of(LSUse.write(1))
				)
		), intervals.getVarIntervalsSorted());
		assertEqualIntervals(List.of(), intervals.getFixedIntervals());

		// ====================================================================
		// 2
		intervals.addInstruction(new IRMove(a.asRegister(1), a, Location.DUMMY), liveAfter);
		// ====================================================================
		assertEquals(List.of(
				new IRLiteral(a, 10, Location.DUMMY),
				new IRMove(a.asRegister(1), a, Location.DUMMY)
		), intervals.getInstructions());
		assertEqualIntervals(List.of(
				LSInterval.testVar(a,
				                   List.of(new LSRange(1, 4)),
				                   List.of(LSUse.write(1),
				                           LSUse.read(2))
				)
		), intervals.getVarIntervalsSorted());
		assertEqualIntervals(List.of(
				LSInterval.testFixed(1,
				                     List.of(new LSRange(3))
				)
		), intervals.getFixedIntervals());

		liveAfter.remove(a);
		// ====================================================================
		// 4
		intervals.addInstruction(new IRCall(null, Type.VOID, "foo", List.of(a.asRegister(1)), Location.DUMMY), liveAfter);
		// ====================================================================
		assertEquals(List.of(
				new IRLiteral(a, 10, Location.DUMMY),
				new IRMove(a.asRegister(1), a, Location.DUMMY),
				new IRCall(null, Type.VOID, "foo", List.of(a.asRegister(1)), Location.DUMMY)
		), intervals.getInstructions());
		assertEqualIntervals(List.of(
				LSInterval.testVar(a,
				                   List.of(new LSRange(1, 4)),
				                   List.of(LSUse.write(1),
				                           LSUse.read(2))
				)
		), intervals.getVarIntervalsSorted());
		assertEqualIntervals(List.of(
				LSInterval.testFixed(0,
				                     List.of(new LSRange(4, 5))
				),
				LSInterval.testFixed(1,
				                     List.of(new LSRange(3, 5))
				),
				LSInterval.testFixed(2,
				                     List.of(new LSRange(4, 5))
				),
				LSInterval.testFixed(3,
				                     List.of(new LSRange(4, 5))
				)
		), intervals.getFixedIntervals());
	}
}