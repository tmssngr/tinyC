package com.regnis.tinyc;

import com.regnis.tinyc.ir.cfg.*;

import java.util.*;

import org.jetbrains.annotations.*;
import org.junit.*;

/**
 * @author Thomas Singer
 */
public class CfgTest {
	@Test
	public void testInOrderIterationA() {
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
		final List<String> order = visitInOrder(blocks);
		Assert.assertEquals(List.of("start", "loop", "break"), order);
	}

	@Test
	public void testLoopHeaderFollowsBody() {
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
		final List<String> order = visitInOrder(blocks);
		Assert.assertEquals(List.of("start", "body", "loop", "break"), order);
	}

	@Test
	public void testConditionalSuccessorAdjacency() {
		final Cfg cfg = new Cfg("start");
		add(cfg, "start", "split");
		add(cfg, "split", "left", "right");
		add(cfg, "left", "leftA", "leftB");
		add(cfg, "right", "rightA", "rightB");
		add(cfg, "leftA", "exit");
		add(cfg, "leftB", "exit");
		add(cfg, "rightA", "exit");
		add(cfg, "rightB", "exit");
		add(cfg, "exit");
		cfg.setPredecessors();

		final List<String> order = cfg.getInOrder();
		Assert.assertEquals(9, order.size());
		Assert.assertEquals(9, new HashSet<>(order).size());
		Assert.assertEquals("start", order.getFirst());
		Assert.assertEquals("exit", order.getLast());
		for (int index = 0; index < order.size() - 1; index++) {
			final BasicBlock block = cfg.get(order.get(index));
			if (block.successors().size() == 2) {
				Assert.assertTrue(block.name, block.successors().contains(order.get(index + 1)));
			}
		}
	}

	private static void add(Cfg cfg, String name, String... successors) {
		cfg.add(new BasicBlock(name, BasicBlock.TEST_DUMMY_INSTRUCTIONS, List.of(), List.of(successors)));
	}

	@NotNull
	private static List<String> visitInOrder(List<BasicBlock> blocks) {
		final Cfg cfg = new Cfg("start");
		for (BasicBlock block : blocks) {
			cfg.add(block);
		}

		return cfg.getInOrder();
	}
}
