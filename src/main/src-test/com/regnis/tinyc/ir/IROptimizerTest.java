package com.regnis.tinyc.ir;

import com.regnis.tinyc.ast.*;

import java.util.*;
import java.util.function.*;

import org.jetbrains.annotations.*;
import org.junit.*;

import static org.junit.Assert.*;

/**
 * @author Thomas Singer
 */
public class IROptimizerTest {

	@Test
	public void testRemoveObsoleteLabelJump() {
		final IRVar condition = new IRVar("condition", 0, VariableScope.function, Type.BOOL);
		final List<IRInstruction> optimized = IROptimizer.removeObsoleteLabelJump(List.of(
				new IRLabel("while"),
				new IRBranch(condition, false, "if_6_end", "if_6_then"),
				new IRLabel("if_6_then"),
				new IRJump("while_break"),
				new IRLabel("if_6_end"),
				new IRBranch(condition, false, "if_7_end", "if_7_then"),
				new IRLabel("if_7_then"),
				new IRCall(null, Type.VOID, "something", List.of()),
				new IRLabel("if_7_end"),
				new IRJump("while"),
				new IRLabel("while_break")
		));
		final Iterator<IRInstruction> it = optimized.iterator();
		assertEquals(new IRLabel("while"), it.next());
		assertEquals(new IRBranch(condition, false, "if_6_end", "while_break"), it.next());
		assertEquals(new IRJump("while_break"), it.next());
		assertEquals(new IRLabel("if_6_end"), it.next());
		assertEquals(new IRBranch(condition, false, "while", "if_7_then"), it.next());
		assertEquals(new IRLabel("if_7_then"), it.next());
		assertEquals(new IRCall(null, Type.VOID, "something", List.of()), it.next());
		assertEquals(new IRJump("while"), it.next());
		assertEquals(new IRLabel("while_break"), it.next());
		assertFalse(it.hasNext());
	}

	@Test
	public void testCollapsedBranches() {
		final IRVar varA = new IRVar("a", 0, VariableScope.register, Type.U8);
		final IRVar varB = new IRVar("b", 1, VariableScope.register, Type.U8);
		final List<IRInstruction> optimized = IROptimizer.optimize(List.of(
				new IRMove(varA, varB),
				new IRBranch(IRCompare.Op.Equals, varA, 1, "then", "next"),
				new IRJump("next"),
				new IRLabel("next"),
				new IRMove(varA, varB),
				new IRLabel("then")
		));
		final Iterator<IRInstruction> it = optimized.iterator();
		assertEquals(new IRMove(varA, varB), it.next());
		assertEquals(new IRBranch(IRCompare.Op.Equals, varA, 1, "then", ""), it.next());
		assertEquals(new IRMove(varA, varB), it.next());
		assertEquals(new IRLabel("then"), it.next());
		assertFalse(it.hasNext());
	}
}