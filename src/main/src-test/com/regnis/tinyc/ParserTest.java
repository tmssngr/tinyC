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
	}

	public static Location loc(int line, int column) {
		return new Location(line, column);
	}

	@Test
	public void testDeclaration() {
		assertEquals(new Program(List.of(
				             new StmtVarDeclaration("u8", "foo", null,
				                                    loc(0, 0))
		             ), List.of(), List.of(), List.of()),
		             new Parser(new Lexer("u8 foo;")).parse());

		assertEquals(new StmtVarDeclaration("u8", "foo", null,
		                                    loc(0, 0)),
		             new Parser(new Lexer("u8 foo;")).getStatementNotNull());

		assertEquals(new StmtVarDeclaration("u8", "foo", intLit(1, loc(0, 9)),
		                                    loc(0, 0)),
		             new Parser(new Lexer("u8 foo = 1;")).getStatementNotNull());

		assertEquals(new StmtVarDeclaration("i16", "foo", new ExprBinary(ExprBinary.Op.Add,
		                                                                 intLit(1, loc(1, 12)),
		                                                                 intLit(2, loc(1, 16)),
		                                                                 loc(1, 14)),
		                                    loc(1, 2)),
		             new Parser(new Lexer("\n  i16 foo = 1 + 2;")).getStatementNotNull());

		assertEquals(new StmtVarDeclaration("u16", "foo", new ExprBinary(ExprBinary.Op.Add,
		                                                                 new ExprBinary(ExprBinary.Op.Add,
		                                                                                intLit(1, loc(0, 10)),
		                                                                                intLit(2, loc(0, 14)),
		                                                                                loc(0, 12)),
		                                                                 intLit(3, loc(0, 18)),
		                                                                 loc(0, 16)),
		                                    loc(0, 0)),
		             new Parser(new Lexer("u16 foo = 1 + 2 + 3;")).getStatementNotNull());

		assertEquals(new StmtVarDeclaration("i16", "foo", new ExprBinary(ExprBinary.Op.Add,
		                                                                 new ExprBinary(ExprBinary.Op.Sub,
		                                                                                intLit(1, loc(0, 10)),
		                                                                                intLit(2, loc(0, 14)),
		                                                                                loc(0, 12)),
		                                                                 intLit(3, loc(0, 18)),
		                                                                 loc(0, 16)),
		                                    loc(0, 0)),
		             new Parser(new Lexer("i16 foo = 1 - 2 + 3;")).getStatementNotNull());

		assertEquals(new StmtVarDeclaration("i16", "foo", new ExprUnary(ExprUnary.Op.Neg,
		                                                                intLit(2, loc(0, 11)),
		                                                                loc(0, 10)),
		                                    loc(0, 0)),
		             new Parser(new Lexer("i16 foo = -2;")).getStatementNotNull());

		assertEquals(new StmtVarDeclaration("i16", "foo", new ExprBinary(ExprBinary.Op.Sub,
		                                                                 new ExprVarAccess("a", 0, null, null, null, loc(0, 10)),
		                                                                 intLit(2, loc(0, 12)),
		                                                                 loc(0, 11)),
		                                    loc(0, 0)),
		             new Parser(new Lexer("i16 foo = a-2;")).getStatementNotNull());

		assertEquals(new StmtVarDeclaration("i16*", "foo", ExprVarAccess.scalar("bar", loc(0, 11)),
		                                    loc(0, 0)),
		             new Parser(new Lexer("i16* foo = bar;")).getStatementNotNull());

		assertEquals(new StmtVarDeclaration("u8*", "text", new ExprStringLiteral("hello", -1, loc(0, 11)),
		                                    loc(0, 0)),
		             new Parser(new Lexer("u8* text = \"hello\";")).getStatementNotNull());
	}

	@Test
	public void testAssignment() {
		assertEquals(assignStmt(ExprVarAccess.scalar("foo", loc(0, 0)),
		                        new ExprBinary(ExprBinary.Op.Sub,
		                                       new ExprBinary(ExprBinary.Op.Add,
		                                                      intLit(1, loc(0, 6)),
		                                                      intLit(2, loc(0, 10)),
		                                                      loc(0, 8)),
		                                       intLit(3, loc(0, 14)),
		                                       loc(0, 12)),
		                        loc(0, 4)),
		             new Parser(new Lexer("foo = 1 + 2 - 3;")).getStatementNotNull());

		assertEquals(assignStmt(ExprVarAccess.scalar("foo", loc(0, 0)),
		                        new ExprBinary(ExprBinary.Op.Add,
		                                       new ExprBinary(ExprBinary.Op.Multiply,
		                                                      intLit(1, loc(0, 6)),
		                                                      intLit(3, loc(0, 10)),
		                                                      loc(0, 8)),
		                                       new ExprBinary(ExprBinary.Op.Multiply,
		                                                      intLit(2, loc(0, 14)),
		                                                      intLit(4, loc(0, 18)),
		                                                      loc(0, 16)),
		                                       loc(0, 12)),
		                        loc(0, 4)),
		             new Parser(new Lexer("foo = 1 * 3 + 2 * 4;")).getStatementNotNull());

		assertEquals(assignStmt(ExprVarAccess.scalar("foo", loc(0, 0)),
		                        new ExprBinary(ExprBinary.Op.Gt,
		                                       new ExprBinary(ExprBinary.Op.Add,
		                                                      intLit(1, loc(0, 6)),
		                                                      intLit(3, loc(0, 10)),
		                                                      loc(0, 8)),
		                                       new ExprBinary(ExprBinary.Op.Multiply,
		                                                      intLit(2, loc(0, 14)),
		                                                      intLit(4, loc(0, 18)),
		                                                      loc(0, 16)),
		                                       loc(0, 12)),
		                        loc(0, 4)),
		             new Parser(new Lexer("foo = 1 + 3 > 2 * 4;")).getStatementNotNull());

		assertEquals(assignStmt(ExprVarAccess.scalar("foo", loc(0, 0)),
		                        new ExprBinary(ExprBinary.Op.Multiply,
		                                       new ExprIntLiteral(2, loc(0, 6)),
		                                       new ExprBinary(ExprBinary.Op.Add,
		                                                      ExprVarAccess.scalar("bar", loc(0, 11)),
		                                                      new ExprIntLiteral(1, loc(0, 17)),
		                                                      loc(0, 15)),
		                                       loc(0, 8)),
		                        loc(0, 4)),
		             new Parser(new Lexer("foo = 2 * (bar + 1);")).getStatementNotNull());

		assertEquals(assignStmt(new ExprUnary(ExprUnary.Op.Deref,
		                                      ExprVarAccess.scalar("foo", loc(0, 1)),
		                                      loc(0, 0)),
		                        ExprVarAccess.scalar("bar", loc(0, 7)),
		                        loc(0, 5)),
		             new Parser(new Lexer("*foo = bar;")).getStatementNotNull());

		assertEquals(assignStmt(new ExprUnary(ExprUnary.Op.Deref,
		                                      new ExprBinary(ExprBinary.Op.Add,
		                                                     ExprVarAccess.scalar("foo", loc(0, 2)),
		                                                     new ExprIntLiteral(2, loc(0, 8)),
		                                                     loc(0, 6)),
		                                      loc(0, 0)),
		                        ExprVarAccess.scalar("bar", loc(0, 13)),
		                        loc(0, 11)),
		             new Parser(new Lexer("*(foo + 2) = bar;")).getStatementNotNull());

		assertEquals(assignStmt(ExprVarAccess.scalar("text", loc(0, 0)),
		                        new ExprStringLiteral("hello", -1, loc(0, 7)),
		                        loc(0, 5)),
		             new Parser(new Lexer("text = \"hello\";")).getStatementNotNull());
	}

	@Test
	public void testCompound() {
		assertEquals(new StmtCompound(List.of(
				             new StmtVarDeclaration("u16", "foo", intLit(10, loc(1, 10)),
				                                    loc(1, 0)),
				             new StmtVarDeclaration("u8", "bar", intLit(20, loc(2, 9)),
				                                    loc(2, 0))
		             )),
		             new Parser(new Lexer("""
				                                  {
				                                  u16 foo = 10;
				                                  u8 bar = 20;
				                                  }""")).getStatementNotNull());
	}

	@Test
	public void testIf() {
		assertEquals(new StmtIf(new ExprBinary(ExprBinary.Op.Lt,
		                                       intLit(1, loc(0, 4)),
		                                       intLit(2, loc(0, 8)),
		                                       loc(0, 6)),
		                        List.of(printStmt(intLit(1, loc(1, 8)),
		                                          loc(1, 2))),
		                        List.of(printStmt(intLit(2, loc(4, 8)),
		                                          loc(4, 2))),
		                        loc(0, 0)
		             ),
		             new Parser(new Lexer("""
				                                  if (1 < 2) {
				                                    print(1);
				                                  }
				                                  else {
				                                    print(2);
				                                  }""")).getStatementNotNull());

		assertEquals(new StmtCompound(List.of(
				             new StmtIf(new ExprBinary(ExprBinary.Op.Gt,
				                                       new ExprVarAccess("i", 0, null, null, null, loc(1, 6)),
				                                       intLit(0, loc(1, 10)),
				                                       loc(1, 8)),
				                        List.of(
						                        new StmtIf(new ExprBinary(ExprBinary.Op.Gt,
						                                                  new ExprVarAccess("i", 0, null, null, null, loc(2, 8)),
						                                                  intLit(9, loc(2, 12)),
						                                                  loc(2, 10)),
						                                   List.of(
								                                   new StmtExpr(new ExprFuncCall("print1", List.of(), loc(3, 6)))
						                                   ),
						                                   List.of(
								                                   new StmtExpr(new ExprFuncCall("print2", List.of(), loc(6, 6)))
						                                   ),
						                                   loc(2, 4))
				                        ), List.of(), loc(1, 2))
		             )),
		             new Parser(new Lexer("""
				                                  {
				                                    if (i > 0)
				                                      if (i > 9) {
				                                        print1();
				                                      }
				                                      else {
				                                        print2();
				                                      }
				                                  }""")).getStatementNotNull());
	}

	@Test
	public void testWhile() {
		assertEquals(new StmtCompound(List.of(
				new StmtVarDeclaration("u16", "i", intLit(5, loc(1, 8)),
				                       loc(1, 0)),
				new StmtLoop(new ExprBinary(ExprBinary.Op.Gt,
				                            ExprVarAccess.scalar("i", loc(2, 7)),
				                            intLit(0, loc(2, 11)),
				                            loc(2, 9)),
				             List.of(
						             printStmt(ExprVarAccess.scalar("i", loc(3, 8)),
						                       loc(3, 2)),
						             assignStmt(ExprVarAccess.scalar("i", loc(4, 2)),
						                        new ExprBinary(ExprBinary.Op.Sub,
						                                       ExprVarAccess.scalar("i", loc(4, 6)),
						                                       intLit(1, loc(4, 10)),
						                                       loc(4, 8)),
						                        loc(4, 4))
				             ),
				             List.of(),
				             loc(2, 0)
				)
		)), new Parser(new Lexer("""
				                         {
				                         u16 i = 5;
				                         while (i > 0) {
				                           print(i);
				                           i = i - 1;
				                         }
				                         }""")).getStatementNotNull());

		assertEquals(new StmtLoop(new ExprBoolLiteral(true, loc(0, 7)),
		                          List.of(
				                          printStmt(ExprVarAccess.scalar("i", loc(1, 8)),
				                                    loc(1, 2))
		                          ),
		                          List.of(),
		                          loc(0, 0)),
		             new Parser(new Lexer("""
				                                  while (true) {
				                                    print(i);
				                                  }""")).getStatementNotNull());
	}

	@Test
	public void testFor() {
		assertEquals(new StmtCompound(List.of(
				             new StmtVarDeclaration("i16", "i", intLit(0, loc(0, 13)),
				                                    loc(0, 5)),
				             new StmtLoop(new ExprBinary(ExprBinary.Op.Lt,
				                                         ExprVarAccess.scalar("i", loc(0, 16)),
				                                         intLit(10, loc(0, 20)),
				                                         loc(0, 18)),
				                          List.of(
						                          printStmt(ExprVarAccess.scalar("i", loc(1, 8)),
						                                    loc(1, 2))
				                          ),
				                          List.of(
						                          assignStmt(ExprVarAccess.scalar("i", loc(0, 24)),
						                                     new ExprBinary(ExprBinary.Op.Add,
						                                                    ExprVarAccess.scalar("i", loc(0, 28)),
						                                                    intLit(1, loc(0, 32)),
						                                                    loc(0, 30)),
						                                     loc(0, 26))
				                          ),
				                          loc(0, 0))
		             )),
		             new Parser(new Lexer("""
				                                  for (i16 i = 0; i < 10; i = i + 1) {
				                                    print(i);
				                                  }""")).getStatementNotNull());

		assertEquals(new StmtCompound(List.of(
				             new StmtVarDeclaration("u8", "i", intLit(1, loc(1, 7)),
				                                    loc(1, 0)),
				             new StmtLoop(new ExprBinary(ExprBinary.Op.Lt, ExprVarAccess.scalar("i", loc(2, 7)), intLit(10, loc(2, 11)), loc(2, 9)),
				                          List.of(
						                          printStmt(ExprVarAccess.scalar("i", loc(3, 8)),
						                                    loc(3, 2))
				                          ),
				                          List.of(
						                          assignStmt(ExprVarAccess.scalar("i", loc(2, 15)),
						                                     new ExprBinary(ExprBinary.Op.Add,
						                                                    ExprVarAccess.scalar("i", loc(2, 19)),
						                                                    intLit(1, loc(2, 23)),
						                                                    loc(2, 21)),
						                                     loc(2, 17))
				                          ),
				                          loc(2, 0)
				             )
		             )),
		             new Parser(new Lexer("""
				                                  {
				                                  u8 i = 1;
				                                  for (; i < 10; i = i + 1) {
				                                    print(i);
				                                  }
				                                  }""")).getStatementNotNull());

		assertEquals(new StmtCompound(List.of(
				             new StmtVarDeclaration("u8", "i", intLit(5, loc(1, 7)),
				                                    loc(1, 0)),
				             new StmtLoop(new ExprBinary(ExprBinary.Op.Gt,
				                                         ExprVarAccess.scalar("i", loc(2, 6)),
				                                         intLit(0, loc(2, 10)),
				                                         loc(2, 8)),
				                          List.of(
						                          printStmt(ExprVarAccess.scalar("i", loc(3, 8)),
						                                    loc(3, 2)),
						                          assignStmt(ExprVarAccess.scalar("i", loc(4, 2)),
						                                     new ExprBinary(ExprBinary.Op.Sub,
						                                                    ExprVarAccess.scalar("i", loc(4, 6)),
						                                                    intLit(1, loc(4, 10)),
						                                                    loc(4, 8)),
						                                     loc(4, 4))
				                          ),
				                          List.of(),
				                          loc(2, 0))
		             )),
		             new Parser(new Lexer("""
				                                  {
				                                  u8 i = 5;
				                                  for (;i > 0;) {
				                                    print(i);
				                                    i = i - 1;
				                                  }
				                                  }""")).getStatementNotNull());

		assertEquals(new StmtCompound(List.of(
				             new StmtVarDeclaration("u8", "i", intLit(5, loc(1, 7)),
				                                    loc(1, 0)),
				             new StmtLoop(new ExprIntLiteral(1, loc(2, 0)),
				                          List.of(
						                          printStmt(ExprVarAccess.scalar("i", loc(3, 8)),
						                                    loc(3, 2)),
						                          assignStmt(ExprVarAccess.scalar("i", loc(4, 2)),
						                                     new ExprBinary(ExprBinary.Op.Sub,
						                                                    ExprVarAccess.scalar("i", loc(4, 6)),
						                                                    intLit(1, loc(4, 10)),
						                                                    loc(4, 8)),
						                                     loc(4, 4))
				                          ),
				                          List.of(),
				                          loc(2, 0))
		             )),
		             new Parser(new Lexer("""
				                                  {
				                                  u8 i = 5;
				                                  for (;;) {
				                                    print(i);
				                                    i = i - 1;
				                                  }
				                                  }""")).getStatementNotNull());
	}

	@Test
	public void testFunctions() {
		Assert.assertEquals(new Program(List.of(),
		                                List.of(
				                                new Function("main", "void", List.of(),
				                                             List.of(
						                                             new StmtVarDeclaration("u8", "i", intLit(10, loc(1, 11)),
						                                                                    loc(1, 4)),
						                                             printStmt(ExprVarAccess.scalar("i", loc(2, 10)),
						                                                       loc(2, 4))
				                                             ),
				                                             loc(0, 0)),
				                                new Function("fooBar", "void", List.of(new Function.Arg("u8", "a", loc(4, 12))),
				                                             List.of(),
				                                             loc(4, 0))
		                                ),
		                                List.of(),
		                                List.of()
		                    ),
		                    new Parser(new Lexer("""
				                                         void main() {
				                                             u8 i = 10;
				                                             print(i);
				                                         }
				                                         void fooBar(u8 a) {
				                                         }""")).parse());

		assertEquals(new Program(List.of(),
		                         List.of(
				                         new Function("main", "void", List.of(),
				                                      List.of(
						                                      new StmtVarDeclaration("u8", "i",
						                                                             new ExprFuncCall("one", List.of(), loc(1, 11)),
						                                                             loc(1, 4)),
						                                      new StmtIf(new ExprBinary(ExprBinary.Op.Equals,
						                                                                ExprVarAccess.scalar("i", loc(2, 8)),
						                                                                new ExprIntLiteral(0, loc(2, 13)),
						                                                                loc(2, 10)),
						                                                 List.of(
								                                                 new StmtReturn(null, loc(3, 8))
						                                                 ),
						                                                 List.of(),
						                                                 loc(2, 4)),
						                                      printStmt(ExprVarAccess.scalar("i", loc(4, 10)),
						                                                loc(4, 4))
				                                      ),
				                                      loc(0, 0)),
				                         new Function("one", "u8", List.of(),
				                                      List.of(
						                                      new StmtReturn(new ExprIntLiteral(1, loc(7, 10)),
						                                                     loc(7, 3))
				                                      ),
				                                      loc(4, 0))
		                         ),
		                         List.of(),
		                         List.of()
		             ),
		             new Parser(new Lexer("""
				                                  void main() {
				                                      u8 i = one();
				                                      if (i == 0)
				                                          return;
				                                      print(i);
				                                  }
				                                  u8 one() {
				                                     return 1;
				                                  }""")).parse());
	}

	@Test
	public void testArrays() {
		assertEquals(new Program(List.of(
				             new StmtArrayDeclaration("u8", "str", 4,
				                                      loc(0, 0))
		             ), List.of(), List.of(), List.of()),
		             new Parser(new Lexer("u8 str[4];")).parse());

		assertEquals(new StmtArrayDeclaration("u8", "buffer", 256,
		                                      loc(0, 0)),
		             new Parser(new Lexer("u8 buffer[256];")).getStatementNotNull());

		assertEquals(assignStmt(ExprVarAccess.array("buffer",
		                                            ExprVarAccess.scalar("i", loc(0, 7)),
		                                            loc(0, 0)),
		                        ExprVarAccess.array("buffer",
		                                            new ExprBinary(ExprBinary.Op.Add,
		                                                           ExprVarAccess.scalar("i", loc(0, 19)),
		                                                           new ExprIntLiteral(1, loc(0, 23)),
		                                                           loc(0, 21)),
		                                            loc(0, 12)),
		                        loc(0, 10)),
		             new Parser(new Lexer("buffer[i] = buffer[i + 1];")).getStatementNotNull());
	}

	@Test
	public void testUnaryOperators() {
		assertEquals(assignStmt(ExprVarAccess.scalar("a", loc(0, 0)),
		                        new ExprUnary(ExprUnary.Op.Neg,
		                                      ExprVarAccess.scalar("a", loc(0, 5)),
		                                      loc(0, 4)),
		                        loc(0, 2)),
		             new Parser(new Lexer("a = -a;")).getStatementNotNull());

		assertEquals(assignStmt(ExprVarAccess.scalar("a", loc(0, 0)),
		                        new ExprUnary(ExprUnary.Op.Com,
		                                      ExprVarAccess.scalar("a", loc(0, 5)),
		                                      loc(0, 4)),
		                        loc(0, 2)),
		             new Parser(new Lexer("a = ~a;")).getStatementNotNull());

		assertEquals(assignStmt(ExprVarAccess.scalar("a", loc(0, 0)),
		                        new ExprUnary(ExprUnary.Op.NotLog,
		                                      ExprVarAccess.scalar("a", loc(0, 5)),
		                                      loc(0, 4)),
		                        loc(0, 2)),
		             new Parser(new Lexer("a = !a;")).getStatementNotNull());
	}

	@Test
	public void testCast() {
		assertEquals(assignStmt(ExprVarAccess.scalar("b", loc(0, 0)),
		                        ExprCast.cast("u8", ExprVarAccess.scalar("a", loc(0, 8)),
		                                      loc(0, 5)),
		                        loc(0, 2)),
		             new Parser(new Lexer("b = (u8)a;")).getStatementNotNull());
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
		assertEquals(expectedFunction.statements(), currentFunction.statements());
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
		else if (expectedNode instanceof ExprAddrOf exprAddrOf
		         && currentNode instanceof ExprAddrOf currAddrOf) {
			assertEquals(exprAddrOf.arrayIndex(), currAddrOf.arrayIndex());
		}
		else if (expectedNode instanceof ExprUnary expDeref
		         && currentNode instanceof ExprUnary currDeref) {
			assertEquals(expDeref.expression(), currDeref.expression());
		}
		else if (expectedNode instanceof ExprVarAccess exprArray
		         && currentNode instanceof ExprVarAccess currArray) {
			assertEquals(exprArray.arrayIndex(), currArray.arrayIndex());
		}
		Assert.assertEquals(expectedNode.getClass(), currentNode.getClass());
		Assert.assertEquals(expectedNode.location(), currentNode.location());
		Assert.assertEquals(expectedNode, currentNode);
	}
}