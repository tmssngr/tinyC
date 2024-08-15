package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;
import org.junit.*;

import static com.regnis.tinyc.ParserTest.loc;

/**
 * @author Thomas Singer
 */
public class IRGeneratorTest {

	@Test
	public void testBreakContinue() {
		testIllegal(Messages.breakContinueOnlyAllowedWithinWhileOrFor(), 1, 2,
		            """
				            void foo() {
				              break;
				            }""");
		testIllegal(Messages.breakContinueOnlyAllowedWithinWhileOrFor(), 1, 2,
		            """
				            void foo() {
				              continue;
				            }""");
		assertEquals(new IRProgram(List.of(
				             new IRFunction("get", "@get", Type.U8, List.of(), List.of(
									 new IRComment("2:10 return 0"),
									 new IRComment("2:10 int lit 0"),
									 new IRLoadInt(0, 0, 1),
									 new IRReturnValue(0, 1),
									 new IRJump("@get_ret"),
									 new IRLabel("@get_ret")
				             ), List.of()),
				             new IRFunction("foo", "@foo", Type.VOID, List.of(
									 new IRLocalVar("chr", 0, false, 1)
				             ), List.of(
									 new IRComment("5:3 while true"),
									 new IRLabel("@while_1"),
									 new IRComment("5:10 bool lit true"),
									 new IRLoadInt(0, 1, 1),
									 new IRBranch(0, false, "@while_1_break",
									              "@while_1_body"),

									 new IRComment("6:14 call get"),
									 new IRCall("@get", List.of(), 0),
									 new IRComment("6:5 var chr(%0)"),
									 new IRAddrOfVar(1, VariableScope.function, 0),
									 new IRComment("6:5 assign"),
									 new IRMemStore(1, 0, 1),

									 new IRComment("7:5 if chr > 97"),
									 new IRComment("7:9 read var chr(%0)"),
									 new IRAddrOfVar(0, VariableScope.function, 0),
									 new IRMemLoad(1, 0, 1),
									 new IRComment("7:15 int lit 97"),
									 new IRLoadInt(0, 97, 1),
									 new IRComment("7:13 >"),
									 new IRCompare(IRCompare.Op.Gt, 2, 1, 0, Type.U8),
									 new IRBranch(2, false, "@if_2_end",
									              "@if_2_then"),
									 new IRJump("@while_1"),

									 new IRLabel("@if_2_end"),
									 new IRComment("10:5 if chr == 10"),
									 new IRComment("10:9 read var chr(%0)"),
									 new IRAddrOfVar(0, VariableScope.function, 0),
									 new IRMemLoad(1, 0, 1),
									 new IRComment("10:16 int lit 10"),
									 new IRLoadInt(0, 10, 1),
									 new IRComment("10:13 =="),
									 new IRCompare(IRCompare.Op.Equals, 2, 1, 0, Type.U8),
									 new IRBranch(2, false, "@if_3_end",
									              "@if_3_then"),
									 new IRJump("@while_1_break"),

									 new IRLabel("@if_3_end"),
									 new IRJump("@while_1"),
									 new IRLabel("@while_1_break"),
									 new IRLabel("@foo_ret")
				             ), List.of())
		             ), List.of(), List.of()),
		             convert("""
				                     u8 get() {
				                       return 0;
				                     }
				                     void foo() {
				                       while (true) {
				                         u8 chr = get();
				                         if (chr > 'a') {
				                           continue;
				                         }
				                         if (chr == '\\n') {
				                           break;
				                         }
				                       }
				                     }"""));
	}

	private void assertEquals(IRProgram expected, IRProgram actual) {
		TestUtils.assertEquals(expected.functions(), actual.functions(),
		                       this::assertEquals);
		Assert.assertEquals(expected, actual);
	}

	private void assertEquals(IRFunction expected, IRFunction actual) {
		TestUtils.assertEquals(expected.localVars(), actual.localVars(),
		                       this::assertEquals);
		TestUtils.assertEquals(expected.instructions(), actual.instructions(),
		                       this::assertEquals);
		Assert.assertEquals(expected, actual);
	}

	private void assertEquals(IRInstruction expected, IRInstruction actual) {
		Assert.assertEquals(expected, actual);
	}

	private void assertEquals(IRLocalVar expected, IRLocalVar actual) {
		Assert.assertEquals(expected, actual);
	}

	private void testIllegal(String expectedMessage, int row, int column, String input) {
		try {
			convert(input);
			Assert.fail("no exception thrown");
		}
		catch (SyntaxException ex) {
			Assert.assertEquals(loc(row, column) + " " + expectedMessage, ex.toString());
		}
	}

	@NotNull
	private IRProgram convert(String input) {
		final Program rawProgram = Parser.parse(input);
		final TypeChecker checker = new TypeChecker(Type.I64);
		final Program program = checker.check(rawProgram);
		return IRGenerator.convert(program);
	}
}