package com.regnis.tinyc.cfg;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.junit.*;

import static org.junit.Assert.*;

/**
 * @author Thomas Singer
 */
public class DetectVarLivenessTest {

	@Test
	public void testLivenessInLoop() {
		final IRVar bool_needsInitialize = new IRVar("needsInitialize", 0, VariableScope.function, Type.BOOL);
		final IRVar bool_exit = new IRVar("exit", 1, VariableScope.function, Type.BOOL);
		final ControlFlowGraph cfg = CfgGenerator.create("main", List.of(
				new IRLiteral(bool_needsInitialize, 1),
				new IRLabel("loop"),
				new IRCall(bool_exit, Type.BOOL, "isExit", List.of()),
				new IRBranch(bool_exit, true, "exit", "1"),
				new IRLabel("1"),
				new IRBranch(bool_needsInitialize, false, "3", "2"),
				new IRLabel("2"),
				new IRLiteral(bool_needsInitialize, 0),
				new IRCall(null, Type.VOID, "doSomething", List.of()),
				new IRLabel("3"),
				new IRJump("loop"),
				new IRLabel("exit")
		));
		DetectVarLiveness.process(cfg);
		final Iterator<BasicBlock> it = cfg.blocks().iterator();
		assertBlock("main", List.of(
				            new IRLiteral(bool_needsInitialize, 1),
				            new IRJump("loop")
		            ),
		            Set.of(),
		            Set.of(bool_needsInitialize), it.next());
		assertBlock("1", List.of(
				            new IRBranch(bool_needsInitialize, false, "@no_critical_edge_6", "2"),
				            new IRJump("2")
		            ),
		            Set.of(bool_needsInitialize),
		            Set.of(bool_needsInitialize), it.next());
		assertBlock("@no_critical_edge_6", List.of(
				            new IRJump("3")
		            ),
		            Set.of(bool_needsInitialize),
		            Set.of(bool_needsInitialize), it.next());
		assertBlock("2", List.of(
				            new IRLiteral(bool_needsInitialize, 0),
				            new IRCall(null, Type.VOID, "doSomething", List.of()),
				            new IRJump("3")
		            ),
		            Set.of(),
		            Set.of(bool_needsInitialize), it.next());
		assertBlock("3", List.of(
				            new IRJump("loop")
		            ),
		            Set.of(bool_needsInitialize),
		            Set.of(bool_needsInitialize), it.next());
		assertBlock("loop", List.of(
				            new IRCall(bool_exit, Type.BOOL, "isExit", List.of()),
				            new IRBranch(bool_exit, true, "exit", "1"),
				            new IRJump("1")
		            ),
		            Set.of(bool_needsInitialize),
		            Set.of(bool_needsInitialize), it.next());
		assertBlock("exit", List.of(), Set.of(), Set.of(), it.next());
		assertFalse(it.hasNext());
	}

	private void assertBlock(String expectedName, List<? extends Record> expectedInstructions, Set<Object> expectedLiveBefore, Set<Object> expectedLiveAfter, BasicBlock block) {
		assertEquals(expectedName, block.name);
		assertEquals(expectedInstructions, block.instructions());
		assertEquals("live before", expectedLiveBefore, block.getLiveBefore());
		assertEquals("live after", expectedLiveAfter, block.getLiveAfter());
	}
}