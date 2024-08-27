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
}