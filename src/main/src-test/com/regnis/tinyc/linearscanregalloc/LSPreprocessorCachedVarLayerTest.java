package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.junit.*;

import static org.junit.Assert.assertEquals;

/**
 * @author Thomas Singer
 */
public class LSPreprocessorCachedVarLayerTest {

	@Test
	public void testGlobalRead() {
		final IRVar varGlobal = new IRVar("global", 0, VariableScope.global, Type.I16);
		final IRVar varLocal = new IRVar(LSPreprocessorCachedVarLayer.TMP_PREFIX + "global", 0, VariableScope.function, Type.I16);

		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(
				new IRVarDef(varGlobal, 2)
		), Set.of(), null);
		final IRVarInfos localVarInfos = new IRVarInfos(List.of(), Set.of(), globalVarInfos);

		final var result = new LSPreprocessorResultLayer();

		final IRLocalVarFactory tempVarFactory = new IRLocalVarFactory(localVarInfos);
		final LSPreprocessorCachedVarLayer preprocessor = new LSPreprocessorCachedVarLayer(localVarInfos, tempVarFactory, result);
		LSPreprocessorLayer.process(preprocessor, List.of(
				new IRRetValue(varGlobal)
		));

		IRTestUtils.assertEqualsInstructions(List.of(
				new IRMove(varLocal, varGlobal),
				new IRRetValue(varLocal)
		), result.instructions);
		assertEquals(List.of(
				             new IRVarDef(varLocal, 2)
		             ),
		             tempVarFactory.createVarInfos().vars());
	}

	@Test
	public void testGlobalWrite() {
		final IRVar varGlobal = new IRVar("global", 0, VariableScope.global, Type.I16);
		final IRVar varLocal = new IRVar(LSPreprocessorCachedVarLayer.TMP_PREFIX + "global", 0, VariableScope.function, Type.I16);

		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(
				new IRVarDef(varGlobal, 2)
		), Set.of(), null);
		final IRVarInfos localVarInfos = new IRVarInfos(List.of(), Set.of(), globalVarInfos);

		final var result = new LSPreprocessorResultLayer();

		final IRLocalVarFactory tempVarFactory = new IRLocalVarFactory(localVarInfos);
		final LSPreprocessorCachedVarLayer preprocessor = new LSPreprocessorCachedVarLayer(localVarInfos, tempVarFactory, result);
		LSPreprocessorLayer.process(preprocessor, List.of(
				new IRLiteral(varGlobal, 999)
		));

		IRTestUtils.assertEqualsInstructions(List.of(
				new IRLiteral(varLocal, 999),
				new IRMove(varGlobal, varLocal)
		), result.instructions);
		assertEquals(List.of(
				             new IRVarDef(varLocal, 2)
		             ),
		             tempVarFactory.createVarInfos().vars());
	}

	@Test
	public void testGlobalReadWrite() {
		final IRVar varGlobal = new IRVar("global", 0, VariableScope.global, Type.I16);
		final IRVar varOne = new IRVar("one", 0, VariableScope.function, Type.I16);
		final IRVar varLocal = new IRVar(LSPreprocessorCachedVarLayer.TMP_PREFIX + "global", 1, VariableScope.function, Type.I16);

		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(
				new IRVarDef(varGlobal, 2)
		), Set.of(), null);
		final IRVarInfos localVarInfos = new IRVarInfos(List.of(
				new IRVarDef(varOne, 2)
		), Set.of(), globalVarInfos);

		final var result = new LSPreprocessorResultLayer();

		final IRLocalVarFactory tempVarFactory = new IRLocalVarFactory(localVarInfos);
		final LSPreprocessorCachedVarLayer preprocessor = new LSPreprocessorCachedVarLayer(localVarInfos, tempVarFactory, result);
		LSPreprocessorLayer.process(preprocessor, List.of(
				new IRLiteral(varOne, 1),
				new IRBinary(varGlobal, IRBinary.Op.Add, varGlobal, varOne),
				new IRRetValue(varGlobal)
		));

		IRTestUtils.assertEqualsInstructions(List.of(
				new IRLiteral(varOne, 1),
				new IRMove(varLocal, varGlobal),
				new IRBinary(varLocal, IRBinary.Op.Add, varLocal, varOne),
				new IRMove(varGlobal, varLocal),
				new IRRetValue(varLocal)
		), result.instructions);
		assertEquals(List.of(
				             new IRVarDef(varOne, 2),
				             new IRVarDef(varLocal, 2)
		             ),
		             tempVarFactory.createVarInfos().vars());
	}

	@Test
	public void testAddressed() {
		final IRVar varA = new IRVar("a", 0, VariableScope.function, Type.I16);
		final IRVar varB = new IRVar("b", 1, VariableScope.function, Type.I16);
		final IRVar varAddrA = new IRVar("addrA", 2, VariableScope.function, Type.pointer(Type.I16));
		final IRVar varTempA = new IRVar(LSPreprocessorCachedVarLayer.TMP_PREFIX + "a", 3, VariableScope.function, Type.I16);

		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(), Set.of(), null);
		final IRVarInfos localVarInfos = new IRVarInfos(List.of(
				new IRVarDef(varA, 2),
				new IRVarDef(varB, 2),
				new IRVarDef(varAddrA, 8)
		), Set.of(varA), globalVarInfos);

		final var result = new LSPreprocessorResultLayer();

		final IRLocalVarFactory tempVarFactory = new IRLocalVarFactory(localVarInfos);
		final LSPreprocessorCachedVarLayer preprocessor = new LSPreprocessorCachedVarLayer(localVarInfos, tempVarFactory, result);
		LSPreprocessorLayer.process(preprocessor, List.of(
				new IRLiteral(varA, 1),
				new IRAddrOf(varAddrA, varA),
				new IRLiteral(varA, 2),
				new IRLiteral(varB, 3),
				new IRMemStore(varAddrA, varB),
				new IRLiteral(varA, 4),
				new IRJump("label")
		));

		IRTestUtils.assertEqualsInstructions(List.of(
				new IRLiteral(varTempA, 1),
				new IRAddrOf(varAddrA, varA),
				new IRLiteral(varTempA, 2),
				new IRLiteral(varB, 3),
				new IRMove(varA, varTempA),
				new IRMemStore(varAddrA, varB),
				new IRLiteral(varTempA, 4),
				new IRMove(varA, varTempA),
				new IRJump("label")
		), result.instructions);
		assertEquals(List.of(
				             new IRVarDef(varA, 2),
				             new IRVarDef(varB, 2),
				             new IRVarDef(varAddrA, 8),
				             new IRVarDef(varTempA, 2)
		             ),
		             tempVarFactory.createVarInfos().vars());
	}
}