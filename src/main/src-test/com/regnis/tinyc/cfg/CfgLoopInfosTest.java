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
		add("getSpacer", List.of("then11", "nce8"), cfg);
		add("then11", List.of("then12", "end12"), cfg);
		add("nce8", List.of("end11"), cfg);
		add("then12", List.of("ret"), cfg);
		add("end12", List.of("then13", "end13"), cfg);
		add("then13", List.of("ret"), cfg);
		add("end13", List.of("end11"), cfg);
		add("end11", List.of("ret"), cfg);
		add("ret", List.of(), cfg);
		cfg.setPredecessors();
		final CfgLoopInfos infos = new CfgLoopInfos(cfg);
		final List<String> inOrder = infos.getInOrder();
		assertEquals(List.of(
				"getSpacer",
				"then11",
				"then12",
				"end12",
				"then13",
				"end13",
				"end11",
				"nce8",
				"ret"

		), inOrder);
	}

	@Test
	public void testLoop() {
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