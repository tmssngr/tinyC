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
				             new IRFunction("get", "@get", Type.U8, List.of(
						             new IRLocalVar("t.0", 0, false, 1)
				             ), List.of(
						             new IRComment("2:10 return 0"),
						             new IRLiteral(tmp(0, Type.U8), 0, loc(1, 9)),
						             new IRRetValue(tmp(0, Type.U8), loc(1, 2)),
						             new IRJump("@get_ret"),
						             new IRLabel("@get_ret")
				             ), List.of()),
				             new IRFunction("foo", "@foo", Type.VOID, List.of(
						             new IRLocalVar("chr", 0, false, 1),
						             new IRLocalVar("t.1", 1, false, 1),
						             new IRLocalVar("t.2", 2, false, 1),
						             new IRLocalVar("t.3", 3, false, 1),
						             new IRLocalVar("t.4", 4, false, 1)
				             ), List.of(
						             new IRComment("5:3 while true"),
						             new IRLabel("@while_1"),
						             new IRCall(var("chr", 0, Type.U8), "get", List.of(), loc(5, 13)),
						             new IRComment("7:5 if chr > 97"),
						             new IRLiteral(tmp(2, Type.U8), 97, loc(6, 14)),
						             new IRBinary(tmp(1, Type.BOOL), IRBinary.Op.Gt, var("chr", 0, Type.U8), tmp(2, Type.U8), loc(6, 12)),
						             new IRBranch(tmp(1, Type.BOOL), false, "@if_2_end",
						                          "@if_2_then"),
						             new IRJump("@while_1"),
						             new IRLabel("@if_2_end"),
						             new IRComment("10:5 if chr == 10"),
						             new IRLiteral(tmp(4, Type.U8), 10, loc(9, 15)),
						             new IRBinary(tmp(3, Type.BOOL), IRBinary.Op.Equals, var("chr", 0, Type.U8), tmp(4, Type.U8), loc(9, 12)),
						             new IRBranch(tmp(3, Type.BOOL), false, "@if_3_end",
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
		final Program rawProgram = Parser.parse(input, Set.of());
		final TypeChecker checker = new TypeChecker(Type.I64);
		final Program program = checker.check(rawProgram);
		return IRGenerator.convert(program);
	}

	@NotNull
	private static IRVar tmp(int index, Type type) {
		return var("t." + index, index, type);
	}

	@NotNull
	private static IRVar var(String name, int index, Type type) {
		return new IRVar(name, index, VariableScope.function, type, true);
	}
}