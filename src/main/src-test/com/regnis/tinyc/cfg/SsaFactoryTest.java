package com.regnis.tinyc.cfg;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.junit.*;

/**
 * @author Thomas Singer
 */
public class SsaFactoryTest {

	@Test
	public void testSsa() {
		final IRVar varI = new IRVar("i", 0, VariableScope.function, Type.U8);
		final IRVar varTmp = new IRVar("tmp", 1, VariableScope.function, Type.U8);
		final IRVar varBool = new IRVar("bool", 2, VariableScope.function, Type.BOOL);
		final ControlFlowGraph cfg = CfgGenerator.create("test", List.of(
				new IRLiteral(varI, 0, Location.DUMMY),
				new IRLabel("loopHeader"),
				new IRLiteral(varTmp, 10, Location.DUMMY),
				new IRCompare(varBool, IRCompare.Op.Lt, varI, varTmp, Location.DUMMY),
				new IRBranch(varBool, false, "break", "loop"),
				new IRLabel("loop"),
				new IRLiteral(varTmp, 1, Location.DUMMY),
				new IRBinary(varI, IRBinary.Op.Add, varI, varTmp, Location.DUMMY),
				new IRJump("loopHeader"),
				new IRLabel("break")
		));
		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(), Set.of(), null);
		final IRVarInfos varInfos = new IRVarInfos(List.of(
				new IRVarDef(varI, 1),
				new IRVarDef(varTmp, 1),
				new IRVarDef(varBool, 1)
		), Set.of(), globalVarInfos);
		final SsaFactory factory = new SsaFactory(cfg, varInfos);
		final ControlFlowGraph ssa = factory.perform();
	}
}