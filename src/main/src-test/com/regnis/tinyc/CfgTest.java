package com.regnis.tinyc;

import com.regnis.tinyc.cfg.*;

import java.util.*;

import org.jetbrains.annotations.*;
import org.junit.*;

/**
 * @author Thomas Singer
 */
public class CfgTest {
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
		final List<String> order = visitInPostOrder(blocks);
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
		final List<String> order = visitInPostOrder(blocks);
		Assert.assertEquals(List.of("start", "loop", "body", "break"), order);
	}

	@NotNull
	private static List<String> visitInPostOrder(List<BasicBlock> blocks) {
		final Cfg cfg = new Cfg("start");
		for (BasicBlock block : blocks) {
			cfg.add(block);
		}

		return cfg.getInOrder();
	}
}
