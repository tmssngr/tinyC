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
						             new IRComment("2:10 return 0"),
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
						                            new IRComment("2:10 return 0"),
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
	public void testStructs() {
		final IRProgram program = convert("""
				                                  typedef Pos struct (u8 x, u8 y);
				                                  void main() {
				                                  	Pos pos;
				                                  	pos.x = 1
				                                  	pos.y = 2
				                                  	print(pos.x)
				                                  	print(pos.y)
				                                  }
				                                  void print(u8 a) {}""");
		final IRVar varPos = new IRVar("pos", 0, VariableScope.function, Type.U8);
		final IRVar varT1 = new IRVar("t.1", 1, VariableScope.function, Type.U8);
		final IRVar varT2 = new IRVar("t.2", 2, VariableScope.function, Type.POINTER_U8);
		final IRVar varT3 = new IRVar("t.3", 3, VariableScope.function, Type.U8);
		final IRVar varT4 = new IRVar("t.4", 4, VariableScope.function, Type.POINTER_U8);
		final IRVar varT5 = new IRVar("t.5", 5, VariableScope.function, Type.U8);
		final IRVar varT6 = new IRVar("t.6", 6, VariableScope.function, Type.POINTER_U8);
		final IRVar varT7 = new IRVar("t.7", 7, VariableScope.function, Type.U8);
		final IRVar varT8 = new IRVar("t.8", 8, VariableScope.function, Type.POINTER_U8);
		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(), Set.of(), null);
		assertEquals(new IRProgram(List.of(
				             new IRFunction("main", Type.VOID,
				                            new IRVarInfos(List.of(
						                            new IRVarDef(varPos, 2),
						                            new IRVarDef(varT1, 1),
						                            new IRVarDef(varT2, 8),
						                            new IRVarDef(varT3, 1),
						                            new IRVarDef(varT4, 8),
						                            new IRVarDef(varT5, 1),
						                            new IRVarDef(varT6, 8),
						                            new IRVarDef(varT7, 1),
						                            new IRVarDef(varT8, 8)
				                            ), Set.of(varPos), globalVarInfos),
				                            List.of(
						                            new IRMove(varT1, 1, loc(3, 9)),
						                            new IRComment("4:6 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=4:2].x"),
						                            new IRAddrOf(varT2, varPos, loc(3, 5)),
						                            new IRMemStore(varT2, varT1, loc(3, 5)),
						                            new IRMove(varT3, 2, loc(4, 9)),
						                            new IRComment("5:6 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=5:2].y"),
						                            new IRAddrOf(varT4, varPos, loc(4, 5)),
						                            new IRBinary(varT4, IRBinary.Op.Add, varT4, new IRValue(1, Type.I64), ParserTest.loc(4, 5)),
						                            new IRMemStore(varT4, varT3, loc(4, 5)),
						                            new IRComment("6:12 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=6:8].x"),
						                            new IRAddrOf(varT6, varPos, loc(5, 11)),
						                            new IRMemLoad(varT5, varT6, loc(5, 11)),
						                            new IRCall(null, Type.VOID, "print@u8", List.of(new IRValue(varT5)), loc(5, 1)),
						                            new IRComment("7:12 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=7:8].y"),
						                            new IRAddrOf(varT8, varPos, loc(6, 11)),
						                            new IRBinary(varT8, IRBinary.Op.Add, varT8, new IRValue(1, Type.I64), ParserTest.loc(6, 11)),
						                            new IRMemLoad(varT7, varT8, loc(6, 11)),
						                            new IRCall(null, Type.VOID, "print@u8", List.of(new IRValue(varT7)), loc(6, 1)),
						                            new IRLabel("main_ret")
				                            )
				             ),
				             new IRFunction("print@u8", Type.VOID,
				                            new IRVarInfos(List.of(
						                            new IRVarDef(new IRVar("a", 0, VariableScope.parameter, Type.U8), 1)
				                            ), Set.of(), globalVarInfos),
				                            List.of(
						                            new IRLabel("print@u8_ret")
				                            )
				             )
		             ), List.of(), globalVarInfos, List.of()),
		             program);
	}

	@Test
	public void testReferencedLocalVars() {
		final IRProgram program = convert("""
				                                  void print(i16 p) {
				                                  }

				                                  void main() {
				                                    i16 a = 17
				                                    print(a)
				                                    i16* b = &a
				                                    *b = a + 1
				                                    print(*b)
				                                  }""");
		final IRVar varA = new IRVar("a", 0, VariableScope.function, Type.I16);
		final IRVar varB = new IRVar("b", 1, VariableScope.function, Type.pointer(Type.I16));
		final IRVar varT2 = new IRVar("t.2", 2, VariableScope.function, Type.I16);
		final IRVar varA3 = new IRVar("a.3", 3, VariableScope.function, Type.pointer(Type.I16));
		final IRVar varA4 = new IRVar("a.4", 4, VariableScope.function, Type.pointer(Type.I16));
		final IRVar varT5 = new IRVar("t.5", 5, VariableScope.function, Type.I16);
		final IRVar varT6 = new IRVar("t.6", 6, VariableScope.function, Type.I16);
		final IRVar varA7 = new IRVar("a.7", 7, VariableScope.function, Type.pointer(Type.I16));
		final IRVar varT8 = new IRVar("t.8", 8, VariableScope.function, Type.I16);
		final IRVar varT9 = new IRVar("t.9", 9, VariableScope.function, Type.I16);
		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(), Set.of(), null);
		assertEquals(new IRProgram(List.of(
				             new IRFunction("print@i16", Type.VOID, new IRVarInfos(List.of(
									 new IRVarDef(new IRVar("p", 0, VariableScope.parameter, Type.I16), 2)
				             ), Set.of(), globalVarInfos), List.of(
									 new IRLabel("print@i16_ret")
				             )),
				             new IRFunction("main", Type.VOID, new IRVarInfos(List.of(
						             new IRVarDef(varA, 2),
						             new IRVarDef(varB, 8),
						             new IRVarDef(varT2, 2),
						             new IRVarDef(varA3, 8),
						             new IRVarDef(varA4, 8),
						             new IRVarDef(varT5, 2),
						             new IRVarDef(varT6, 2),
						             new IRVarDef(varA7, 8),
						             new IRVarDef(varT8, 2),
						             new IRVarDef(varT9, 2)
				             ), Set.of(varA), globalVarInfos), List.of(
									 new IRMove(varT2, 17, loc(4, 10)),
									 new IRAddrOf(varA3, varA),
									 new IRMemStore(varA3, varT2),
									 new IRAddrOf(varA4, varA),
									 new IRMemLoad(varT5, varA4),
									 new IRCall(null, Type.VOID, "print@i16", List.of(new IRValue(varT5)), loc(5, 2)),
									 new IRAddrOf(varB, varA, loc(6, 11)),
									 new IRAddrOf(varA7, varA),
									 new IRMemLoad(varT8, varA7),
									 new IRBinary(varT6, IRBinary.Op.Add, varT8, 1, loc(7, 9)),
									 new IRMemStore(varB, varT6, loc(7, 2)),
									 new IRMemLoad(varT9, varB, loc(8, 8)),
									 new IRCall(null, Type.VOID, "print@i16", List.of(new IRValue(varT9)), loc(8, 2)),
									 new IRLabel("main_ret")
				             ))
		             ), List.of(), globalVarInfos, List.of()),
		             program);
	}

	@Test
	public void testGlobalVars() {
		final IRProgram program = convert("""
				                                  u8 global = 0

				                                  void print(u8 p) {
				                                  }

				                                  void main() {
				                                    print(global)
				                                    global = global + 1
				                                    print(global)
				                                  }""");
		final IRVar varGlobal = new IRVar("global", 0, VariableScope.global, Type.U8);
		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(
				new IRVarDef(varGlobal, 1)
		), Set.of(), null);
		final IRVar varT0 = new IRVar("t.0", 0, VariableScope.function, Type.U8);
		final IRVar varA1 = new IRVar("a.1", 1, VariableScope.function, Type.POINTER_U8);
		final IRVar varA2 = new IRVar("a.2", 2, VariableScope.function, Type.POINTER_U8);
		final IRVar varT3 = new IRVar("t.3", 3, VariableScope.function, Type.U8);
		final IRVar varT4 = new IRVar("t.4", 4, VariableScope.function, Type.U8);
		final IRVar varA5 = new IRVar("a.5", 5, VariableScope.function, Type.POINTER_U8);
		final IRVar varT6 = new IRVar("t.6", 6, VariableScope.function, Type.U8);
		final IRVar varA7 = new IRVar("a.7", 7, VariableScope.function, Type.POINTER_U8);
		final IRVar varA8 = new IRVar("a.8", 8, VariableScope.function, Type.POINTER_U8);
		final IRVar varT9 = new IRVar("t.9", 9, VariableScope.function, Type.U8);
		assertEquals(new IRProgram(List.of(
				             new IRFunction("print@u8", Type.VOID, new IRVarInfos(List.of(
						             new IRVarDef(new IRVar("p", 0, VariableScope.parameter, Type.U8), 1)
				             ), Set.of(), globalVarInfos), List.of(
						             new IRLabel("print@u8_ret")
				             )),
				             new IRFunction("main", Type.VOID, new IRVarInfos(List.of(
						             new IRVarDef(varT0, 1),
						             new IRVarDef(varA1, 8),
						             new IRVarDef(varA2, 8),
						             new IRVarDef(varT3, 1),
						             new IRVarDef(varT4, 1),
						             new IRVarDef(varA5, 8),
						             new IRVarDef(varT6, 1),
						             new IRVarDef(varA7, 8),
						             new IRVarDef(varA8, 8),
						             new IRVarDef(varT9, 1)
				             ), Set.of(), globalVarInfos), List.of(
									 new IRComment("begin initialize global variables"),
						             new IRMove(varT0, 0, loc(0, 12)),
									 new IRAddrOf(varA1, varGlobal),
									 new IRMemStore(varA1, varT0),
									 new IRComment("end initialize global variables"),
									 new IRAddrOf(varA2, varGlobal),
									 new IRMemLoad(varT3, varA2),
						             new IRCall(null, Type.VOID, "print@u8", List.of(new IRValue(varT3)), loc(6, 2)),
									 new IRAddrOf(varA5, varGlobal),
									 new IRMemLoad(varT6, varA5),
									 new IRBinary(varT4, IRBinary.Op.Add, varT6, 1, loc(7, 18)),
									 new IRAddrOf(varA7, varGlobal),
									 new IRMemStore(varA7, varT4),
									 new IRAddrOf(varA8, varGlobal),
									 new IRMemLoad(varT9, varA8),
									 new IRCall(null, Type.VOID, "print@u8", List.of(new IRValue(varT9)), loc(8, 2)),
						             new IRLabel("main_ret")
				             ))
		             ), List.of(), globalVarInfos, List.of()),
		             program);
	}

	private void assertEquals(IRProgram expected, IRProgram actual) {
		TestUtils.assertEquals(expected.functions(), actual.functions(),
		                       this::assertEquals);
		Assert.assertEquals(expected, actual);
	}

	private void assertEquals(IRFunction expected, IRFunction actual) {
		TestUtils.assertEquals(expected.varInfos().vars(), actual.varInfos().vars(),
		                       this::assertEqualsVars);
		IRTestUtils.assertEqualsInstructions(expected.instructions(), actual.instructions());
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
	private static IRVar var(String name, int index, Type type) {
		return new IRVar(name, index, VariableScope.function, type);
	}
}