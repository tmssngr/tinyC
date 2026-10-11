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
		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(), Set.of(), null);

		final IRProgram program = convert("""
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
				                                  }""");
		assertEquals(new IRProgram(List.of(
				             new IRFunction("get", Type.U8, new IRVarInfos(List.of(
				             ), Set.of(), globalVarInfos), List.of(
						             new IRRetValue(new IRValue(0, Type.U8), loc(1, 2)),
						             new IRJump("get_ret"),
						             new IRLabel("get_ret")
				             )),
				             new IRFunction("foo", Type.VOID, new IRVarInfos(List.of(
						             new IRVarDef(new IRVar("chr", 0, VariableScope.function, Type.U8), 1)
				             ), Set.of(), globalVarInfos), List.of(
						             new IRComment("5:3 while true"),
						             new IRLabel("while_1"),
						             new IRCall(var("chr", 0, Type.U8), Type.U8, "get", List.of(), loc(5, 13)),
						             new IRComment("7:5 if chr > 97"),
									 new IRBranch(IRCompare.Op.LtEq, var("chr", 0, Type.U8), 97, "if_2_end",
									              "if_2_then", loc(6, 12)),
						             new IRLabel("if_2_then"),
						             new IRJump("while_1"),
						             new IRLabel("if_2_end"),
						             new IRComment("10:5 if chr == 10"),
						             new IRBranch(IRCompare.Op.NotEquals, var("chr", 0, Type.U8), 10, "if_3_end",
						                          "if_3_then", loc(9, 12)),
						             new IRLabel("if_3_then"),
						             new IRJump("while_1_break"),
						             new IRLabel("if_3_end"),
						             new IRJump("while_1"),
						             new IRLabel("while_1_break"),
						             new IRLabel("foo_ret")
				             ))
		             ), List.of(), globalVarInfos, List.of()),
		             program);
		assertEquals(new IRProgram(List.of(
				             new IRFunction("get", Type.U8,
				                            new IRVarInfos(List.of(
				                            ), Set.of(), globalVarInfos),
				                            List.of(
						                            new IRRetValue(new IRValue(0, Type.U8), loc(1, 2)),
						                            new IRJump("get_ret"),
						                            new IRLabel("get_ret")
				                            )),
				             new IRFunction("foo", Type.VOID,
				                            new IRVarInfos(List.of(
						                            new IRVarDef(new IRVar("chr", 0, VariableScope.function, Type.U8), 1)
				                            ), Set.of(), globalVarInfos),
				                            List.of(
						                            new IRComment("5:3 while true"),
						                            new IRLabel("while_1"),
						                            new IRCall(var("chr", 0, Type.U8), Type.U8, "get", List.of(), loc(5, 13)),
						                            new IRComment("7:5 if chr > 97"),
						                            new IRBranch(IRCompare.Op.Gt, var("chr", 0, Type.U8), 97, "while_1",
						                                         "if_2_end", loc(6, 12)),
						                            new IRLabel("if_2_end"),
						                            new IRComment("10:5 if chr == 10"),
						                            new IRBranch(IRCompare.Op.NotEquals, var("chr", 0, Type.U8), 10, "while_1",
						                                         "foo_ret", loc(9, 12)),
						                            new IRLabel("foo_ret")
				                            ))
		             ), List.of(), globalVarInfos, List.of()),
		             IROptimizer.branchAndLabelOptimizations(program));
	}

	@Test
	public void testSimplifiedIfElse() {
		final IRProgram program = convert("""
				                                  void print(u8 a) {
				                                  }
				                                  void foo() {
				                                    if true {
				                                      print('a')
				                                    }
				                                    else {
				                                      print('b')
				                                    }

				                                    if false {
				                                      print('c')
				                                    }
				                                    else {
				                                      print('d')
				                                    }

				                                    if true {
				                                      print('e')
				                                    }

				                                    if false {
				                                      print('f')
				                                    }

				                                    if true {
				                                      return
				                                    }

				                                    print(' ')
				                                  }""");
		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(), Set.of(), null);
		assertEquals(new IRProgram(List.of(
				new IRFunction("print@u8", Type.VOID,
				               new IRVarInfos(List.of(
						               new IRVarDef(new IRVar("a", 0, VariableScope.parameter, Type.U8), 1)
				               ), Set.of(), globalVarInfos),
				               List.of(
						               new IRLabel("print@u8_ret")
				               )),
				new IRFunction("foo", Type.VOID,
				               new IRVarInfos(List.of(), Set.of(), globalVarInfos),
				               List.of(
						               new IRCall(null, Type.VOID, "print@u8", List.of(new IRValue('a', Type.U8)), loc(4, 4)),
						               new IRCall(null, Type.VOID, "print@u8", List.of(new IRValue('d', Type.U8)), loc(14, 4)),
						               new IRCall(null, Type.VOID, "print@u8", List.of(new IRValue('e', Type.U8)), loc(18, 4)),
									   new IRComment("27:5 return"),
									   new IRJump("foo_ret"),
						               new IRLabel("foo_ret")
				               ))), List.of(), globalVarInfos, List.of()), program);
	}

	private void assertEquals(IRProgram expected, IRProgram actual) {
		TestUtils.assertEquals(expected.functions(), actual.functions(),
		                       this::assertEquals);
		Assert.assertEquals(expected, actual);
	}

	private void assertEquals(IRFunction expected, IRFunction actual) {
		TestUtils.assertEquals(expected.varInfos().vars(), actual.varInfos().vars(),
		                       this::assertEqualsVars);
		TestUtils.assertEquals(expected.instructions(), actual.instructions(),
		                       this::assertEquals);
		Assert.assertEquals(expected, actual);
	}

	private void assertEquals(IRInstruction expected, IRInstruction actual) {
		Assert.assertEquals(expected, actual);
	}

	private void assertEqualsVars(IRVarDef expected, IRVarDef actual) {
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
		final Type pointerIntType = Type.I64;
		final TypeChecker checker = new TypeChecker(pointerIntType, message -> Assert.fail("no message expected"));
		final Program program = checker.check(rawProgram);
		return IRGenerator.convert(program, pointerIntType);
	}

	@NotNull
	private static IRVar tmp(int index, Type type) {
		return var("t." + index, index, type);
	}

	@NotNull
	private static IRVar var(String name, int index, Type type) {
		return new IRVar(name, index, VariableScope.function, type);
	}
}
