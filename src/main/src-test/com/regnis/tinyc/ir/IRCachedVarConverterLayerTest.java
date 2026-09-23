package com.regnis.tinyc.ir;

import com.regnis.tinyc.ast.*;

import java.util.*;

import org.junit.*;

import static org.junit.Assert.*;

/**
 * @author Thomas Singer
 */
public class IRCachedVarConverterLayerTest {

	@Test
	public void testGlobalRead() {
		final IRVar varGlobal = new IRVar("global", 0, VariableScope.global, Type.I16);
		final IRVar varLocal = new IRVar(IRCachedVarConverterLayer.TMP_PREFIX + "global", 0, VariableScope.function, Type.I16);

		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(
				new IRVarDef(varGlobal, 2)
		), Set.of(), null);
		final IRVarInfos localVarInfos = new IRVarInfos(List.of(), Set.of(), globalVarInfos);

		final var result = new IRConverterResultLayer();

		final IRLocalVarFactory tempVarFactory = new IRLocalVarFactory(localVarInfos, Type.I64);
		final IRCachedVarConverterLayer preprocessor = new IRCachedVarConverterLayer(tempVarFactory, result);
		IRConverterLayer.process(preprocessor, List.of(
				new IRRetValue(varGlobal)
		));

		final Iterator<IRInstruction> i = result.instructions.iterator();
		assertEquals(new IRMove(varLocal, varGlobal), i.next());
		assertEquals(new IRRetValue(varLocal), i.next());
		assertFalse(i.hasNext());

		final Iterator<IRVarDef> d = tempVarFactory.createVarInfos().vars().iterator();
		assertEquals(new IRVarDef(varLocal, 2), d.next());
		assertFalse(d.hasNext());
	}

	@Test
	public void testGlobalWrite() {
		final IRVar varGlobal = new IRVar("global", 0, VariableScope.global, Type.I16);
		final IRVar varLocal = new IRVar(IRCachedVarConverterLayer.TMP_PREFIX + "global", 0, VariableScope.function, Type.I16);

		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(
				new IRVarDef(varGlobal, 2)
		), Set.of(), null);
		final IRVarInfos localVarInfos = new IRVarInfos(List.of(), Set.of(), globalVarInfos);

		final var result = new IRConverterResultLayer();

		final IRLocalVarFactory tempVarFactory = new IRLocalVarFactory(localVarInfos, Type.I64);
		final IRCachedVarConverterLayer preprocessor = new IRCachedVarConverterLayer(tempVarFactory, result);
		IRConverterLayer.process(preprocessor, List.of(
				new IRMove(varGlobal, 999)
		));

		final Iterator<IRInstruction> i = result.instructions.iterator();
		assertEquals(new IRMove(varLocal, 999), i.next());
		assertEquals(new IRMove(varGlobal, varLocal), i.next());
		assertFalse(i.hasNext());

		final Iterator<IRVarDef> d = tempVarFactory.createVarInfos().vars().iterator();
		assertEquals(new IRVarDef(varLocal, 2), d.next());
		assertFalse(d.hasNext());
	}

	@Test
	public void testGlobalReadWrite() {
		final IRVar varGlobal = new IRVar("global", 0, VariableScope.global, Type.I16);
		final IRVar varOne = new IRVar("one", 0, VariableScope.function, Type.I16);
		final IRVar varLocal = new IRVar(IRCachedVarConverterLayer.TMP_PREFIX + "global", 1, VariableScope.function, Type.I16);

		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(
				new IRVarDef(varGlobal, 2)
		), Set.of(), null);
		final IRVarInfos localVarInfos = new IRVarInfos(List.of(
				new IRVarDef(varOne, 2)
		), Set.of(), globalVarInfos);

		final var result = new IRConverterResultLayer();

		final IRLocalVarFactory tempVarFactory = new IRLocalVarFactory(localVarInfos, Type.I64);
		final IRCachedVarConverterLayer preprocessor = new IRCachedVarConverterLayer(tempVarFactory, result);
		IRConverterLayer.process(preprocessor, List.of(
				new IRMove(varOne, 1),
				new IRBinary(varGlobal, IRBinary.Op.Add, varGlobal, varOne),
				new IRRetValue(varGlobal)
		));

		final Iterator<IRInstruction> i = result.instructions.iterator();
		assertEquals(new IRMove(varOne, 1), i.next());
		assertEquals(new IRMove(varLocal, varGlobal), i.next());
		assertEquals(new IRBinary(varLocal, IRBinary.Op.Add, varLocal, varOne), i.next());
		assertEquals(new IRMove(varGlobal, varLocal), i.next());
		assertEquals(new IRRetValue(varLocal), i.next());
		assertFalse(i.hasNext());

		final Iterator<IRVarDef> d = tempVarFactory.createVarInfos().vars().iterator();
		assertEquals(new IRVarDef(varOne, 2), d.next());
		assertEquals(new IRVarDef(varLocal, 2), d.next());
		assertFalse(d.hasNext());
	}

	@Test
	public void testAddressed() {
		final IRVar varA = new IRVar("a", 0, VariableScope.function, Type.I16);
		final IRVar varB = new IRVar("b", 1, VariableScope.function, Type.I16);
		final IRVar varAddrA = new IRVar("addrA", 2, VariableScope.function, Type.pointer(Type.I16));
		final IRVar varTempA = new IRVar(IRCachedVarConverterLayer.TMP_PREFIX + "a", 3, VariableScope.function, Type.I16);

		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(), Set.of(), null);
		final IRVarInfos localVarInfos = new IRVarInfos(List.of(
				new IRVarDef(varA, 2),
				new IRVarDef(varB, 2),
				new IRVarDef(varAddrA, 8)
		), Set.of(varA), globalVarInfos);

		final var result = new IRConverterResultLayer();

		final IRLocalVarFactory tempVarFactory = new IRLocalVarFactory(localVarInfos, Type.I64);
		final IRCachedVarConverterLayer preprocessor = new IRCachedVarConverterLayer(tempVarFactory, result);
		IRConverterLayer.process(preprocessor, List.of(
				new IRMove(varA, 1),
				new IRAddrOf(varAddrA, varA),
				new IRMove(varA, 2),
				new IRMove(varB, 3),
				new IRMemStore(varAddrA, varB),
				new IRMove(varA, 4),
				new IRJump("label")
		));

		final Iterator<IRInstruction> i = result.instructions.iterator();
		assertEquals(new IRMove(varTempA, 1), i.next());
		assertEquals(new IRAddrOf(varAddrA, varA), i.next());
		assertEquals(new IRMove(varTempA, 2), i.next());
		assertEquals(new IRMove(varB, 3), i.next());
		assertEquals(new IRMove(varA, varTempA), i.next());
		assertEquals(new IRMemStore(varAddrA, varB), i.next());
		assertEquals(new IRMove(varTempA, 4), i.next());
		assertEquals(new IRMove(varA, varTempA), i.next());
		assertEquals(new IRJump("label"), i.next());
		assertFalse(i.hasNext());

		final Iterator<IRVarDef> d = tempVarFactory.createVarInfos().vars().iterator();
		assertEquals(new IRVarDef(varA, 2), d.next());
		assertEquals(new IRVarDef(varB, 2), d.next());
		assertEquals(new IRVarDef(varAddrA, 8), d.next());
		assertEquals(new IRVarDef(varTempA, 2), d.next());
		assertFalse(d.hasNext());
	}
}