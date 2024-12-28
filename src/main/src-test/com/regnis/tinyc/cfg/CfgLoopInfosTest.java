package com.regnis.tinyc.cfg;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;
import org.junit.*;

import static org.junit.Assert.assertEquals;

/**
 * @author Thomas Singer
 */
public class CfgLoopInfosTest {

	@Test
	public void testNestedIfs() {
		final Cfg cfg = new Cfg("getSpacer");
		add("getSpacer", List.of("then1", "nce"), cfg);
		add("then1", List.of("then2", "end2"), cfg);
		add("nce", List.of("end1"), cfg);
		add("then2", List.of("ret"), cfg);
		add("end2", List.of("then3", "end3"), cfg);
		add("then3", List.of("ret"), cfg);
		add("end3", List.of("end1"), cfg);
		add("end1", List.of("ret"), cfg);
		add("ret", List.of(), cfg);
		cfg.setPredecessors();
		final CfgLoopInfos infos = new CfgLoopInfos(cfg);

		final List<CfgLoopInfos.BlockPath> paths = infos.getBlockPaths();
		final CfgLoopInfos.BlockPath root = new CfgLoopInfos.BlockPath("getSpacer");
		assertEquals(List.of(
				root.resolve("nce").resolve("end1").resolve("ret"),
				root.resolve("then1").resolve("end2").resolve("end3").resolve("end1").resolve("ret"),
				root.resolve("then1").resolve("end2").resolve("then3").resolve("ret"),
				root.resolve("then1").resolve("then2").resolve("ret")
		), paths);

		final List<String> order3 = infos.detectOrder3();

		final List<String> inOrder = infos.getBlocksInOrder2();
		assertEquals(List.of(
				"getSpacer",
				"then1",
				"then2",
				"end2",
				"then3",
				"end3",
				"end1",
				"nce",
				"ret"

		), inOrder);
	}

	@Test
	public void testSimpleLoop() {
		final Cfg cfg = new Cfg("start");
		add("start", List.of("loop"), cfg);
		add("loop", List.of("break", "body"), cfg);
		add("body", List.of("loop"), cfg);
		add("break", List.of(), cfg);
		cfg.setPredecessors();
		final CfgLoopInfos infos = new CfgLoopInfos(cfg);

		final List<String> order3 = infos.detectOrder3();

		final List<CfgLoopInfos.BlockPath> paths = infos.getBlockPaths();
		final CfgLoopInfos.BlockPath root = new CfgLoopInfos.BlockPath("start");
		assertEquals(List.of(
				root.resolve("loop").resolve("body").resolve("loop"),
				root.resolve("loop").resolve("break")
		), paths);

		final List<String> inOrder = infos.getBlocksInOrder2();
	}

	@Test
	public void testNestedLoop() {
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
		assertEquals(Map.of(
				"bb", Set.of("cc", "ddd", "eee", "ff"),
				"ddd", Set.of("eee"),
				"hh", Set.of("ii")
		), infos.getLoops());
		final List<String> inOrder = infos.getInOrder();
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