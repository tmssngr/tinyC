package com.regnis.tinyc.ir;

import com.regnis.tinyc.ast.*;

import java.util.*;

import org.junit.*;

import static org.junit.Assert.*;

/**
 * @author Thomas Singer
 */
public class IRNonLocalVarLoweringConverterLayerTest {

	@Test
	public void testGlobalRead() {
		final IRVar varGlobal = new IRVar("global", 0, VariableScope.global, Type.I16);

		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(
				new IRVarDef(varGlobal, 2)
		), Set.of(), null);
		final IRVarInfos localVarInfos = new IRVarInfos(List.of(), Set.of(), globalVarInfos);

		final var result = new IRConverterResultLayer();

		final IRLocalVarFactory tempVarFactory = new IRLocalVarFactory(localVarInfos, Type.I64);
		final IRNonLocalVarLoweringConverterLayer preprocessor = new IRNonLocalVarLoweringConverterLayer(tempVarFactory, result);
		IRConverterLayer.process(preprocessor, List.of(
				new IRRetValue(varGlobal)
		));

		final IRVar varAddr = new IRVar(IRNonLocalVarLoweringConverterLayer.ADDR_PREFIX + "global", 0, VariableScope.function, Type.pointer(Type.I16));
		final IRVar varLocal = new IRVar(IRNonLocalVarLoweringConverterLayer.TMP_PREFIX + "global", 1, VariableScope.function, Type.I16);

		final Iterator<IRInstruction> i = result.instructions.iterator();
		assertEquals(new IRAddrOf(varAddr, varGlobal), i.next());
		assertEquals(new IRMemLoad(varLocal, varAddr), i.next());
		assertEquals(new IRRetValue(varLocal), i.next());
		assertFalse(i.hasNext());

		final Iterator<IRVarDef> d = tempVarFactory.createVarInfos().vars().iterator();
		assertEquals(new IRVarDef(varAddr, 8), d.next());
		assertEquals(new IRVarDef(varLocal, 2), d.next());
		assertFalse(d.hasNext());
	}

	@Test
	public void testGlobalWrite() {
		final IRVar varGlobal = new IRVar("global", 0, VariableScope.global, Type.I16);

		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(
				new IRVarDef(varGlobal, 2)
		), Set.of(), null);
		final IRVarInfos localVarInfos = new IRVarInfos(List.of(), Set.of(), globalVarInfos);

		final var result = new IRConverterResultLayer();

		final IRLocalVarFactory tempVarFactory = new IRLocalVarFactory(localVarInfos, Type.I64);
		final IRNonLocalVarLoweringConverterLayer preprocessor = new IRNonLocalVarLoweringConverterLayer(tempVarFactory, result);
		IRConverterLayer.process(preprocessor, List.of(
				new IRMove(varGlobal, 999)
		));

		final IRVar varAddr = new IRVar(IRNonLocalVarLoweringConverterLayer.ADDR_PREFIX + "global", 0, VariableScope.function, Type.pointer(Type.I16));
		final IRVar varLocal = new IRVar(IRNonLocalVarLoweringConverterLayer.TMP_PREFIX + "global", 1, VariableScope.function, Type.I16);

		final Iterator<IRInstruction> i = result.instructions.iterator();
		assertEquals(new IRMove(varLocal, 999), i.next());
		assertEquals(new IRAddrOf(varAddr, varGlobal), i.next());
		assertEquals(new IRMemStore(varAddr, varLocal), i.next());
		assertFalse(i.hasNext());

		final Iterator<IRVarDef> d = tempVarFactory.createVarInfos().vars().iterator();
		assertEquals(new IRVarDef(varAddr, 8), d.next());
		assertEquals(new IRVarDef(varLocal, 2), d.next());
		assertFalse(d.hasNext());
	}

	@Test
	public void testGlobalReadWrite() {
		final IRVar varGlobal = new IRVar("global", 0, VariableScope.global, Type.I16);
		final IRVar varOne = new IRVar("one", 0, VariableScope.function, Type.I16);

		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(
				new IRVarDef(varGlobal, 2)
		), Set.of(), null);
		final IRVarInfos localVarInfos = new IRVarInfos(List.of(
				new IRVarDef(varOne, 2)
		), Set.of(), globalVarInfos);

		final var result = new IRConverterResultLayer();

		final IRLocalVarFactory tempVarFactory = new IRLocalVarFactory(localVarInfos, Type.I64);
		final IRNonLocalVarLoweringConverterLayer preprocessor = new IRNonLocalVarLoweringConverterLayer(tempVarFactory, result);
		IRConverterLayer.process(preprocessor, List.of(
				new IRMove(varOne, 1),
				new IRBinary(varGlobal, IRBinary.Op.Add, varGlobal, varOne),
				new IRRetValue(varGlobal)
		));

		final IRVar varAddr = new IRVar(IRNonLocalVarLoweringConverterLayer.ADDR_PREFIX + "global", 1, VariableScope.function, Type.pointer(Type.I16));
		final IRVar varLocal = new IRVar(IRNonLocalVarLoweringConverterLayer.TMP_PREFIX + "global", 2, VariableScope.function, Type.I16);
		final IRVar varAddr1 = new IRVar(IRNonLocalVarLoweringConverterLayer.ADDR_PREFIX + "global1", 3, VariableScope.function, Type.pointer(Type.I16));
		final IRVar varLocal1 = new IRVar(IRNonLocalVarLoweringConverterLayer.TMP_PREFIX + "global1", 4, VariableScope.function, Type.I16);
		final IRVar varAddr2 = new IRVar(IRNonLocalVarLoweringConverterLayer.ADDR_PREFIX + "global2", 5, VariableScope.function, Type.pointer(Type.I16));
		final IRVar varLocal2 = new IRVar(IRNonLocalVarLoweringConverterLayer.TMP_PREFIX + "global2", 6, VariableScope.function, Type.I16);

		final Iterator<IRInstruction> i = result.instructions.iterator();
		assertEquals(new IRMove(varOne, 1), i.next());

		assertEquals(new IRAddrOf(varAddr, varGlobal), i.next());
		assertEquals(new IRMemLoad(varLocal, varAddr), i.next());

		assertEquals(new IRBinary(varLocal1, IRBinary.Op.Add, varLocal, varOne), i.next());
		assertEquals(new IRAddrOf(varAddr1, varGlobal), i.next());
		assertEquals(new IRMemStore(varAddr1, varLocal1), i.next());

		assertEquals(new IRAddrOf(varAddr2, varGlobal), i.next());
		assertEquals(new IRMemLoad(varLocal2, varAddr2), i.next());
		assertEquals(new IRRetValue(varLocal2), i.next());
		assertFalse(i.hasNext());

		final Iterator<IRVarDef> d = tempVarFactory.createVarInfos().vars().iterator();
		assertEquals(new IRVarDef(varOne, 2), d.next());
		assertEquals(new IRVarDef(varAddr, 8), d.next());
		assertEquals(new IRVarDef(varLocal, 2), d.next());
		assertEquals(new IRVarDef(varAddr1, 8), d.next());
		assertEquals(new IRVarDef(varLocal1, 2), d.next());
		assertEquals(new IRVarDef(varAddr2, 8), d.next());
		assertEquals(new IRVarDef(varLocal2, 2), d.next());
		assertFalse(d.hasNext());
	}

	@Test
	public void testAddressed() {
		final IRVar varA = new IRVar("a", 0, VariableScope.function, Type.I16);
		final IRVar varB = new IRVar("b", 1, VariableScope.function, Type.I16);
		final IRVar varAddrA = new IRVar("addrA", 2, VariableScope.function, Type.pointer(Type.I16));

		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(), Set.of(), null);
		final IRVarInfos localVarInfos = new IRVarInfos(List.of(
				new IRVarDef(varA, 2),
				new IRVarDef(varB, 2),
				new IRVarDef(varAddrA, 8)
		), Set.of(varA), globalVarInfos);

		final var result = new IRConverterResultLayer();

		final IRLocalVarFactory tempVarFactory = new IRLocalVarFactory(localVarInfos, Type.I64);
		final IRNonLocalVarLoweringConverterLayer preprocessor = new IRNonLocalVarLoweringConverterLayer(tempVarFactory, result);
		IRConverterLayer.process(preprocessor, List.of(
				new IRMove(varA, 1),
				new IRAddrOf(varAddrA, varA),
				new IRMove(varA, 2),
				new IRMove(varB, 3),
				new IRMemStore(varAddrA, varB),
				new IRMove(varA, 4),
				new IRJump("label")
		));

		final IRVar varAddr_A = new IRVar(IRNonLocalVarLoweringConverterLayer.ADDR_PREFIX + "a", 3, VariableScope.function, Type.pointer(Type.I16));
		final IRVar varTemp_A = new IRVar(IRNonLocalVarLoweringConverterLayer.TMP_PREFIX + "a", 4, VariableScope.function, Type.I16);
		final IRVar varAddr_A1 = new IRVar(IRNonLocalVarLoweringConverterLayer.ADDR_PREFIX + "a1", 5, VariableScope.function, Type.pointer(Type.I16));
		final IRVar varTemp_A1 = new IRVar(IRNonLocalVarLoweringConverterLayer.TMP_PREFIX + "a1", 6, VariableScope.function, Type.I16);
		final IRVar varAddr_A2 = new IRVar(IRNonLocalVarLoweringConverterLayer.ADDR_PREFIX + "a2", 7, VariableScope.function, Type.pointer(Type.I16));
		final IRVar varTemp_A2 = new IRVar(IRNonLocalVarLoweringConverterLayer.TMP_PREFIX + "a2", 8, VariableScope.function, Type.I16);

		final Iterator<IRInstruction> i = result.instructions.iterator();
		assertEquals(new IRMove(varTemp_A, 1), i.next());
		assertEquals(new IRAddrOf(varAddr_A, varA), i.next());
		assertEquals(new IRMemStore(varAddr_A, varTemp_A), i.next());

		assertEquals(new IRAddrOf(varAddrA, varA), i.next());

		assertEquals(new IRMove(varTemp_A1, 2), i.next());
		assertEquals(new IRAddrOf(varAddr_A1, varA), i.next());
		assertEquals(new IRMemStore(varAddr_A1, varTemp_A1), i.next());

		assertEquals(new IRMove(varB, 3), i.next());

		assertEquals(new IRMemStore(varAddrA, varB), i.next());

		assertEquals(new IRMove(varTemp_A2, 4), i.next());
		assertEquals(new IRAddrOf(varAddr_A2, varA), i.next());
		assertEquals(new IRMemStore(varAddr_A2, varTemp_A2), i.next());

		assertEquals(new IRJump("label"), i.next());
		assertFalse(i.hasNext());

		final Iterator<IRVarDef> d = tempVarFactory.createVarInfos().vars().iterator();
		assertEquals(new IRVarDef(varA, 2), d.next());
		assertEquals(new IRVarDef(varB, 2), d.next());
		assertEquals(new IRVarDef(varAddrA, 8), d.next());
		assertEquals(new IRVarDef(varAddr_A, 8), d.next());
		assertEquals(new IRVarDef(varTemp_A, 2), d.next());
		assertEquals(new IRVarDef(varAddr_A1, 8), d.next());
		assertEquals(new IRVarDef(varTemp_A1, 2), d.next());
		assertEquals(new IRVarDef(varAddr_A2, 8), d.next());
		assertEquals(new IRVarDef(varTemp_A2, 2), d.next());
		assertFalse(d.hasNext());
	}
}