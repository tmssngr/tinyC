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
	public void testGlobal() {
		final IRVar varGlobal = new IRVar("global", 0, VariableScope.global, Type.I16);
		final IRVar varOne = new IRVar("one", 0, VariableScope.function, Type.I16);
		final IRVar varLocal = new IRVar(LSPreprocessorCachedVarLayer.PREFIX + "global", 1, VariableScope.function, Type.I16);

		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(
				new IRVarDef(varGlobal, 2)
		), Set.of(), null);
		final IRVarInfos localVarInfos = new IRVarInfos(List.of(
				new IRVarDef(varOne, 2)
		), Set.of(), globalVarInfos);

		final var result = new LSPreprocessorResultLayer();

		final LSTempRegisterVars tempRegisterVars = new LSTempRegisterVars(localVarInfos);
		final LSPreprocessorCachedVarLayer preprocessor = new LSPreprocessorCachedVarLayer(localVarInfos, tempRegisterVars, result);
		LSPreprocessorLayer.process(preprocessor, List.of(
				new IRLiteral(varOne, 1, Location.DUMMY),
				new IRBinary(varGlobal, IRBinary.Op.Add, varGlobal, varOne, Location.DUMMY),
				new IRRetValue(varGlobal, Location.DUMMY)
		));

		IRTestUtils.assertEqualsInstructions(List.of(
				new IRLiteral(varOne, 1, Location.DUMMY),
				new IRMove(varLocal, varGlobal, Location.DUMMY),
				new IRBinary(varLocal, IRBinary.Op.Add, varLocal, varOne, Location.DUMMY),
				new IRMove(varGlobal, varLocal, Location.DUMMY),
				new IRRetValue(varLocal, Location.DUMMY)
		), result.instructions);
		assertEquals(List.of(
				             new IRVarDef(varOne, 2),
				             new IRVarDef(varLocal, 2)
		             ),
		             tempRegisterVars.createVarInfos().vars());
	}

	@Test
	public void testAddressed() {
		final IRVar varA = new IRVar("a", 0, VariableScope.function, Type.I16);
		final IRVar varB = new IRVar("b", 1, VariableScope.function, Type.I16);
		final IRVar varAddrA = new IRVar("addrA", 2, VariableScope.function, Type.pointer(Type.I16));
		final IRVar varTempA = new IRVar(LSPreprocessorCachedVarLayer.PREFIX + "a", 3, VariableScope.function, Type.I16);

		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(), Set.of(), null);
		final IRVarInfos localVarInfos = new IRVarInfos(List.of(
				new IRVarDef(varA, 2),
				new IRVarDef(varB, 2),
				new IRVarDef(varAddrA, 8)
		), Set.of(varA), globalVarInfos);

		final var result = new LSPreprocessorResultLayer();

		final LSTempRegisterVars tempRegisterVars = new LSTempRegisterVars(localVarInfos);
		final LSPreprocessorCachedVarLayer preprocessor = new LSPreprocessorCachedVarLayer(localVarInfos, tempRegisterVars, result);
		LSPreprocessorLayer.process(preprocessor, List.of(
				new IRLiteral(varA, 1, Location.DUMMY),
				new IRAddrOf(varAddrA, varA, Location.DUMMY),
				new IRLiteral(varA, 2, Location.DUMMY),
				new IRLiteral(varB, 3, Location.DUMMY),
				new IRMemStore(varAddrA, varB, Location.DUMMY),
				new IRLiteral(varA, 4, Location.DUMMY),
				new IRJump("label")
		));

		IRTestUtils.assertEqualsInstructions(List.of(
				new IRLiteral(varTempA, 1, Location.DUMMY),
				new IRAddrOf(varAddrA, varA, Location.DUMMY),
				new IRLiteral(varTempA, 2, Location.DUMMY),
				new IRLiteral(varB, 3, Location.DUMMY),
				new IRMove(varA, varTempA, Location.DUMMY),
				new IRMemStore(varAddrA, varB, Location.DUMMY),
				new IRLiteral(varTempA, 4, Location.DUMMY),
				new IRMove(varA, varTempA, Location.DUMMY),
				new IRJump("label")
		), result.instructions);
		assertEquals(List.of(
				             new IRVarDef(varA, 2),
				             new IRVarDef(varB, 2),
				             new IRVarDef(varAddrA, 8),
				             new IRVarDef(varTempA, 2)
		             ),
		             tempRegisterVars.createVarInfos().vars());
	}
}