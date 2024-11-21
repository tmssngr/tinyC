package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.cfg.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.junit.*;

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
		Assert.assertEquals(List.of(
				new BasicBlock("start", List.of(
						new IRJump("end")
				), List.of(), List.of("end")),

				new BasicBlock("end", List.of(
				), List.of("start"), List.of())
		), cfg.blocks());
	}

	@Test
	public void testCritialEdgeElimination() {
		final ControlFlowGraph cfg = CfgGenerator.create("start", List.of(
				new IRLabel("endlessloop"),
				new IRJump("endlessloop")
		));
		Assert.assertEquals(List.of(
				new BasicBlock("start", List.of(
						new IRJump("endlessloop")
				), List.of(), List.of("endlessloop")),

				new BasicBlock("endlessloop", List.of(
						new IRJump("@no_critical_edge_2")
				), List.of("start", "@no_critical_edge_2"), List.of("@no_critical_edge_2")),

				new BasicBlock("@no_critical_edge_2", List.of(
						new IRJump("endlessloop")
				), List.of("endlessloop"), List.of("endlessloop"))
		), cfg.blocks());
	}
}