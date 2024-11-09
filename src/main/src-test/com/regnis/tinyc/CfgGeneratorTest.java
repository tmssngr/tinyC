package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.cfg.*;
import com.regnis.tinyc.ir.*;

import java.util.*;
import java.util.function.*;

import org.junit.*;

import static org.junit.Assert.assertEquals;

/**
 * @author Thomas Singer
 */
public class CfgGeneratorTest {

	@Test
	public void testRemovingRedundantCode() {
		final ControlFlowGraph cfg = CfgGenerator.create("start", List.of(
				new IRJump("end"),
				new IRLabel("redundant"),
				new IRLiteral(new IRVar("a", 0, VariableScope.function, Type.BOOL), 0, new Location(1, 1)),
				new IRLiteral(new IRVar("b", 1, VariableScope.function, Type.BOOL), 0, new Location(1, 1)),
				new IRLabel("end")
		));
		assertEquals(List.of(
				new BasicBlock("start", List.of(
						new IRJump("end")
				), List.of(), List.of("end")),

				new BasicBlock("end", List.of(
				), List.of("start"), List.of())
		), cfg.blocks());
	}

	@Test
	public void testNoCritialEdgeElimination() {
		final ControlFlowGraph cfg = CfgGenerator.create("start", List.of(
				new IRLabel("endlessloop"),
				new IRJump("endlessloop")
		));
		assertEquals(List.of(
				new BasicBlock("start", List.of(
						new IRJump("endlessloop")
				), List.of(), List.of("endlessloop")),

				new BasicBlock("endlessloop", List.of(
						new IRJump("endlessloop")
				), List.of("start", "endlessloop"), List.of("endlessloop"))
		), cfg.blocks());
	}

	@Test
	public void testCritialEdgeElimination() {
		final IRVar cond = new IRVar("cond", 2, VariableScope.function, Type.BOOL);
		final ControlFlowGraph cfg = CfgGenerator.create("start", List.of(
				new IRLabel("loop"),
				new IRCall(cond, "getSomething", List.of(), Location.DUMMY),
				new IRBranch(cond, false, "loop", "break")
		));
		assertEqualsBlocks(List.of(
				new BasicBlock("start", List.of(
						new IRJump("loop")
				), List.of(), List.of("loop")),

				new BasicBlock("@no_critical_edge_3", List.of(
						new IRJump("loop")
				), List.of("loop"), List.of("loop")),

				new BasicBlock("loop", List.of(
						new IRCall(cond, "getSomething", List.of(), Location.DUMMY),
						new IRBranch(cond, false, "@no_critical_edge_3", ""),
						new IRJump("break")
				), List.of("start", "@no_critical_edge_3"), List.of("@no_critical_edge_3", "break")),

				new BasicBlock("break", List.of(
				), List.of("loop"), List.of())
		), cfg.blocks());
	}

	private void assertEqualsBlocks(List<BasicBlock> expected, List<BasicBlock> actual) {
		TestUtils.assertEquals(expected, actual, this::assertEqualsBlock);
	}

	private void assertEqualsBlock(BasicBlock expected, BasicBlock actual) {
		assertEquals(expected.name, actual.name);
		assertEquals(expected.predecessors(), actual.predecessors());
		assertEquals(expected.successors(), actual.successors());
		TestUtils.assertEquals(expected.instructions(), actual.instructions(), Assert::assertEquals);
		assertEquals(expected, actual);
	}
}