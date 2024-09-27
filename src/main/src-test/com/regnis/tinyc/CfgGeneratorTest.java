package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.cfg.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;
import org.junit.*;

/**
 * @author Thomas Singer
 */
public class CfgGeneratorTest {

	@Test
	public void testRemovingRedundantCode() {
		final List<BasicBlock> blocks = CfgGenerator.createBlocks("start", List.of(
				new IRJump("end"),
				new IRLabel("redundant"),
				new IRLiteral(new IRVar("a", 0, VariableScope.function, Type.BOOL, true), 0, new Location(1, 1)),
				new IRLiteral(new IRVar("b", 1, VariableScope.function, Type.BOOL, true), 0, new Location(1, 1)),
				new IRLabel("end")
		));
		Assert.assertEquals(List.of(
				new BasicBlock("start", List.of(
						new IRJump("end")
				), List.of(), List.of("end")),
				new BasicBlock("end", List.of(
				), List.of("start"), List.of())
		), blocks);
	}

	@Test
	public void testPostOrderIterationA() {
		final List<BasicBlock> blocks = List.of(
				new BasicBlock("break",
				               BasicBlock.TEST_DUMMY_INSTRUCTIONS,
				               List.of("loop"),
				               List.of()),
				new BasicBlock("loop",
				               BasicBlock.TEST_DUMMY_INSTRUCTIONS,
				               List.of("start", "loop"),
				               List.of("loop", "break")),
				new BasicBlock("start",
				               BasicBlock.TEST_DUMMY_INSTRUCTIONS,
				               List.of(),
				               List.of("loop"))
		);
		final List<String> order = visitInPostOrder("start", blocks);
		Assert.assertEquals(List.of("start", "loop", "break"), order);
	}

	@Test
	public void testPostOrderIterationB() {
		final List<BasicBlock> blocks = List.of(
				new BasicBlock("start",
				               BasicBlock.TEST_DUMMY_INSTRUCTIONS,
				               List.of(),
				               List.of("loop")),
				new BasicBlock("loop",
				               BasicBlock.TEST_DUMMY_INSTRUCTIONS,
				               List.of("start", "body"),
				               List.of("body", "break")),
				new BasicBlock("body",
				               BasicBlock.TEST_DUMMY_INSTRUCTIONS,
				               List.of("loop"),
				               List.of("loop")),
				new BasicBlock("break",
				               List.of(),
				               List.of("loop"),
				               List.of())
		);
		final List<String> order = visitInPostOrder("start", blocks);
		Assert.assertEquals(List.of("start", "loop", "body", "break"), order);
	}

	@NotNull
	private static List<String> visitInPostOrder(String start, List<BasicBlock> blocks) {
		final List<String> order = new ArrayList<>();
		CfgGenerator.visitInPostOrder(start, blocks, block -> {
			final String name = block.name;
			if (block.successors.isEmpty()) {
				order.add(name);
			}
			else {
				order.addFirst(name);
			}
		});
		return order;
	}
}