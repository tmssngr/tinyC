package com.regnis.tinyc.ir.cfg;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;
import org.junit.*;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

/**
 * @author Thomas Singer
 */
public class CfgLoopInfosTest {

	@Test
	public void testNestedLoopOrder() {
		final Cfg cfg = new Cfg("a");
		add("a", List.of("bb"), cfg);
		add("bb", List.of("cc"), cfg);
		add("cc", List.of("ddd"), cfg);
		add("ddd", List.of("eee", "ff"), cfg);
		add("eee", List.of("ddd"), cfg);
		add("ff", List.of("bb", "g"), cfg);
		add("g", List.of("hh"), cfg);
		add("hh", List.of("ii", "j"), cfg);
		add("ii", List.of("hh"), cfg);
		add("j", List.of(), cfg);
		cfg.setPredecessors();
		final CfgLoopInfos infos = new CfgLoopInfos(cfg);
		final Map<String, Set<String>> loops = infos.getLoops();
		assertEquals(Map.of(
				"bb", Set.of("cc", "ddd", "eee", "ff"),
				"ddd", Set.of("eee"),
				"hh", Set.of("ii")
		), loops);
		final List<String> inOrder = infos.getInOrder();
		for (Map.Entry<String, Set<String>> loop : loops.entrySet()) {
			final String previous = inOrder.get(inOrder.indexOf(loop.getKey()) - 1);
			assertTrue(loop.getValue().contains(previous));
			assertTrue(cfg.get(previous).successors().contains(loop.getKey()));
		}
		final List<Pair<String, Integer>> nameToLoopLevel = new ArrayList<>();
		for (String name : inOrder) {
			nameToLoopLevel.add(pair(name, infos.getLoopLevel(name)));
		}
		assertEquals(List.of(
				pair("a", 0),
				pair("cc", 1),
				pair("eee", 2),
				pair("ddd", 2),
				pair("ff", 1),
				pair("bb", 1),
				pair("g", 0),
				pair("ii", 1),
				pair("hh", 1),
				pair("j", 0)
		), nameToLoopLevel);
	}

	@NotNull
	private Pair<String, Integer> pair(String name, int level) {
		return new Pair<>(name, level);
	}

	private void add(String name, List<String> successors, Cfg blocks) {
		blocks.add(new BasicBlock(name, BasicBlock.TEST_DUMMY_INSTRUCTIONS, List.of(), successors));
	}
}
