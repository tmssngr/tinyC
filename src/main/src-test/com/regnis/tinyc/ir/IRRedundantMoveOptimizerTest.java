package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.linearscanregalloc.*;

import java.util.*;

import org.junit.*;

import static org.junit.Assert.assertEquals;

/**
 * @author Thomas Singer
 */
public class IRRedundantMoveOptimizerTest {

	@Test
	public void testRedundantMoves() {
		final IRVar a = new IRVar("a", 0, VariableScope.function, Type.I16);
		final IRVar b = new IRVar("b", 1, VariableScope.function, Type.I16);
		checkOptimize(List.of(
				new IRMove(a.asRegister(1), a, Location.DUMMY),
				new IRCall(null, "foo", List.of(a.asRegister(1)), Location.DUMMY)
		), List.of(
				new IRMove(a.asRegister(1), a, Location.DUMMY),
				new IRMove(a, a.asRegister(1), Location.DUMMY),
				new IRCall(null, "foo", List.of(a.asRegister(1)), Location.DUMMY),
				new IRMove(a.asRegister(1), a, Location.DUMMY)
		));
	}

	private void checkOptimize(List<IRInstruction> expected, List<IRInstruction> input) {
		final List<IRInstruction> instructions = new ArrayList<>(input);
		final IRRedundantMoveOptimizer optimizer = new IRRedundantMoveOptimizer(LSArchitecture.WIN_X86_64);
		optimizer.optimize(instructions);
		assertEquals(expected, instructions);
	}
}