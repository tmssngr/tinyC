package com.regnis.tinyc.ir.cfg;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.junit.*;

import static org.junit.Assert.*;

/**
 * @author Thomas Singer
 */
public class SsaFactoryTest {

	@Test
	public void testSimple() {
		final IRVar varA = new IRVar("a", 0, VariableScope.function, Type.I16);
		final IRVar varB = new IRVar("b", 1, VariableScope.function, Type.I16);
		final IRVar varA1 = new IRVar("a.1", 2, VariableScope.function, Type.I16);
		final IRVar varB1 = new IRVar("b.1", 3, VariableScope.function, Type.I16);

		final ControlFlowGraph cfg = CfgGenerator.create("simple", List.of(
				new IRBinary(varA, IRBinary.Op.Add, varA, 1),
				new IRBinary(varB, IRBinary.Op.Add, varA, varB)
		));
		DetectVarLiveness.process(cfg);

		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(), Set.of(), null);
		final IRVarInfos varInfos = new IRVarInfos(List.of(
				new IRVarDef(varA, 2),
				new IRVarDef(varB, 2)
		), Set.of(), globalVarInfos);

		final var result = SsaFactory.convert(cfg, varInfos);

		final Iterator<IRInstruction> i = result.first().iterator();
		assertEquals(new IRBinary(varA1, IRBinary.Op.Add, varA, 1), i.next());
		assertEquals(new IRBinary(varB1, IRBinary.Op.Add, varA1, varB), i.next());
		assertFalse(i.hasNext());

		final Iterator<IRVarDef> d = result.second().vars().iterator();
		assertEquals(new IRVarDef(varA, 2), d.next());
		assertEquals(new IRVarDef(varB, 2), d.next());
		assertEquals(new IRVarDef(varA1, 2), d.next());
		assertEquals(new IRVarDef(varB1, 2), d.next());
		assertFalse(d.hasNext());
	}

	@Test
	public void testIf() {
		final IRVar varA = new IRVar("a", 0, VariableScope.function, Type.I16);
		final IRVar varB = new IRVar("b", 1, VariableScope.function, Type.I16);
		final IRVar varA1 = new IRVar("a.1", 2, VariableScope.function, Type.I16);
		final IRVar varA2 = new IRVar("a.2", 3, VariableScope.function, Type.I16);
		final IRVar varA3 = new IRVar("a.3", 4, VariableScope.function, Type.I16);

		final ControlFlowGraph cfg = CfgGenerator.create("if", List.of(
				new IRBranch(IRCompare.Op.Lt, varB, 10, "then", "else"),
				new IRLabel("else"),
				new IRMove(varA, 10),
				new IRJump("end"),
				new IRLabel("then"),
				new IRMove(varA, 20),
				new IRLabel("end"),
				new IRCall(null, Type.VOID, "sink", List.of(new IRValue(varA)))
		));
		DetectVarLiveness.process(cfg);

		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(), Set.of(), null);
		final IRVarInfos varInfos = new IRVarInfos(List.of(
				new IRVarDef(varA, 2),
				new IRVarDef(varB, 2)
		), Set.of(), globalVarInfos);

		final var result = SsaFactory.convert(cfg, varInfos);

		final Iterator<IRInstruction> i = result.first().iterator();
		assertEquals(new IRBranch(IRCompare.Op.Lt, varB, 10, "then", "else"), i.next());
		assertEquals(new IRJump("else"), i.next());
		assertEquals(new IRLabel("then"), i.next());
		assertEquals(new IRMove(varA2, 20), i.next());
		assertEquals(new IRJump("end"), i.next());
		assertEquals(new IRLabel("else"), i.next());
		assertEquals(new IRMove(varA3, 10), i.next());
		assertEquals(new IRJump("end"), i.next());
		assertEquals(new IRLabel("end"), i.next());
		assertEquals(new IRPhi(varA1, List.of(varA2, varA3)), i.next());
		assertEquals(new IRCall(null, Type.VOID, "sink", List.of(new IRValue(varA))), i.next());
		assertFalse(i.hasNext());

		final Iterator<IRVarDef> d = result.second().vars().iterator();
		assertEquals(new IRVarDef(varA, 2), d.next());
		assertEquals(new IRVarDef(varB, 2), d.next());
		assertEquals(new IRVarDef(varA1, 2), d.next());
		assertEquals(new IRVarDef(varA2, 2), d.next());
		assertFalse(d.hasNext());
	}
}