package com.regnis.tinyc.ir.interpreter;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;
import org.junit.*;

import static org.junit.Assert.*;

/**
 * @author Thomas Singer
 */
public class InterpreterTest {

	@Test
	public void testPointers() {
		final Type pointerI16 = Type.pointer(Type.I16);
		final IRVar varA = new IRVar("a", 0, VariableScope.function, Type.I16);
		final IRVar varB = new IRVar("b", 1, VariableScope.function, pointerI16);
		final IRVar varC = new IRVar("c", 2, VariableScope.function, Type.I16);
		final IRVar varD = new IRVar("d", 3, VariableScope.function, pointerI16);
		final IRVar varT4 = new IRVar("t.4", 4, VariableScope.function, Type.I16);
		final IRVar varT5 = new IRVar("t.5", 5, VariableScope.function, Type.I16);
		final IRVar varT6 = new IRVar("t.6", 6, VariableScope.function, Type.I16);
		final IRVar varT7 = new IRVar("t.7", 7, VariableScope.function, Type.I16);
		final IRVar varT8 = new IRVar("t.8", 8, VariableScope.function, Type.I16);

		final List<Integer> printedValues = new ArrayList<>();
		final Interpreter interpreter = new Interpreter(new IRFunction("main", "@main", Type.VOID,
		                                                               new IRVarInfos(List.of(
				                                                               new IRVarDef(varA, 2),
				                                                               new IRVarDef(varB, 8),
				                                                               new IRVarDef(varC, 2),
				                                                               new IRVarDef(varD, 8),
				                                                               new IRVarDef(varT4, 2),
				                                                               new IRVarDef(varT5, 2),
				                                                               new IRVarDef(varT6, 2),
				                                                               new IRVarDef(varT7, 2),
				                                                               new IRVarDef(varT8, 2)
		                                                               ), Set.of(), new IRVarInfos(List.of(), Set.of(), null)),
		                                                               List.of(
				                                                               new IRLiteral(varA, 10),
				                                                               new IRCall(null, Type.VOID, "printIntLf", List.of(varA)),
				                                                               new IRAddrOf(varB, varA),
				                                                               new IRMemLoad(varT4, varB),
				                                                               new IRLiteral(varT5, 1),
				                                                               new IRMove(varC, varT4),
				                                                               new IRBinary(varC, IRBinary.Op.Sub, varC, varT5),
				                                                               new IRCall(null, Type.VOID, "printIntLf", List.of(varC)),
				                                                               new IRAddrOf(varD, varC),
				                                                               new IRMemLoad(varT7, varD),
				                                                               new IRLiteral(varT8, 1),
				                                                               new IRMove(varT6, varT7),
				                                                               new IRBinary(varT6, IRBinary.Op.Sub, varT6, varT8),
				                                                               new IRMemStore(varD, varT6),
				                                                               new IRCall(null, Type.VOID, "printIntLf", List.of(varC))
		                                                               )),
		                                                (name, args) -> {
			                                                Assert.assertEquals("printIntLf", name);
			                                                Assert.assertEquals(1, args.size());
			                                                Assert.assertEquals(Type.I16, args.get(0).type());
			                                                final Interpreter.IntValue value = (Interpreter.IntValue)args.get(0);
			                                                printedValues.add(value.value());
			                                                return null;
		                                                });
		interpreter.run(100);
		assertEquals(List.of(10, 9, 8), printedValues);
	}

	@Test
	public void testPrintUint() {
		final IRVar varNumber = new IRVar("number", 0, VariableScope.parameter, Type.I32);
		final IRVar varPos = new IRVar("pos", 1, VariableScope.function, Type.U8);
		final IRVar varBool = new IRVar("bool", 2, VariableScope.function, Type.BOOL);
		final IRVar varValue8 = new IRVar("value8", 3, VariableScope.function, Type.U8);
		final IRVar varValue32 = new IRVar("value32", 4, VariableScope.function, Type.I32);
		final IRVar varValue64 = new IRVar("value64", 5, VariableScope.function, Type.I64);
		final IRVar varRemainder = new IRVar("remainder", 6, VariableScope.function, Type.I32);
		final IRVar varDigit = new IRVar("digit", 7, VariableScope.function, Type.U8);
		final IRVar varMem = new IRVar("mem", 8, VariableScope.function, Type.POINTER_U8);
		final IRVar varBuffer = new IRVar("buffer", 9, VariableScope.function, Type.POINTER_U8);
		final String labelLoop = "loop";
		final String labelBreak = "break";
		final Interpreter interpreter = new Interpreter(new IRFunction("printUint", "printUint", Type.VOID,
		                                                               new IRVarInfos(List.of(
				                                                               new IRVarDef(varNumber, 4),
				                                                               new IRVarDef(varPos, 1),
				                                                               new IRVarDef(varBool, 1),
				                                                               new IRVarDef(varValue8, 1),
				                                                               new IRVarDef(varValue32, 4),
				                                                               new IRVarDef(varValue64, 4),
				                                                               new IRVarDef(varRemainder, 4),
				                                                               new IRVarDef(varDigit, 1),
				                                                               new IRVarDef(varMem, 8),
				                                                               new IRVarDef(varBuffer, 20, true)
		                                                               ), Set.of(), new IRVarInfos(List.of(), Set.of(), null)),
		                                                               List.of(
																			   new IRLiteral(varNumber, 100),

				                                                               new IRLiteral(varPos, 20),

				                                                               new IRLabel(labelLoop),
				                                                               new IRLiteral(varValue8, 1),
				                                                               new IRBinary(varPos, IRBinary.Op.Sub, varPos, varValue8),
				                                                               new IRMove(varRemainder, varNumber),
																			   new IRLiteral(varValue32, 10),
				                                                               new IRBinary(varRemainder, IRBinary.Op.Mod, varRemainder, varValue32),
																			   new IRCast(varDigit, varRemainder),
				                                                               new IRBinary(varNumber, IRBinary.Op.Div, varNumber, varValue32),
				                                                               new IRLiteral(varValue8, 48),
				                                                               new IRBinary(varDigit, IRBinary.Op.Add, varDigit, varValue8),
																			   new IRCast(varValue64, varPos),
				                                                               new IRAddrOfArray(varMem, varBuffer),
				                                                               new IRBinary(varMem, IRBinary.Op.Add, varMem, varValue64),
				                                                               new IRMemStore(varMem, varDigit),
				                                                               new IRLiteral(varValue32, 0),
				                                                               new IRCompare(varBool, IRCompare.Op.Equals, varNumber, varValue32),
				                                                               new IRBranch(varBool, false, labelLoop, labelBreak),

				                                                               new IRLabel(labelBreak),
																			   new IRCast(varValue64, varPos),
																			   new IRAddrOfArray(varMem, varBuffer),
																			   new IRBinary(varMem, IRBinary.Op.Add, varMem, varValue64),
																			   new IRLiteral(varValue8, 20),
																			   new IRBinary(varValue8, IRBinary.Op.Sub, varValue8, varPos),
																			   new IRCall(null, Type.VOID, "printStringLength", List.of(varMem, varValue8))
		                                                               )),
		                                                (name, args) -> {
															Assert.assertEquals("printStringLength", name);
			                                                Assert.assertEquals(2, args.size());
			                                                Assert.assertEquals(new Interpreter.IntValue(3, Type.U8), args.get(1));
			                                                final Interpreter.PointerValue pointerValue = (Interpreter.PointerValue)args.get(0);
															assertEquals(new Interpreter.IntValue('1', Type.U8), pointerValue.get(0));
															assertEquals(new Interpreter.IntValue('0', Type.U8), pointerValue.get(1));
															assertEquals(new Interpreter.IntValue('0', Type.U8), pointerValue.get(2));
			                                                return null;
		                                                });
		interpreter.run(100);
	}
}
