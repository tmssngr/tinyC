package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.junit.*;

import static org.junit.Assert.*;

/**
 * @author Thomas Singer
 */
public class LSRegAllocTest {

	private static final int U8_SIZE = 1;

	@Test
	public void testSimplest() {
		final int r0 = 0;
		final int r1 = 1;
		final int r2 = 2;
		final IRVar varFour = new IRVar("four", 0, VariableScope.function, Type.U8);
		final IRVar varThree = new IRVar("three", 1, VariableScope.function, Type.U8);
		final IRVar varOne = new IRVar("one", 2, VariableScope.function, Type.U8);
		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(), Set.of(), null);
		final IRFunction function = new IRFunction(
				"simple", "@simple", Type.U8,
				new IRVarInfos(List.of(
						new IRVarDef(varFour, U8_SIZE),
						new IRVarDef(varThree, U8_SIZE),
						new IRVarDef(varOne, U8_SIZE)
				), Set.of(), globalVarInfos),
				List.of(
						new IRLiteral(varFour, 4),
						new IRLiteral(varThree, 3),
						new IRMove(varOne, varFour),
						new IRBinary(varOne, IRBinary.Op.Sub, varOne, varThree),
						new IRRetValue(varOne)
				)
		);
		final LSCallingConventionProvider callingConventionProvider = (targetType, argTypes) -> LSCallingConvention.createX86CallingConvention(2, 0);
		final IRFunction regAllocFunction = LSRegAlloc.process(function, false, 3, callingConventionProvider);
		assertEquals(List.of(
				new IRLiteral(varFour.asRegister(r1), 4),
				new IRLiteral(varThree.asRegister(r2), 3),
				new IRMove(varOne.asRegister(r0), varFour.asRegister(r1)),
				new IRBinary(varOne.asRegister(r0), IRBinary.Op.Sub, varOne.asRegister(r0), varThree.asRegister(r2))
		), regAllocFunction.instructions());
	}

	@Test
	public void testRegisterHint() {
		final int rRet = 0;
		final int rArg1 = 1;
		final int rArg2 = 2;
		final IRVar argA = new IRVar("a", 0, VariableScope.parameter, Type.U8);
		final IRVar argB = new IRVar("b", 1, VariableScope.parameter, Type.U8);
		final IRVar varT2 = new IRVar("t2", 2, VariableScope.function, Type.U8);
		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(), Set.of(), null);
		final IRFunction function = new IRFunction(
				"simple", "@simple", Type.U8,
				new IRVarInfos(List.of(
						new IRVarDef(argA, U8_SIZE),
						new IRVarDef(argB, U8_SIZE),
						new IRVarDef(varT2, U8_SIZE)
				), Set.of(), globalVarInfos),
				List.of(
						new IRMove(varT2, argA),
						new IRBinary(varT2, IRBinary.Op.Add, varT2, argB),
						new IRRetValue(varT2)
				)
		);
		final LSCallingConventionProvider callingConventionProvider = (targetType, argTypes) -> LSCallingConvention.createX86CallingConvention(2, 0);
		final IRFunction regAllocFunction = LSRegAlloc.process(function, false, 3, callingConventionProvider);
		assertEquals(List.of(
				new IRMove(varT2.asRegister(rRet), argA.asRegister(rArg1)),
				new IRBinary(varT2.asRegister(rRet), IRBinary.Op.Add, varT2.asRegister(rRet), argB.asRegister(rArg2))
		), regAllocFunction.instructions());
	}

	@Test
	public void testSplitLiveInterval() {
		final int rRet = 0;
		final int rArg1 = 1;
		final IRVar varA = new IRVar("a", 0, VariableScope.function, Type.U8);
		final IRVar varB = new IRVar("b", 1, VariableScope.function, Type.U8);
		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(), Set.of(), null);
		final IRFunction function = new IRFunction(
				"simple", "@simple", Type.U8,
				new IRVarInfos(List.of(
						new IRVarDef(varA, U8_SIZE),
						new IRVarDef(varB, U8_SIZE)
				), Set.of(), globalVarInfos),
				List.of(
						new IRLiteral(varA, 1),
						new IRCall(varB, Type.U8, "foo", List.of(varA)),
						new IRBinary(varA, IRBinary.Op.Add, varA, varB),
						new IRRetValue(varA)
				)
		);
		final LSCallingConventionProvider callingConventionProvider = (targetType, argTypes) -> LSCallingConvention.createX86CallingConvention(1, 0);
		final IRFunction regAllocFunction = LSRegAlloc.process(function, false, 2, callingConventionProvider);
		IRTestUtils.assertEqualsInstructions(List.of(
				new IRLiteral(varA.asRegister(rArg1), 1),
				new IRMove(varA, varA.asRegister(rArg1)),
				new IRCall(varB.asRegister(rRet), Type.U8, "foo", List.of(varA.asRegister(rArg1))),
				new IRMove(varA.asRegister(rArg1), varA),
				new IRBinary(varA.asRegister(rArg1), IRBinary.Op.Add, varA.asRegister(rArg1), varB.asRegister(rRet)),
				new IRMove(varA.asRegister(rRet), varA.asRegister(rArg1))
		), regAllocFunction.instructions());
	}

	@Test
	public void testIf() {
		final int rRet = 0;
		final int rArg1 = 1;
		final int rArg2 = 2;
		final IRVar varA = new IRVar("a", 0, VariableScope.parameter, Type.U8);
		final IRVar varB = new IRVar("b", 1, VariableScope.parameter, Type.U8);
		final IRVar varTmp = new IRVar("tmp", 2, VariableScope.function, Type.BOOL);
		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(), Set.of(), null);
		final IRFunction function = new IRFunction(
				"if", "@if", Type.U8,
				new IRVarInfos(List.of(
						new IRVarDef(varA, U8_SIZE),
						new IRVarDef(varB, U8_SIZE),
						new IRVarDef(varTmp, U8_SIZE)
				), Set.of(), globalVarInfos),
				List.of(
						new IRCompare(varTmp, IRCompare.Op.Lt, varA, varB),
						new IRBranch(varTmp, false, "@if_1_end", "@if_1_then"),
						new IRLabel("@if_1_then"),
						new IRRetValue(varB),
						new IRJump("@ret"),
						new IRLabel("@if_1_end"),
						new IRRetValue(varA),
						new IRLabel("@ret")
				)
		);
		final LSCallingConventionProvider callingConventionProvider = (targetType, argTypes) -> LSCallingConvention.createX86CallingConvention(2, 0);
		final IRFunction regAllocFunction = LSRegAlloc.process(function, false, 3, callingConventionProvider);
		IRTestUtils.assertEqualsInstructions(List.of(
				new IRCompare(varTmp.asRegister(rRet), IRCompare.Op.Lt, varA.asRegister(rArg1), varB.asRegister(rArg2)),
				new IRBranch(varTmp.asRegister(rRet), false, "@if_1_end", "@if_1_then"),
				new IRJump("@if_1_then"),
				new IRLabel("@if_1_end"),
				new IRMove(varA.asRegister(rRet), varA.asRegister(rArg1)),
				new IRJump("@ret"),
				new IRLabel("@if_1_then"),
				new IRMove(varB.asRegister(rRet), varB.asRegister(rArg2)),
				new IRJump("@ret"),
				new IRLabel("@ret")
		), regAllocFunction.instructions());
	}

	@Test
	public void testPrintString() {
		final int rRet = 0;
		final int rArg1 = 1;
		final int rArg2 = 2;
		final int rNV1 = 3;
		final IRVar varStr = new IRVar("str", 0, VariableScope.parameter, Type.U8);
		final IRVar varLength = new IRVar("length", 1, VariableScope.function, Type.U8);
		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(), Set.of(), null);
		final IRFunction function = new IRFunction(
				"printString", "@printString", Type.U8,
				new IRVarInfos(List.of(
						new IRVarDef(varStr, 8),
						new IRVarDef(varLength, 2)
				), Set.of(), globalVarInfos),
				List.of(
						new IRCall(varLength, Type.U8, "strlen", List.of(varStr)),
						new IRCall(null, Type.VOID, "printStringLength", List.of(varStr, varLength))
				)
		);
		final LSCallingConventionProvider callingConventionProvider = (targetType, argTypes) -> LSCallingConvention.createX86CallingConvention(2, 0);
		final IRFunction regAllocFunction = LSRegAlloc.process(function, false, 5, callingConventionProvider);
		IRTestUtils.assertEqualsInstructions(List.of(
				new IRMove(varStr.asRegister(rNV1), varStr.asRegister(rArg1)),
				// todo
				new IRMove(varStr.asRegister(rArg1), varStr.asRegister(rNV1)),
				new IRCall(varLength.asRegister(rRet), Type.U8, "strlen", List.of(varStr.asRegister(rArg1))),
				new IRMove(varStr.asRegister(rArg1), varStr.asRegister(rNV1)),
				new IRMove(varLength.asRegister(rArg2), varLength.asRegister(rRet)),
				new IRCall(null, Type.VOID, "printStringLength", List.of(varStr.asRegister(rArg1), varLength.asRegister(rArg2)))
		), regAllocFunction.instructions());
	}

	@Test
	public void testGlobalVar() {
		final int rRet = 0;
		final int rArg1 = 1;
		final IRVar varGlobal = new IRVar("global", 0, VariableScope.global, Type.U8);
		final IRVar varOne = new IRVar("one", 0, VariableScope.function, Type.U8);
		final IRVar varLocalGlobal = new IRVar(LSPreprocessorCachedVarLayer.TMP_PREFIX + "global", 1, VariableScope.global, Type.U8);
		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(
				new IRVarDef(varGlobal, 1)
		), Set.of(), null);
		final IRVarInfos localVarInfos = new IRVarInfos(List.of(
				new IRVarDef(varOne, 1)
		), Set.of(), globalVarInfos);
		final IRFunction function = new IRFunction(
				"nextIndex", "@nextIndex", Type.U8,
				localVarInfos,
				List.of(
						new IRLiteral(varOne, 1),
						new IRBinary(varGlobal, IRBinary.Op.Add, varGlobal, varOne),
						new IRRetValue(varGlobal)
				)
		);
		final LSCallingConventionProvider callingConventionProvider = (targetType, argTypes) -> LSCallingConvention.createX86CallingConvention(2, 0);
		final IRFunction regAllocFunction = LSRegAlloc.process(function, false, 3, callingConventionProvider);
		IRTestUtils.assertEqualsInstructions(List.of(
				new IRLiteral(varOne.asRegister(rArg1), 1),
				new IRMove(varLocalGlobal.asRegister(rRet), varGlobal),
				new IRBinary(varLocalGlobal.asRegister(rRet), IRBinary.Op.Add, varLocalGlobal.asRegister(rRet), varOne.asRegister(rArg1)),
				new IRMove(varGlobal, varLocalGlobal.asRegister(rRet))
		), regAllocFunction.instructions());
	}

	@Test
	public void testStackVar() {
		final int r0 = 0;
		final int r1 = 1;
		final int r2 = 2;
		final IRVar varA = new IRVar("a", 0, VariableScope.function, Type.U8);
		final IRVar varB = new IRVar("b", 1, VariableScope.function, Type.U8);
		final IRVar varC = new IRVar("c", 2, VariableScope.function, Type.U8);
		final IRVar varT = new IRVar("t", 3, VariableScope.function, Type.U8);
		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(), Set.of(), null);
		final IRFunction function = new IRFunction(
				"simple", "@simple", Type.U8,
				new IRVarInfos(List.of(
						new IRVarDef(varA, U8_SIZE),
						new IRVarDef(varB, U8_SIZE),
						new IRVarDef(varC, U8_SIZE),
						new IRVarDef(varT, U8_SIZE)
				), Set.of(), globalVarInfos),
				List.of(
						new IRLiteral(varA, 1),
						new IRLiteral(varB, 2),
						new IRLiteral(varC, 3),
						new IRCall(null, Type.VOID, "print", List.of(varA)),
						new IRCall(null, Type.VOID, "print", List.of(varB)),
						new IRMove(varT, varA),
						new IRBinary(varT, IRBinary.Op.Add, varT, varC),
						new IRCall(null, Type.VOID, "print", List.of(varT)),
						new IRCall(null, Type.VOID, "print", List.of(varC))
				)
		);
		final LSCallingConventionProvider callingConventionProvider = (targetType, argTypes) -> LSCallingConvention.createX86CallingConvention(2, 0);
		final IRFunction regAllocFunction = LSRegAlloc.process(function, false, 3, callingConventionProvider);
		final IRVar varA0 = varA.asRegister(0);
		final IRVar varA1 = varA.asRegister(1);
		final IRVar varB0 = varB.asRegister(0);
		final IRVar varB1 = varB.asRegister(1);
		final IRVar varC0 = varC.asRegister(0);
		final IRVar varC1 = varC.asRegister(1);
		final IRVar varT1 = varT.asRegister(1);
		assertEquals(List.of(
				new IRLiteral(varA1, 1),
				new IRLiteral(varB0, 2),
				new IRMove(varB, varB0),
				new IRLiteral(varC0, 3),
				new IRMove(varC, varC0),
				new IRMove(varA, varA1),
				new IRCall(null, Type.VOID, "print", List.of(varA1)),
				new IRMove(varB1, varB),
				new IRCall(null, Type.VOID, "print", List.of(varB1)),
				new IRMove(varA0, varA),
				new IRMove(varT1, varA0),
				new IRMove(varC0, varC),
				new IRBinary(varT1, IRBinary.Op.Add, varT1, varC0),
				new IRMove(varC, varC0),
				new IRCall(null, Type.VOID, "print", List.of(varT1)),
				new IRMove(varC1, varC),
				new IRCall(null, Type.VOID, "print", List.of(varC1))
		), regAllocFunction.instructions());
	}
}