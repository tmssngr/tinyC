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
public class LSAlgorithmTest {

	@Test
	public void test1() {
		// 0: a = 1
		// 2: mov r0, a
		final IRVar varA = new IRVar("a", 0, VariableScope.function, Type.I16);
		final LSAlgorithm algorithm = new LSAlgorithm(List.of(
				LSInterval.testVar(varA, List.of(new LSRange(1, 3)), List.of(LSUse.write(1),
				                                                             LSUse.read(2)))
		), List.of(), 4);

		final Map<IRVar, LSVarRegisters> result = algorithm.run();
		assertEquals(1, result.size());
		final LSVarRegisters registers = result.get(varA);
		assertEqualsRegisterOrState(LSVarRegisters.NOT_LIVE, registers, 0, 1);
		assertEqualsRegisterOrState(0, registers, 1, 3);
		assertEqualsRegisterOrState(LSVarRegisters.NOT_LIVE, registers, 3, 10);

		assertNoTransition(registers, 0, 20);
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
		final LSAlgorithm algorithm = new LSAlgorithm(List.of(
				LSInterval.testVar(varStr,
				                   List.of(new LSRange(1, 9)),
				                   List.of(LSUse.write(1),
				                           LSUse.read(2),
				                           LSUse.read(8)
				                   )),
				LSInterval.testVar(varLength,
				                   List.of(new LSRange(7, 11)),
				                   List.of(LSUse.write(7),
				                           LSUse.read(10)
				                   ))
		), List.of(
				LSInterval.testFixed(0, List.of(new LSRange(4, 6))),
				LSInterval.testFixed(1, List.of(new LSRange(-1, 0), new LSRange(2, 5), new LSRange(8, 12))),
				LSInterval.testFixed(2, List.of(new LSRange(4, 5), new LSRange(10, 13)))
		), 4);

		final Map<IRVar, LSVarRegisters> result = algorithm.run();
		assertEquals(2, result.size());

		LSVarRegisters registers = result.get(varStr);
		assertEqualsRegisterOrState(LSVarRegisters.NOT_LIVE, registers, 0, 1);
		assertEqualsRegisterOrState(3, registers, 1, 9);
		assertEqualsRegisterOrState(LSVarRegisters.NOT_LIVE, registers, 9, 20);

		registers = result.get(varLength);
		assertEqualsRegisterOrState(LSVarRegisters.NOT_LIVE, registers, 0, 7);
		assertEqualsRegisterOrState(0, registers, 7, 11);
		assertEqualsRegisterOrState(LSVarRegisters.NOT_LIVE, registers, 11, 20);

		assertNoTransition(registers, 0, 20);
	}

	@Test
	public void test3() {
		// 0: move a, 1
		// 2: call foo
		// 4: move r1, a
		// 6: call bar
		final IRVar varA = new IRVar("a", 0, VariableScope.function, Type.I16);
		final LSAlgorithm algorithm = new LSAlgorithm(List.of(
				LSInterval.testVar(varA,
				                   List.of(new LSRange(1, 5)),
				                   List.of(LSUse.write(1),
				                           LSUse.read(4)
				                   ))
		), List.of(
				LSInterval.testFixed(0, List.of(new LSRange(2), new LSRange(6))),
				LSInterval.testFixed(1, List.of(new LSRange(2), new LSRange(5, 7)))
		), 2);

		final Map<IRVar, LSVarRegisters> result = algorithm.run();
		assertEquals(1, result.size());

		final LSVarRegisters registers = result.get(varA);
		assertEqualsRegisterOrState(LSVarRegisters.NOT_LIVE, registers, 0, 1);
		assertEqualsRegisterOrState(0, registers, 1, 2);
		assertEqualsRegisterOrState(LSVarRegisters.NOT_REGISTER, registers, 2, 4);
		assertEqualsRegisterOrState(1, registers, 4, 5);
		assertEqualsRegisterOrState(LSVarRegisters.NOT_LIVE, registers, 5, 20);

		assertNoTransition(registers, 0, 2);
		assertEquals(new Pair<>(varA.asRegister(0), varA), registers.getTransitionAt(2));
		assertNoTransition(registers, 3, 4);
		assertEquals(new Pair<>(varA, varA.asRegister(1)), registers.getTransitionAt(4));
		assertNoTransition(registers, 5, 20);
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
		final LSAlgorithm algorithm = new LSAlgorithm(List.of(
				LSInterval.testVar(varA,
				                   List.of(new LSRange(1, 9), new LSRange(9, 11)),
				                   List.of(LSUse.write(1),
				                           LSUse.read(2),
				                           LSUse.read(8),
				                           LSUse.write(9),
				                           LSUse.read(10)
				                   )),
				LSInterval.testVar(varB,
				                   List.of(new LSRange(7, 9)),
				                   List.of(LSUse.write(7),
				                           LSUse.read(8)
				                   ))
		), List.of(
				LSInterval.testFixed(0, List.of(new LSRange(4, 7), new LSRange(11, 12))),
				LSInterval.testFixed(1, List.of(new LSRange(3, 5)))
		), 2);

		final Map<IRVar, LSVarRegisters> result = algorithm.run();
		assertEquals(2, result.size());

		LSVarRegisters registers = result.get(varA);
		assertEqualsRegisterOrState(LSVarRegisters.NOT_LIVE, registers, 0, 1);
		assertEqualsRegisterOrState(0, registers, 1, 4);
		assertEqualsRegisterOrState(LSVarRegisters.NOT_REGISTER, registers, 4, 8);
		assertEqualsRegisterOrState(0, registers, 8, 11);
		assertEqualsRegisterOrState(LSVarRegisters.NOT_LIVE, registers, 11, 20);

		assertNoTransition(registers, 0, 4);
		assertEquals(new Pair<>(varA.asRegister(0), varA), registers.getTransitionAt(4));
		assertNoTransition(registers, 5, 8);
		assertEquals(new Pair<>(varA, varA.asRegister(0)), registers.getTransitionAt(8));
		assertNoTransition(registers, 9, 20);

		registers = result.get(varB);
		assertEqualsRegisterOrState(LSVarRegisters.NOT_LIVE, registers, 0, 7);
		assertEqualsRegisterOrState(1, registers, 7, 9);
		assertEqualsRegisterOrState(LSVarRegisters.NOT_LIVE, registers, 9, 20);
	}

	private void assertEqualsRegisterOrState(int expectedRegisterOrState, LSVarRegisters registers, int from, int to) {
		for (int i = from; i < to; i++) {
			assertEquals(expectedRegisterOrState, registers.getRegisterOrState(from));
		}
	}

	private void assertNoTransition(LSVarRegisters registers, int from, int to) {
		for (int i = from; i < to; i++) {
			final Pair<IRVar, IRVar> transition = registers.getTransitionAt(i);
			assertNull(transition);
		}
	}
}