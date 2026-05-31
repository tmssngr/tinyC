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
public class LSPreprocessorTest {

	@Test
	public void testArgs() {
		final IRVar a = new IRVar("a", 0, VariableScope.parameter, Type.I16);
		final IRVar b = new IRVar("b", 1, VariableScope.parameter, Type.I16);
		final IRVar c = new IRVar("c", 2, VariableScope.parameter, Type.I16);
		final IRVar d = new IRVar("d", 3, VariableScope.function, Type.I16);
		final IRVar arg02 = new IRVar("arg.0.2", 4, VariableScope.function, Type.I16);
		final IRVar arg03 = new IRVar("arg.0.3", 5, VariableScope.function, Type.I16);
		final LSCallingConventionProvider callingConventionProvider = (targetType, argTypes) -> LSCallingConvention.createX86CallingConvention(2, 0);
		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(), Set.of(), null);
		final var result = LSPreprocessor.process(new IRFunction("name", "label", Type.BOOL,
		                                                         new IRVarInfos(List.of(
				                                                         new IRVarDef(a, 2),
				                                                         new IRVarDef(b, 2),
				                                                         new IRVarDef(c, 2),
				                                                         new IRVarDef(d, 2)
		                                                         ), Set.of(), globalVarInfos),
		                                                         List.of(
				                                                         new IRBinary(d, IRBinary.Op.Add, a, b),
				                                                         new IRCall(c, Type.I16, "sub", List.of(d, c, b, a)),
				                                                         new IRRetValue(c)
		                                                         )), callingConventionProvider, false);
		assertEquals(List.of(
				new IRMove(a, a.asRegister(1)),
				new IRMove(b, b.asRegister(2)),
				new IRBinary(d, IRBinary.Op.Add, a, b),
				new IRMove(arg02, b),
				new IRMove(arg03, a),
				new IRMove(d.asRegister(1), d),
				new IRMove(c.asRegister(2), c),
				new IRCall(c.asRegister(0), Type.I16, "sub",
				           List.of(
						           d.asRegister(1),
						           c.asRegister(2),
						           arg02,
						           arg03
				           )),
				new IRMove(c, c.asRegister(0)),
				new IRMove(c.asRegister(0), c)
		), result.second());
	}

	@Test
	public void testAddressedGlobal() {
		final IRVar varA = new IRVar("a", 0, VariableScope.global, Type.I16);
		final IRVar varB = new IRVar("b", 0, VariableScope.function, Type.I16);
		final IRVar varAddrA = new IRVar("addrA", 1, VariableScope.function, Type.pointer(Type.I16));
		final IRVar varTempA = new IRVar(LSPreprocessorCachedVarLayer.TMP_PREFIX + "a", 2, VariableScope.function, Type.I16);

		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(
				new IRVarDef(varA, 2)
		), Set.of(varA), null);
		final IRVarInfos localVarInfos = new IRVarInfos(List.of(
				new IRVarDef(varB, 2),
				new IRVarDef(varAddrA, 8)
		), Set.of(), globalVarInfos);

		final LSCallingConventionProvider callingConventionProvider = (targetType, argTypes) -> LSCallingConvention.createX86CallingConvention(2, 0);
		final var result = LSPreprocessor.process(new IRFunction("name", "label", Type.VOID, localVarInfos,
		                                                         List.of(
				                                                         new IRLiteral(varA, 1),
				                                                         new IRAddrOf(varAddrA, varA),
				                                                         new IRLiteral(varA, 2),
				                                                         new IRLiteral(varB, 3),
				                                                         new IRMemStore(varAddrA, varB),
				                                                         new IRLiteral(varA, 4),
				                                                         new IRJump("label"),
				                                                         new IRLabel("label")
		                                                         )), callingConventionProvider, false);
		IRTestUtils.assertEqualsInstructions(List.of(
				new IRLiteral(varTempA, 1),
				new IRAddrOf(varAddrA, varA),
				new IRLiteral(varTempA, 2),
				new IRLiteral(varB, 3),
				new IRMove(varA, varTempA),
				new IRMemStore(varAddrA, varB),
				new IRLiteral(varTempA, 4),
				new IRMove(varA, varTempA),
				new IRJump("label"),
				new IRLabel("label")
		), result.second());
		assertEquals(List.of(
				             new IRVarDef(varB, 2),
				             new IRVarDef(varAddrA, 8),
				             new IRVarDef(varTempA, 2)
		             ),
		             result.first().vars());
	}

	@Test
	public void testPrintChar() {
		final IRVar varChr = new IRVar("chr", 0, VariableScope.parameter, Type.U8);
		final IRVar varT1 = new IRVar("t.1", 1, VariableScope.function, Type.POINTER_U8);
		final IRVar varT2 = new IRVar("t.2", 2, VariableScope.function, Type.I64);

		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(), Set.of(varChr), null);
		final IRVarInfos localVarInfos = new IRVarInfos(List.of(
				new IRVarDef(varChr, 1),
				new IRVarDef(varT1, 8),
				new IRVarDef(varT2, 8)
		), Set.of(varChr), globalVarInfos);

		final LSCallingConventionProvider callingConventionProvider = (targetType, argTypes) -> LSCallingConvention.createX86CallingConvention(2, 0);
		final var result = LSPreprocessor.process(new IRFunction("printChar", "@printChar", Type.VOID, localVarInfos,
		                                                         List.of(
				                                                         new IRAddrOf(varT1, varChr),
				                                                         new IRLiteral(varT2, 1),
																		 new IRCall(null, Type.VOID, "printStringLength", List.of(varT1, varT2)),
				                                                         new IRLabel("@printChar_ret")
		                                                         )), callingConventionProvider, false);
		IRTestUtils.assertEqualsInstructions(List.of(
				new IRMove(varChr, varChr.asRegister(1)),
				new IRAddrOf(varT1, varChr),
				new IRLiteral(varT2, 1),
				new IRMove(varT1.asRegister(1), varT1),
				new IRMove(varT2.asRegister(2), varT2),
				new IRCall(null, Type.VOID, "printStringLength", List.of(varT1.asRegister(1), varT2.asRegister(2))),
				new IRLabel("@printChar_ret")
		), result.second());
		assertEquals(List.of(
				             new IRVarDef(varChr, 1),
				             new IRVarDef(varT1, 8),
				             new IRVarDef(varT2, 8)
		             ),
		             result.first().vars());
	}
}