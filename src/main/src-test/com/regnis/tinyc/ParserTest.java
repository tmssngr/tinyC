package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;
import org.junit.*;

/**
 * @author Thomas Singer
 */
public class ParserTest {

	public static void assertEquals(@NotNull Program expectedProgram, @NotNull Program currentProgram) {
		assertEquals(expectedProgram.globalVars(), currentProgram.globalVars());
		TestUtils.assertEquals(expectedProgram.functions(), currentProgram.functions(),
		                       ParserTest::assertEquals);
		TestUtils.assertEquals(expectedProgram.globalVariables(), currentProgram.globalVariables(),
		                       Assert::assertEquals);
		TestUtils.assertEquals(expectedProgram.stringLiterals(), currentProgram.stringLiterals(),
		                       Assert::assertEquals);
		Assert.assertEquals(expectedProgram, currentProgram);
	}

	public static Location loc(int line, int column) {
		return new Location(line, column);
	}

	@Test
	public void testDeclaration() {
		assertEquals(new Program(List.of(), List.of(
				             new StmtVarDeclaration("u8", "foo", null,
				                                    loc(0, 0))
		             ), List.of(), List.of(), List.of()),
		             parseProgram("u8 foo;"));

		assertEquals(new StmtVarDeclaration("u8", "foo", null,
		                                    locS(0, 0)),
		             parseStatement("u8 foo;"));

		assertEquals(new StmtVarDeclaration("u8", "foo", intLit(1, locS(0, 9)),
		                                    locS(0, 0)),
		             parseStatement("u8 foo = 1;"));

		assertEquals(new StmtVarDeclaration("i16", "foo", new ExprBinary(ExprBinary.Op.Add,
		                                                                 intLit(1, locS(1, 12)),
		                                                                 intLit(2, locS(1, 16)),
		                                                                 locS(1, 14)),
		                                    locS(1, 2)),
		             parseStatement("\n  i16 foo = 1 + 2;"));

		assertEquals(new StmtVarDeclaration("u16", "foo", new ExprBinary(ExprBinary.Op.Add,
		                                                                 new ExprBinary(ExprBinary.Op.Add,
		                                                                                intLit(1, locS(0, 10)),
		                                                                                intLit(2, locS(0, 14)),
		                                                                                locS(0, 12)),
		                                                                 intLit(3, locS(0, 18)),
		                                                                 locS(0, 16)),
		                                    locS(0, 0)),
		             parseStatement("u16 foo = 1 + 2 + 3;"));

		assertEquals(new StmtVarDeclaration("i16", "foo", new ExprBinary(ExprBinary.Op.Add,
		                                                                 new ExprBinary(ExprBinary.Op.Sub,
		                                                                                intLit(1, locS(0, 10)),
		                                                                                intLit(2, locS(0, 14)),
		                                                                                locS(0, 12)),
		                                                                 intLit(3, locS(0, 18)),
		                                                                 locS(0, 16)),
		                                    locS(0, 0)),
		             parseStatement("i16 foo = 1 - 2 + 3;"));

		assertEquals(new StmtVarDeclaration("i16", "foo", new ExprUnary(ExprUnary.Op.Neg,
		                                                                intLit(2, locS(0, 11)),
		                                                                locS(0, 10)),
		                                    locS(0, 0)),
		             parseStatement("i16 foo = -2;"));

		assertEquals(new StmtVarDeclaration("i16", "foo", new ExprBinary(ExprBinary.Op.Sub,
		                                                                 new ExprVarAccess("a", 0, null, null, locS(0, 10)),
		                                                                 intLit(2, locS(0, 12)),
		                                                                 locS(0, 11)),
		                                    locS(0, 0)),
		             parseStatement("i16 foo = a-2;"));

		assertEquals(new StmtVarDeclaration("i16*", "foo", new ExprVarAccess("bar", locS(0, 11)),
		                                    locS(0, 0)),
		             parseStatement("i16* foo = bar;"));

		assertEquals(new StmtVarDeclaration("u8*", "text", new ExprStringLiteral("hello", -1, locS(0, 11)),
		                                    locS(0, 0)),
		             parseStatement("u8* text = \"hello\";"));
	}

	@Test
	public void testAssignment() {
		assertEquals(assignStmt(new ExprVarAccess("foo", locS(0, 0)),
		                        new ExprBinary(ExprBinary.Op.Sub,
		                                       new ExprBinary(ExprBinary.Op.Add,
		                                                      intLit(1, locS(0, 6)),
		                                                      intLit(2, locS(0, 10)),
		                                                      locS(0, 8)),
		                                       intLit(3, locS(0, 14)),
		                                       locS(0, 12)),
		                        locS(0, 4)),
		             parseStatement("foo = 1 + 2 - 3;"));

		assertEquals(assignStmt(new ExprVarAccess("foo", locS(0, 0)),
		                        new ExprBinary(ExprBinary.Op.Add,
		                                       new ExprBinary(ExprBinary.Op.Multiply,
		                                                      intLit(1, locS(0, 6)),
		                                                      intLit(3, locS(0, 10)),
		                                                      locS(0, 8)),
		                                       new ExprBinary(ExprBinary.Op.Multiply,
		                                                      intLit(2, locS(0, 14)),
		                                                      intLit(4, locS(0, 18)),
		                                                      locS(0, 16)),
		                                       locS(0, 12)),
		                        locS(0, 4)),
		             parseStatement("foo = 1 * 3 + 2 * 4;"));

		assertEquals(assignStmt(new ExprVarAccess("foo", locS(0, 0)),
		                        new ExprBinary(ExprBinary.Op.Gt,
		                                       new ExprBinary(ExprBinary.Op.Add,
		                                                      intLit(1, locS(0, 6)),
		                                                      intLit(3, locS(0, 10)),
		                                                      locS(0, 8)),
		                                       new ExprBinary(ExprBinary.Op.Multiply,
		                                                      intLit(2, locS(0, 14)),
		                                                      intLit(4, locS(0, 18)),
		                                                      locS(0, 16)),
		                                       locS(0, 12)),
		                        locS(0, 4)),
		             parseStatement("foo = 1 + 3 > 2 * 4;"));

		assertEquals(assignStmt(new ExprVarAccess("foo", locS(0, 0)),
		                        new ExprBinary(ExprBinary.Op.Multiply,
		                                       new ExprIntLiteral(2, locS(0, 6)),
		                                       new ExprBinary(ExprBinary.Op.Add,
		                                                      new ExprVarAccess("bar", locS(0, 11)),
		                                                      new ExprIntLiteral(1, locS(0, 17)),
		                                                      locS(0, 15)),
		                                       locS(0, 8)),
		                        locS(0, 4)),
		             parseStatement("foo = 2 * (bar + 1);"));

		assertEquals(assignStmt(new ExprUnary(ExprUnary.Op.Deref,
		                                      new ExprVarAccess("foo", locS(0, 1)),
		                                      locS(0, 0)),
		                        new ExprVarAccess("bar", locS(0, 7)),
		                        locS(0, 5)),
		             parseStatement("*foo = bar;"));

		assertEquals(assignStmt(new ExprUnary(ExprUnary.Op.Deref,
		                                      new ExprBinary(ExprBinary.Op.Add,
		                                                     new ExprVarAccess("foo", locS(0, 2)),
		                                                     new ExprIntLiteral(2, locS(0, 8)),
		                                                     locS(0, 6)),
		                                      locS(0, 0)),
		                        new ExprVarAccess("bar", locS(0, 13)),
		                        locS(0, 11)),
		             parseStatement("*(foo + 2) = bar;"));

		assertEquals(assignStmt(new ExprVarAccess("text", locS(0, 0)),
		                        new ExprStringLiteral("hello", -1, locS(0, 7)),
		                        locS(0, 5)),
		             parseStatement("text = \"hello\";"));
	}

	@Test
	public void testCompound() {
		assertEquals(new StmtCompound(List.of(
				             new StmtVarDeclaration("u16", "foo", intLit(10, locS(1, 10)),
				                                    locS(1, 0)),
				             new StmtVarDeclaration("u8", "bar", intLit(20, locS(2, 9)),
				                                    locS(2, 0))
		             )),
		             parseStatement("""
				                            {
				                            u16 foo = 10;
				                            u8 bar = 20;
				                            }"""));
	}

	@Test
	public void testIf() {
		assertEquals(new StmtIf(new ExprBinary(ExprBinary.Op.Lt,
		                                       intLit(1, locS(0, 4)),
		                                       intLit(2, locS(0, 8)),
		                                       locS(0, 6)),
		                        List.of(printStmt(intLit(1, locS(1, 8)),
		                                          locS(1, 2))),
		                        List.of(printStmt(intLit(2, locS(4, 8)),
		                                          locS(4, 2))),
		                        locS(0, 0)
		             ),
		             parseStatement("""
				                            if (1 < 2) {
				                              print(1);
				                            }
				                            else {
				                              print(2);
				                            }"""));

		assertEquals(new StmtCompound(List.of(
				             new StmtIf(new ExprBinary(ExprBinary.Op.Gt,
				                                       new ExprVarAccess("i", 0, null, null, locS(1, 6)),
				                                       intLit(0, locS(1, 10)),
				                                       locS(1, 8)),
				                        List.of(
						                        new StmtIf(new ExprBinary(ExprBinary.Op.Gt,
						                                                  new ExprVarAccess("i", 0, null, null, locS(2, 8)),
						                                                  intLit(9, locS(2, 12)),
						                                                  locS(2, 10)),
						                                   List.of(
								                                   new StmtExpr(new ExprFuncCall("print1", List.of(), locS(3, 6)))
						                                   ),
						                                   List.of(
								                                   new StmtExpr(new ExprFuncCall("print2", List.of(), locS(6, 6)))
						                                   ),
						                                   locS(2, 4))
				                        ), List.of(), locS(1, 2))
		             )),
		             parseStatement("""
				                            {
				                              if (i > 0)
				                                if (i > 9) {
				                                  print1();
				                                }
				                                else {
				                                  print2();
				                                }
				                            }"""));
	}

	@Test
	public void testWhile() {
		assertEquals(new StmtCompound(List.of(
				new StmtVarDeclaration("u16", "i", intLit(5, locS(1, 8)),
				                       locS(1, 0)),
				new StmtLoop(new ExprBinary(ExprBinary.Op.Gt,
				                            new ExprVarAccess("i", locS(2, 7)),
				                            intLit(0, locS(2, 11)),
				                            locS(2, 9)),
				             List.of(
						             printStmt(new ExprVarAccess("i", locS(3, 8)),
						                       locS(3, 2)),
						             assignStmt(new ExprVarAccess("i", locS(4, 2)),
						                        new ExprBinary(ExprBinary.Op.Sub,
						                                       new ExprVarAccess("i", locS(4, 6)),
						                                       intLit(1, locS(4, 10)),
						                                       locS(4, 8)),
						                        locS(4, 4))
				             ),
				             List.of(),
				             locS(2, 0)
				)
		)), parseStatement("""
				                   {
				                   u16 i = 5;
				                   while (i > 0) {
				                     print(i);
				                     i = i - 1;
				                   }
				                   }"""));

		assertEquals(new StmtLoop(new ExprBoolLiteral(true, locS(0, 7)),
		                          List.of(
				                          printStmt(new ExprVarAccess("i", locS(1, 8)),
				                                    locS(1, 2))
		                          ),
		                          List.of(),
		                          locS(0, 0)),
		             parseStatement("""
				                            while (true) {
				                              print(i);
				                            }"""));
	}

	@Test
	public void testFor() {
		assertEquals(new StmtCompound(List.of(
				             new StmtVarDeclaration("i16", "i", intLit(0, locS(0, 13)),
				                                    locS(0, 5)),
				             new StmtLoop(new ExprBinary(ExprBinary.Op.Lt,
				                                         new ExprVarAccess("i", locS(0, 16)),
				                                         intLit(10, locS(0, 20)),
				                                         locS(0, 18)),
				                          List.of(
						                          printStmt(new ExprVarAccess("i", locS(1, 8)),
						                                    locS(1, 2))
				                          ),
				                          List.of(
						                          assignStmt(new ExprVarAccess("i", locS(0, 24)),
						                                     new ExprBinary(ExprBinary.Op.Add,
						                                                    new ExprVarAccess("i", locS(0, 28)),
						                                                    intLit(1, locS(0, 32)),
						                                                    locS(0, 30)),
						                                     locS(0, 26))
				                          ),
				                          locS(0, 0))
		             )),
		             parseStatement("""
				                            for (i16 i = 0; i < 10; i = i + 1) {
				                              print(i);
				                            }"""));

		assertEquals(new StmtCompound(List.of(
				             new StmtVarDeclaration("u8", "i", intLit(1, locS(1, 7)),
				                                    locS(1, 0)),
				             new StmtLoop(new ExprBinary(ExprBinary.Op.Lt, new ExprVarAccess("i", locS(2, 7)), intLit(10, locS(2, 11)), locS(2, 9)),
				                          List.of(
						                          printStmt(new ExprVarAccess("i", locS(3, 8)),
						                                    locS(3, 2))
				                          ),
				                          List.of(
						                          assignStmt(new ExprVarAccess("i", locS(2, 15)),
						                                     new ExprBinary(ExprBinary.Op.Add,
						                                                    new ExprVarAccess("i", locS(2, 19)),
						                                                    intLit(1, locS(2, 23)),
						                                                    locS(2, 21)),
						                                     locS(2, 17))
				                          ),
				                          locS(2, 0)
				             )
		             )),
		             parseStatement("""
				                            {
				                            u8 i = 1;
				                            for (; i < 10; i = i + 1) {
				                              print(i);
				                            }
				                            }"""));

		assertEquals(new StmtCompound(List.of(
				             new StmtVarDeclaration("u8", "i", intLit(5, locS(1, 7)),
				                                    locS(1, 0)),
				             new StmtLoop(new ExprBinary(ExprBinary.Op.Gt,
				                                         new ExprVarAccess("i", locS(2, 6)),
				                                         intLit(0, locS(2, 10)),
				                                         locS(2, 8)),
				                          List.of(
						                          printStmt(new ExprVarAccess("i", locS(3, 8)),
						                                    locS(3, 2)),
						                          assignStmt(new ExprVarAccess("i", locS(4, 2)),
						                                     new ExprBinary(ExprBinary.Op.Sub,
						                                                    new ExprVarAccess("i", locS(4, 6)),
						                                                    intLit(1, locS(4, 10)),
						                                                    locS(4, 8)),
						                                     locS(4, 4))
				                          ),
				                          List.of(),
				                          locS(2, 0))
		             )),
		             parseStatement("""
				                            {
				                            u8 i = 5;
				                            for (;i > 0;) {
				                              print(i);
				                              i = i - 1;
				                            }
				                            }"""));

		assertEquals(new StmtCompound(List.of(
				             new StmtVarDeclaration("u8", "i", intLit(5, locS(1, 7)),
				                                    locS(1, 0)),
				             new StmtLoop(new ExprIntLiteral(1, locS(2, 0)),
				                          List.of(
						                          printStmt(new ExprVarAccess("i", locS(3, 8)),
						                                    locS(3, 2)),
						                          assignStmt(new ExprVarAccess("i", locS(4, 2)),
						                                     new ExprBinary(ExprBinary.Op.Sub,
						                                                    new ExprVarAccess("i", locS(4, 6)),
						                                                    intLit(1, locS(4, 10)),
						                                                    locS(4, 8)),
						                                     locS(4, 4))
				                          ),
				                          List.of(),
				                          locS(2, 0))
		             )),
		             parseStatement("""
				                            {
				                            u8 i = 5;
				                            for (;;) {
				                              print(i);
				                              i = i - 1;
				                            }
				                            }"""));
	}

	@Test
	public void testFunctions() {
		Assert.assertEquals(new Program(List.of(), List.of(),
		                                List.of(
				                                Function.createInstance("main", "void", List.of(),
				                                                        List.of(
						                                                        new StmtVarDeclaration("u8", "i", intLit(10, loc(1, 11)),
						                                                                               loc(1, 4)),
						                                                        printStmt(new ExprVarAccess("i", loc(2, 10)),
						                                                                  loc(2, 4))
				                                                        ),
				                                                        loc(0, 0)),
				                                Function.createInstance("fooBar", "void", List.of(new Function.Arg("u8", "a", loc(4, 12))),
				                                                        List.of(),
				                                                        loc(4, 0))
		                                ),
		                                List.of(),
		                                List.of()
		                    ),
		                    parseProgram("""
				                                 void main() {
				                                     u8 i = 10;
				                                     print(i);
				                                 }
				                                 void fooBar(u8 a) {
				                                 }"""));

		assertEquals(new Program(List.of(), List.of(),
		                         List.of(
				                         Function.createInstance("main", "void", List.of(),
				                                                 List.of(
						                                                 new StmtVarDeclaration("u8", "i",
						                                                                        new ExprFuncCall("one", List.of(), loc(1, 11)),
						                                                                        loc(1, 4)),
						                                                 new StmtIf(new ExprBinary(ExprBinary.Op.Equals,
						                                                                           new ExprVarAccess("i", loc(2, 8)),
						                                                                           new ExprIntLiteral(0, loc(2, 13)),
						                                                                           loc(2, 10)),
						                                                            List.of(
								                                                            new StmtReturn(null, loc(3, 8))
						                                                            ),
						                                                            List.of(),
						                                                            loc(2, 4)),
						                                                 printStmt(new ExprVarAccess("i", loc(4, 10)),
						                                                           loc(4, 4))
				                                                 ),
				                                                 loc(0, 0)),
				                         Function.createInstance("one", "u8", List.of(),
				                                                 List.of(
						                                                 new StmtReturn(new ExprIntLiteral(1, loc(7, 10)),
						                                                                loc(7, 3))
				                                                 ),
				                                                 loc(6, 0))
		                         ),
		                         List.of(),
		                         List.of()
		             ),
		             parseProgram("""
				                          void main() {
				                              u8 i = one();
				                              if (i == 0)
				                                  return;
				                              print(i);
				                          }
				                          u8 one() {
				                             return 1;
				                          }"""));
	}

	@Test
	public void testArrays() {
		assertEquals(new Program(List.of(), List.of(
				             new StmtArrayDeclaration("u8", "str", 4,
				                                      loc(0, 0))
		             ), List.of(), List.of(), List.of()),
		             parseProgram("u8 str[4];"));

		assertEquals(new StmtArrayDeclaration("u8", "buffer", 256,
		                                      locS(0, 0)),
		             parseStatement("u8 buffer[256];"));

		assertEquals(assignStmt(new ExprArrayAccess(new ExprVarAccess("buffer", locS(0, 0)),
		                                            new ExprVarAccess("i", locS(0, 7))),
		                        new ExprArrayAccess(new ExprVarAccess("buffer", locS(0, 12)),
		                                            new ExprBinary(ExprBinary.Op.Add,
		                                                           new ExprVarAccess("i", locS(0, 19)),
		                                                           new ExprIntLiteral(1, locS(0, 23)),
		                                                           locS(0, 21))),
		                        locS(0, 10)),
		             parseStatement("buffer[i] = buffer[i + 1];"));
	}

	@Test
	public void testUnaryOperators() {
		assertEquals(assignStmt(new ExprVarAccess("a", locS(0, 0)),
		                        new ExprUnary(ExprUnary.Op.Neg,
		                                      new ExprVarAccess("a", locS(0, 5)),
		                                      locS(0, 4)),
		                        locS(0, 2)),
		             parseStatement("a = -a;"));

		assertEquals(assignStmt(new ExprVarAccess("a", locS(0, 0)),
		                        new ExprUnary(ExprUnary.Op.Com,
		                                      new ExprVarAccess("a", locS(0, 5)),
		                                      locS(0, 4)),
		                        locS(0, 2)),
		             parseStatement("a = ~a;"));

		assertEquals(assignStmt(new ExprVarAccess("a", locS(0, 0)),
		                        new ExprUnary(ExprUnary.Op.NotLog,
		                                      new ExprVarAccess("a", locS(0, 5)),
		                                      locS(0, 4)),
		                        locS(0, 2)),
		             parseStatement("a = !a;"));
	}

	@Test
	public void testCast() {
		assertEquals(assignStmt(new ExprVarAccess("b", locS(0, 0)),
		                        ExprCast.cast("u8", new ExprVarAccess("a", locS(0, 8)),
		                                      locS(0, 5)),
		                        locS(0, 2)),
		             parseStatement("b = (u8)a;"));
	}

	@Test
	public void testStruct() {
		assertEquals(new Program(List.of(
				             new TypeDef("Foo", null, List.of(
						             new TypeDef.Part("x", "u8", null, loc(0, 13)),
						             new TypeDef.Part("y", "u8", null, loc(0, 19))
				             ), loc(0, 0))
		             ), List.of(),
		                         List.of(
				                         Function.createInstance("bla", "void", List.of(),
				                                                 List.of(
						                                                 new StmtArrayDeclaration("Foo", "foos", 10, loc(3, 2)),
						                                                 assignStmt(new ExprMemberAccess(new ExprArrayAccess(new ExprVarAccess("foos", loc(4, 2)),
						                                                                                                     new ExprIntLiteral(0, loc(4, 7))),
						                                                                                 "x",
						                                                                                 null,
						                                                                                 loc(4, 10)),
						                                                            new ExprIntLiteral(1, loc(4, 14)),
						                                                            loc(4, 12))
				                                                 ),
				                                                 loc(2, 0)
				                         )
		                         ),
		                         List.of(),
		                         List.of()
		             ),
		             parseProgram("""
				                          typedef Foo (u8 x, u8 y);

				                          void bla() {
				                            Foo foos[10];
				                            foos[0].x = 1;
				                          }"""));
	}

	@Test
	public void testAsm() {
		assertEquals(new Program(List.of(), List.of(),
		                         List.of(
				                         Function.createAsmInstance("zero", "i64", List.of(), List.of(
						                                                    "mov rax, 0"
				                                                    ),
				                                                    loc(0, 0)
				                         )
		                         ),
		                         List.of(),
		                         List.of()
		             ),
		             parseProgram("""
				                          i64 zero() asm {
				                            "mov rax, 0"
				                          }"""));
	}

	@Test
	public void testConst() {
		assertEquals(new Program(List.of(), List.of(),
		                         List.of(
				                         Function.createInstance("zero", "i64", List.of(), List.of(
						                                                 new StmtReturn(new ExprIntLiteral(0, loc(3, 9)),
						                                                                loc(3, 2)
						                                                 )
				                                                 ),
				                                                 loc(2, 0)
				                         )
		                         ),
		                         List.of(),
		                         List.of()
		             ),
		             parseProgram("""
				                          const TEN = 10;
				                          const ZERO = TEN - 5 * 2;
				                          i64 zero() {
				                            return ZERO;
				                          }"""));

		assertEquals(new Program(List.of(),
		                         List.of(
				                         new StmtArrayDeclaration("u8", "a", 0, null, null, 10, loc(1, 0))
		                         ),
		                         List.of(
				                         new Function("foo", "void", null, List.of(),
				                                      List.of(),
				                                      List.of(
						                                      new StmtArrayDeclaration("u8", "b", 0, null, null, 11, loc(3, 2))
				                                      ),
				                                      List.of(), loc(2, 0))
		                         ),
		                         List.of(),
		                         List.of()
		             ),
		             parseProgram("""
				                          const TEN = 10;
				                          u8 a[TEN];
				                          void foo() {
				                            u8 b[TEN + 1];
				                          }"""));
	}

	@NotNull
	private static Program parseProgram(String text) {
		return Parser.parse(text);
	}

	@NotNull
	private static Statement parseStatement(String text) {
		final Program program = parseProgram("void main() {\n" + text + "\n}");
		return program.functions().getFirst().statements().getFirst();
	}

	@NotNull
	private static Location locS(int line, int column) {
		return new Location(line + 1, column);
	}

	@NotNull
	private static StmtExpr assignStmt(Expression left, Expression right, Location loc) {
		return new StmtExpr(new ExprBinary(ExprBinary.Op.Assign,
		                                   left,
		                                   right,
		                                   loc));
	}

	private static Statement printStmt(Expression expression, Location loc) {
		return new StmtExpr(new ExprFuncCall("print", List.of(expression), loc));
	}

	private static ExprIntLiteral intLit(int value, Location location) {
		return new ExprIntLiteral(value, location);
	}

	private static void assertEquals(@NotNull Function expectedFunction, @NotNull Function currentFunction) {
		Assert.assertEquals(expectedFunction.name(), currentFunction.name());
		Assert.assertEquals(expectedFunction.typeString(), currentFunction.typeString());
		Assert.assertEquals(expectedFunction.returnType(), currentFunction.returnType());
		Assert.assertEquals(expectedFunction.args(), currentFunction.args());
		Assert.assertEquals(expectedFunction.localVars(), currentFunction.localVars());
		Assert.assertEquals(expectedFunction.location(), currentFunction.location());
		assertEquals(expectedFunction.statements(), currentFunction.statements());
		Assert.assertEquals(expectedFunction.asmLines(), currentFunction.asmLines());
		Assert.assertEquals(expectedFunction, currentFunction);
	}

	private static void assertEquals(List<Statement> expectedStatements, List<Statement> currentStatements) {
		TestUtils.assertEquals(expectedStatements, currentStatements,
		                       ParserTest::assertEquals);
	}

	private static void assertEquals(@Nullable Statement expectedStatement, @Nullable Statement currentStatement) {
		if (expectedStatement == null) {
			Assert.assertNull(currentStatement);
			return;
		}

		Assert.assertNotNull(currentStatement);
		if (expectedStatement instanceof StmtCompound expC
		    && currentStatement instanceof StmtCompound currC) {
			assertEquals(expC.statements(), currC.statements());
		}
		else if (expectedStatement instanceof StmtIf expIf
		         && currentStatement instanceof StmtIf currIf) {
			assertEquals(expIf.condition(), currIf.condition());
			assertEquals(expIf.thenStatements(), currIf.thenStatements());
			assertEquals(expIf.elseStatements(), currIf.elseStatements());
		}
		else if (expectedStatement instanceof StmtLoop expLoop
		         && currentStatement instanceof StmtLoop currLoop) {
			assertEquals(expLoop.condition(), currLoop.condition());
			assertEquals(expLoop.bodyStatements(), currLoop.bodyStatements());
			assertEquals(expLoop.iteration(), currLoop.iteration());
		}
		else if (expectedStatement instanceof StmtExpr expExpr
		         && currentStatement instanceof StmtExpr currExpr) {
			assertEquals(expExpr.expression(), currExpr.expression());
		}
		else if (expectedStatement instanceof StmtVarDeclaration expDecl
		         && currentStatement instanceof StmtVarDeclaration currDecl) {
			assertEquals(expDecl.expression(), currDecl.expression());
		}
		Assert.assertEquals(expectedStatement, currentStatement);
	}

	private static void assertEquals(@Nullable Expression expectedNode, @Nullable Expression currentNode) {
		if (expectedNode == null) {
			Assert.assertNull(currentNode);
			return;
		}

		Assert.assertNotNull(currentNode);
		if (expectedNode instanceof ExprBinary exprBinary
		    && currentNode instanceof ExprBinary currBinary) {
			assertEquals(exprBinary.left(), currBinary.left());
			assertEquals(exprBinary.right(), currBinary.right());
		}
		else if (expectedNode instanceof ExprUnary expDeref
		         && currentNode instanceof ExprUnary currDeref) {
			assertEquals(expDeref.expression(), currDeref.expression());
		}
		else if (expectedNode instanceof ExprArrayAccess exprArray
		         && currentNode instanceof ExprArrayAccess currArray) {
			assertEquals(exprArray.index(), currArray.index());
		}
		Assert.assertEquals(expectedNode.getClass(), currentNode.getClass());
		Assert.assertEquals(expectedNode.location(), currentNode.location());
		Assert.assertEquals(expectedNode, currentNode);
	}
}