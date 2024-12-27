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
		final IRFunction function = new IRFunction(
				"simple", "@simple", Type.U8,
				new IRVarInfos(List.of(
						new IRVarDef(varFour, U8_SIZE),
						new IRVarDef(varThree, U8_SIZE),
						new IRVarDef(varOne, U8_SIZE)
				), Set.of(), null),
				List.of(
						new IRLiteral(varFour, 4, Location.DUMMY),
						new IRLiteral(varThree, 3, Location.DUMMY),
						new IRMove(varOne, varFour, Location.DUMMY),
						new IRBinary(varOne, IRBinary.Op.Sub, varOne, varThree, Location.DUMMY),
						new IRRetValue(varOne, Location.DUMMY)
				)
		);
		final LSArchitecture architecture = new LSArchitecture(2, 0, 0, false);
		final List<IRInstruction> instructions = LSRegAlloc.process(function, architecture);
		assertEquals(List.of(
				new IRLiteral(varFour.asRegister(r1), 4, Location.DUMMY),
				new IRLiteral(varThree.asRegister(r2), 3, Location.DUMMY),
				new IRMove(varOne.asRegister(r0), varFour.asRegister(r1), Location.DUMMY),
				new IRBinary(varOne.asRegister(r0), IRBinary.Op.Sub, varOne.asRegister(r0), varThree.asRegister(r2), Location.DUMMY)
		), instructions);
	}

	@Test
	public void testRegisterHint() {
		final int rRet = 0;
		final int rArg1 = 1;
		final int rArg2 = 2;
		final IRVar argA = new IRVar("a", 0, VariableScope.argument, Type.U8);
		final IRVar argB = new IRVar("b", 1, VariableScope.argument, Type.U8);
		final IRVar varT2 = new IRVar("t2", 2, VariableScope.function, Type.U8);
		final IRFunction function = new IRFunction(
				"simple", "@simple", Type.U8,
				new IRVarInfos(List.of(
						new IRVarDef(argA, U8_SIZE),
						new IRVarDef(argB, U8_SIZE),
						new IRVarDef(varT2, U8_SIZE)
				), Set.of(), null),
				List.of(
						new IRMove(varT2, argA, Location.DUMMY),
						new IRBinary(varT2, IRBinary.Op.Add, varT2, argB, Location.DUMMY),
						new IRRetValue(varT2, Location.DUMMY)
				)
		);
		final LSArchitecture architecture = new LSArchitecture(2, 0, 0, false);
		final List<IRInstruction> instructions = LSRegAlloc.process(function, architecture);
		assertEquals(List.of(
				new IRMove(varT2.asRegister(rRet), argA.asRegister(rArg1), Location.DUMMY),
				new IRBinary(varT2.asRegister(rRet), IRBinary.Op.Add, varT2.asRegister(rRet), argB.asRegister(rArg2), Location.DUMMY)
		), instructions);
	}

	@Test
	public void testSplitLiveInterval() {
		final int rRet = 0;
		final int rArg1 = 1;
		final IRVar varA = new IRVar("a", 0, VariableScope.function, Type.U8);
		final IRVar varB = new IRVar("b", 1, VariableScope.function, Type.U8);
		final IRFunction function = new IRFunction(
				"simple", "@simple", Type.U8,
				new IRVarInfos(List.of(
						new IRVarDef(varA, U8_SIZE),
						new IRVarDef(varB, U8_SIZE)
				), Set.of(), null),
				List.of(
						new IRLiteral(varA, 1, Location.DUMMY),
						new IRCall(varB, "foo", List.of(varA), Location.DUMMY),
						new IRBinary(varA, IRBinary.Op.Add, varA, varB, Location.DUMMY),
						new IRRetValue(varA, Location.DUMMY)
				)
		);
		final LSArchitecture architecture = new LSArchitecture(1, 0, 0, false);
		final List<IRInstruction> instructions = LSRegAlloc.process(function, architecture);
		IRTestUtils.assertEqualsInstructions(List.of(
				new IRLiteral(varA.asRegister(rRet), 1, Location.DUMMY),
				new IRMove(varA.asRegister(rArg1), varA.asRegister(rRet), Location.DUMMY),
				new IRMove(varA, varA.asRegister(rRet), Location.DUMMY),
				new IRCall(varB.asRegister(rRet), "foo", List.of(varA.asRegister(rArg1)), Location.DUMMY),
				new IRMove(varA.asRegister(rArg1), varA, Location.DUMMY),
				new IRBinary(varA.asRegister(rArg1), IRBinary.Op.Add, varA.asRegister(rArg1), varB.asRegister(rRet), Location.DUMMY),
				new IRMove(varA.asRegister(rRet), varA.asRegister(rArg1), Location.DUMMY)
		), instructions);
	}

	@Test
	public void testIf() {
		final int rRet = 0;
		final int rArg1 = 1;
		final int rArg2 = 2;
		final IRVar varA = new IRVar("a", 0, VariableScope.argument, Type.U8);
		final IRVar varB = new IRVar("b", 1, VariableScope.argument, Type.U8);
		final IRVar varTmp = new IRVar("tmp", 2, VariableScope.function, Type.BOOL);
		final IRFunction function = new IRFunction(
				"if", "@if", Type.U8,
				new IRVarInfos(List.of(
						new IRVarDef(varA, U8_SIZE),
						new IRVarDef(varB, U8_SIZE),
						new IRVarDef(varTmp, U8_SIZE)
				), Set.of(), null),
				List.of(
						new IRCompare(varTmp, IRCompare.Op.Lt, varA, varB, Location.DUMMY),
						new IRBranch(varTmp, false, "@if_1_end", "@if_1_then"),
						new IRRetValue(varB, Location.DUMMY),
						new IRJump("@ret"),
						new IRLabel("@if_1_end"),
						new IRRetValue(varA, Location.DUMMY),
						new IRLabel("@ret")
				)
		);
		final LSArchitecture architecture = new LSArchitecture(2, 0, 0, false);
		final List<IRInstruction> instructions = LSRegAlloc.process(function, architecture);
		IRTestUtils.assertEqualsInstructions(List.of(
				new IRCompare(varTmp.asRegister(rRet), IRCompare.Op.Lt, varA.asRegister(rArg1), varB.asRegister(rArg2), Location.DUMMY),
				new IRBranch(varTmp.asRegister(rRet), false, "@if_1_end", "@if_1_then"),
				new IRJump("@if_1_then"),
				new IRLabel("@if_1_end"),
				new IRMove(varA.asRegister(rRet), varA.asRegister(rArg1), Location.DUMMY),
				new IRJump("@ret"),
				new IRLabel("@if_1_then"),
				new IRMove(varB.asRegister(rRet), varB.asRegister(rArg2), Location.DUMMY),
				new IRJump("@ret"),
				new IRLabel("@ret")
		), instructions);
	}

	@Test
	public void testPrintString() {
		final int rRet = 0;
		final int rArg1 = 1;
		final int rArg2 = 2;
		final int rNV1 = 3;
		final IRVar varStr = new IRVar("str", 0, VariableScope.argument, Type.U8);
		final IRVar varLength = new IRVar("length", 1, VariableScope.function, Type.U8);
		final IRFunction function = new IRFunction(
				"printString", "@printString", Type.U8,
				new IRVarInfos(List.of(
						new IRVarDef(varStr, 8),
						new IRVarDef(varLength, 2)
				), Set.of(), null),
				List.of(
						new IRCall(varLength, "strlen", List.of(varStr), Location.DUMMY),
						new IRCall(null, "printStringLength", List.of(varStr, varLength), Location.DUMMY)
				)
		);
		final LSArchitecture architecture = new LSArchitecture(2, 0, 2, false);
		final List<IRInstruction> instructions = LSRegAlloc.process(function, architecture);
		IRTestUtils.assertEqualsInstructions(List.of(
				new IRMove(varStr.asRegister(rNV1), varStr.asRegister(rArg1), Location.DUMMY),
				// todo
				new IRMove(varStr.asRegister(rArg1), varStr.asRegister(rNV1), Location.DUMMY),
				new IRCall(varLength.asRegister(rRet), "strlen", List.of(varStr.asRegister(rArg1)), Location.DUMMY),
				new IRMove(varStr.asRegister(rArg1), varStr.asRegister(rNV1), Location.DUMMY),
				new IRMove(varLength.asRegister(rArg2), varLength.asRegister(rRet), Location.DUMMY),
				new IRCall(null, "printStringLength", List.of(varStr.asRegister(rArg1), varLength.asRegister(rArg2)), Location.DUMMY)
		), instructions);
	}

	@Test
	public void testGlobalVar() {
		final int rRet = 0;
		final int rArg1 = 1;
		final IRVar varGlobal = new IRVar("global", 0, VariableScope.global, Type.U8);
		final IRVar varOne = new IRVar("one", 0, VariableScope.function, Type.U8);
		final IRVar varLocalGlobal = new IRVar(LSPreprocessorCachedVarLayer.PREFIX + "global", 1, VariableScope.global, Type.U8);
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
						new IRLiteral(varOne, 1, Location.DUMMY),
						new IRBinary(varGlobal, IRBinary.Op.Add, varGlobal, varOne, Location.DUMMY),
						new IRRetValue(varGlobal, Location.DUMMY)
				)
		);
		final LSArchitecture architecture = new LSArchitecture(2, 0, 2, false);
		final List<IRInstruction> instructions = LSRegAlloc.process(function, architecture);
		IRTestUtils.assertEqualsInstructions(List.of(
				new IRLiteral(varOne.asRegister(rArg1), 1, Location.DUMMY),
				new IRMove(varLocalGlobal.asRegister(rRet), varGlobal, Location.DUMMY),
				new IRBinary(varLocalGlobal.asRegister(rRet), IRBinary.Op.Add, varLocalGlobal.asRegister(rRet), varOne.asRegister(rArg1), Location.DUMMY),
				new IRMove(varGlobal, varLocalGlobal.asRegister(rRet), Location.DUMMY)
		), instructions);
	}
}