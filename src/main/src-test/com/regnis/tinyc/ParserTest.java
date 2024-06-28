package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;
import org.junit.*;

/**
 * @author Thomas Singer
 */
public class ParserTest {

	@Test
	public void testAssignment() {
		assertEquals(new SimpleStatement.Assign("foo", Expression.intLiteral(1, new Location(0, 10)),
		                                        new Location(0, 0)),
		             new Parser(new Lexer("var foo = 1;")).getStatementNotNull());

		assertEquals(new SimpleStatement.Assign("foo", Expression.add(Expression.intLiteral(1, new Location(1, 12)),
		                                                              Expression.intLiteral(2, new Location(1, 16)),
		                                                              new Location(1, 14)),
		                                        new Location(1, 2)),
		             new Parser(new Lexer("\n  var foo = 1 + 2;")).getStatementNotNull());

		assertEquals(new SimpleStatement.Assign("foo", Expression.add(Expression.add(Expression.intLiteral(1, new Location(0, 10)),
		                                                                             Expression.intLiteral(2, new Location(0, 14)),
		                                                                             new Location(0, 12)),
		                                                              Expression.intLiteral(3, new Location(0, 18)),
		                                                              new Location(0, 16)),
		                                        new Location(0, 0)),
		             new Parser(new Lexer("var foo = 1 + 2 + 3;")).getStatementNotNull());

		assertEquals(new SimpleStatement.Assign("foo", Expression.add(Expression.sub(Expression.intLiteral(1, new Location(0, 10)),
		                                                                             Expression.intLiteral(2, new Location(0, 14)),
		                                                                             new Location(0, 12)),
		                                                              Expression.intLiteral(3, new Location(0, 18)),
		                                                              new Location(0, 16)),
		                                        new Location(0, 0)),
		             new Parser(new Lexer("var foo = 1 - 2 + 3;")).getStatementNotNull());

		assertEquals(new SimpleStatement.Assign("foo", Expression.sub(Expression.add(Expression.intLiteral(1, new Location(0, 10)),
		                                                                             Expression.intLiteral(2, new Location(0, 14)),
		                                                                             new Location(0, 12)),
		                                                              Expression.intLiteral(3, new Location(0, 18)),
		                                                              new Location(0, 16)),
		                                        new Location(0, 0)),
		             new Parser(new Lexer("var foo = 1 + 2 - 3;")).getStatementNotNull());

		assertEquals(
				new SimpleStatement.Assign("foo", Expression.add(Expression.multiply(Expression.intLiteral(1, new Location(0, 10)),
				                                                                     Expression.intLiteral(3, new Location(0, 14)),
				                                                                     new Location(0, 12)),
				                                                 Expression.multiply(Expression.intLiteral(2, new Location(0, 18)),
				                                                                     Expression.intLiteral(4, new Location(0, 22)),
				                                                                     new Location(0, 20)),
				                                                 new Location(0, 16)),
				                           new Location(0, 0)),
				new Parser(new Lexer("var foo = 1 * 3 + 2 * 4;")).getStatementNotNull());

		assertEquals(new SimpleStatement.Assign("foo", Expression.gt(Expression.add(Expression.intLiteral(1, new Location(0, 10)),
		                                                                            Expression.intLiteral(3, new Location(0, 14)),
		                                                                            new Location(0, 12)),
		                                                             Expression.multiply(Expression.intLiteral(2, new Location(0, 18)),
		                                                                                 Expression.intLiteral(4, new Location(0, 22)),
		                                                                                 new Location(0, 20)),
		                                                             new Location(0, 16)),
		                                        new Location(0, 0)),
		             new Parser(new Lexer("var foo = 1 + 3 > 2 * 4;")).getStatementNotNull());
	}

	@Test
	public void testCompound() {
		assertEquals(new Statement.Compound(List.of(
				             new SimpleStatement.Assign("foo", Expression.intLiteral(10, new Location(1, 10)),
				                                        new Location(1, 0)),
				             new SimpleStatement.Assign("bar", Expression.intLiteral(20, new Location(2, 10)),
				                                        new Location(2, 0))
		             )),
		             new Parser(new Lexer("""
				                                  {
				                                  var foo = 10;
				                                  var bar = 20;
				                                  }""")).getStatementNotNull());
	}

	@Test
	public void testIf() {
		assertEquals(new Statement.If(Expression.lt(Expression.intLiteral(1, new Location(0, 4)),
		                                            Expression.intLiteral(2, new Location(0, 8)),
		                                            new Location(0, 6)),
		                              new Statement.Compound(List.of(new Statement.Print(Expression.intLiteral(1, new Location(1, 8)), new Location(1, 2)))),
		                              new Statement.Compound(List.of(new Statement.Print(Expression.intLiteral(2, new Location(4, 8)), new Location(4, 2)))),
		                              new Location(0, 0)
		             ),
		             new Parser(new Lexer("""
				                                  if (1 < 2) {
				                                    print 1;
				                                  }
				                                  else {
				                                    print 2;
				                                  }""")).getStatementNotNull());
	}

	@Test
	public void testWhile() {
		assertEquals(new Statement.Compound(List.of(
				new SimpleStatement.Assign("i", Expression.intLiteral(5, new Location(1, 8)),
				                           new Location(1, 0)),
				new Statement.While(Expression.gt(Expression.varRead("i", new Location(2, 7)),
				                                  Expression.intLiteral(0, new Location(2, 11)),
				                                  new Location(2, 9)),
				                    new Statement.Compound(List.of(
						                    new Statement.Print(Expression.varRead("i", new Location(3, 8)), new Location(3, 2)),
						                    new SimpleStatement.Assign("i", Expression.sub(Expression.varRead("i", new Location(4, 6)),
						                                                                   Expression.intLiteral(1, new Location(4, 10)),
						                                                                   new Location(4, 8)),
						                                               new Location(4, 2))
				                    )),
				                    new Location(2, 0)
				)
		)), new Parser(new Lexer("""
				                         {
				                         var i = 5;
				                         while (i > 0) {
				                           print i;
				                           i = i - 1;
				                         }
				                         }""")).getStatementNotNull());
	}

	@Test
	public void testFor() {
		assertEquals(new Statement.For(List.of(
				             new SimpleStatement.Assign("i", Expression.intLiteral(0, new Location(0, 13)),
				                                        new Location(0, 5))
		             ),
		                               Expression.lt(Expression.varRead("i", new Location(0, 16)),
		                                             Expression.intLiteral(10, new Location(0, 20)),
		                                             new Location(0, 18)),
		                               new Statement.Compound(List.of(
				                               new Statement.Print(Expression.varRead("i", new Location(1, 8)), new Location(1, 2))
		                               )),
		                               List.of(
				                               new SimpleStatement.Assign("i", Expression.add(Expression.varRead("i", new Location(0, 28)),
				                                                                              Expression.intLiteral(1, new Location(0, 32)),
				                                                                              new Location(0, 30)),
				                                                          new Location(0, 24))
		                               ),
		                               new Location(0, 0)),
		             new Parser(new Lexer("""
				                                  for (var i = 0; i < 10; i = i + 1) {
				                                    print i;
				                                  }""")).getStatementNotNull());

		assertEquals(new Statement.Compound(List.of(
				             new SimpleStatement.Assign("i", Expression.intLiteral(1, new Location(1, 8)),
				                                        new Location(1, 0)),
				             new Statement.For(List.of(),
				                               Expression.lt(Expression.varRead("i", new Location(2, 7)),
				                                             Expression.intLiteral(10, new Location(2, 11)),
				                                             new Location(2, 9)),
				                               new Statement.Compound(List.of(
						                               new Statement.Print(Expression.varRead("i", new Location(3, 8)), new Location(3, 2))
				                               )),
				                               List.of(
						                               new SimpleStatement.Assign("i", Expression.add(Expression.varRead("i", new Location(2, 19)),
						                                                                              Expression.intLiteral(1, new Location(2, 23)),
						                                                                              new Location(2, 21)),
						                                                          new Location(2, 15))
				                               ),
				                               new Location(2, 0)
				             )
		             )),
		             new Parser(new Lexer("""
				                                  {
				                                  var i = 1;
				                                  for (; i < 10; i = i + 1) {
				                                    print i;
				                                  }
				                                  }""")).getStatementNotNull());

		assertEquals(new Statement.Compound(List.of(
				             new SimpleStatement.Assign("i", Expression.intLiteral(5, new Location(1, 8)),
				                                        new Location(1, 0)),
				             new Statement.For(List.of(),
				                               Expression.gt(Expression.varRead("i", new Location(2, 6)),
				                                             Expression.intLiteral(0, new Location(2, 10)),
				                                             new Location(2, 8)),
				                               new Statement.Compound(List.of(
						                               new Statement.Print(Expression.varRead("i", new Location(3, 8)), new Location(3, 2)),
						                               new SimpleStatement.Assign("i", Expression.sub(Expression.varRead("i", new Location(4, 6)),
						                                                                              Expression.intLiteral(1, new Location(4, 10)),
						                                                                              new Location(4, 8)),
						                                                          new Location(4, 2))
				                               )),
				                               List.of(),
				                               new Location(2, 0))
		             )),
		             new Parser(new Lexer("""
				                                  {
				                                  var i = 5;
				                                  for (;i > 0;) {
				                                    print i;
				                                    i = i - 1;
				                                  }
				                                  }""")).getStatementNotNull());
	}

	@Test
	public void testFunctions() {
		Assert.assertEquals(new Program(List.of(
				new Function("main", "void",
				             new Statement.Compound(List.of(
						             new SimpleStatement.Assign("i", Expression.intLiteral(10, new Location(1, 12)),
						                                        new Location(1, 4)),
						             new Statement.Print(Expression.varRead("i", new Location(2, 10)),
						                                 new Location(2, 4))
				             )),
				             new Location(0, 0)),
				new Function("fooBar", "void",
				             new Statement.Compound(List.of()),
				             new Location(4, 0))
		)), new Parser(new Lexer("""
				                         void main() {
				                             var i = 10;
				                             print i;
				                         }
				                         void fooBar() {
				                         }""")).parse());
	}

	private static void assertEquals(@Nullable Statement expectedStatement, @Nullable Statement currentStatement) {
		if (expectedStatement == null) {
			Assert.assertNull(currentStatement);
			return;
		}

		Assert.assertNotNull(currentStatement);
		Assert.assertEquals(expectedStatement, currentStatement);
	}

	private static void assertEquals(@Nullable Expression expectedNode, @Nullable Expression currentNode) {
		if (expectedNode == null) {
			Assert.assertNull(currentNode);
			return;
		}

		Assert.assertNotNull(currentNode);
		assertEquals(expectedNode.left(), currentNode.left());
		assertEquals(expectedNode.right(), currentNode.right());

		Assert.assertEquals(expectedNode.type(), currentNode.type());
		Assert.assertEquals(expectedNode.text(), currentNode.text());
		Assert.assertEquals(expectedNode.value(), currentNode.value());
		Assert.assertEquals(expectedNode.location(), currentNode.location());
	}
}