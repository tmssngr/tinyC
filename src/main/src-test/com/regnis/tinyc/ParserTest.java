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
		assertEquals(new SimpleStatement.Assign("foo", AstNode.intLiteral(1, new Location(0, 10)),
		                                        new Location(0, 0)),
		             new Parser(new Lexer("var foo = 1;")).parse());

		assertEquals(new SimpleStatement.Assign("foo", AstNode.add(AstNode.intLiteral(1, new Location(1, 12)),
		                                                           AstNode.intLiteral(2, new Location(1, 16)),
		                                                           new Location(1, 14)),
		                                        new Location(1, 2)),
		             new Parser(new Lexer("\n  var foo = 1 + 2;")).parse());

		assertEquals(new SimpleStatement.Assign("foo", AstNode.add(AstNode.add(AstNode.intLiteral(1, new Location(0, 10)),
		                                                                       AstNode.intLiteral(2, new Location(0, 14)),
		                                                                       new Location(0, 12)),
		                                                           AstNode.intLiteral(3, new Location(0, 18)),
		                                                           new Location(0, 16)),
		                                        new Location(0, 0)),
		             new Parser(new Lexer("var foo = 1 + 2 + 3;")).parse());

		assertEquals(new SimpleStatement.Assign("foo", AstNode.add(AstNode.sub(AstNode.intLiteral(1, new Location(0, 10)),
		                                                                       AstNode.intLiteral(2, new Location(0, 14)),
		                                                                       new Location(0, 12)),
		                                                           AstNode.intLiteral(3, new Location(0, 18)),
		                                                           new Location(0, 16)),
		                                        new Location(0, 0)),
		             new Parser(new Lexer("var foo = 1 - 2 + 3;")).parse());

		assertEquals(new SimpleStatement.Assign("foo", AstNode.sub(AstNode.add(AstNode.intLiteral(1, new Location(0, 10)),
		                                                                       AstNode.intLiteral(2, new Location(0, 14)),
		                                                                       new Location(0, 12)),
		                                                           AstNode.intLiteral(3, new Location(0, 18)),
		                                                           new Location(0, 16)),
		                                        new Location(0, 0)),
		             new Parser(new Lexer("var foo = 1 + 2 - 3;")).parse());

		assertEquals(
				new SimpleStatement.Assign("foo", AstNode.add(AstNode.multiply(AstNode.intLiteral(1, new Location(0, 10)),
				                                                               AstNode.intLiteral(3, new Location(0, 14)),
				                                                               new Location(0, 12)),
				                                              AstNode.multiply(AstNode.intLiteral(2, new Location(0, 18)),
				                                                               AstNode.intLiteral(4, new Location(0, 22)),
				                                                               new Location(0, 20)),
				                                              new Location(0, 16)),
				                           new Location(0, 0)),
				new Parser(new Lexer("var foo = 1 * 3 + 2 * 4;")).parse());

		assertEquals(new SimpleStatement.Assign("foo", AstNode.gt(AstNode.add(AstNode.intLiteral(1, new Location(0, 10)),
		                                                                      AstNode.intLiteral(3, new Location(0, 14)),
		                                                                      new Location(0, 12)),
		                                                          AstNode.multiply(AstNode.intLiteral(2, new Location(0, 18)),
		                                                                           AstNode.intLiteral(4, new Location(0, 22)),
		                                                                           new Location(0, 20)),
		                                                          new Location(0, 16)),
		                                        new Location(0, 0)),
		             new Parser(new Lexer("var foo = 1 + 3 > 2 * 4;")).parse());
	}

	@Test
	public void testCompound() {
		assertEquals(new Statement.Compound(List.of(
				             new SimpleStatement.Assign("foo", AstNode.intLiteral(10, new Location(1, 10)),
				                                        new Location(1, 0)),
				             new SimpleStatement.Assign("bar", AstNode.intLiteral(20, new Location(2, 10)),
				                                        new Location(2, 0))
		             )),
		             new Parser(new Lexer("""
				                                  {
				                                  var foo = 10;
				                                  var bar = 20;
				                                  }""")).parse());
	}

	@Test
	public void testIf() {
		assertEquals(new Statement.If(AstNode.lt(AstNode.intLiteral(1, new Location(0, 4)),
		                                         AstNode.intLiteral(2, new Location(0, 8)),
		                                         new Location(0, 6)),
		                              new Statement.Compound(List.of(new Statement.Print(AstNode.intLiteral(1, new Location(1, 8)), new Location(1, 2)))),
		                              new Statement.Compound(List.of(new Statement.Print(AstNode.intLiteral(2, new Location(4, 8)), new Location(4, 2)))),
		                              new Location(0, 0)
		             ),
		             new Parser(new Lexer("""
				                                  if (1 < 2) {
				                                    print 1;
				                                  }
				                                  else {
				                                    print 2;
				                                  }""")).parse());
	}

	@Test
	public void testWhile() {
		assertEquals(new Statement.Compound(List.of(
				new SimpleStatement.Assign("i", AstNode.intLiteral(5, new Location(1, 8)),
				                           new Location(1, 0)),
				new Statement.While(AstNode.gt(AstNode.varRead("i", new Location(2, 7)),
				                               AstNode.intLiteral(0, new Location(2, 11)),
				                               new Location(2, 9)),
				                    new Statement.Compound(List.of(
						                    new Statement.Print(AstNode.varRead("i", new Location(3, 8)), new Location(3, 2)),
						                    new SimpleStatement.Assign("i", AstNode.sub(AstNode.varRead("i", new Location(4, 6)),
						                                                                AstNode.intLiteral(1, new Location(4, 10)),
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
				                         }""")).parse());
	}

	@Test
	public void testFor() {
		assertEquals(new Statement.For(List.of(
				             new SimpleStatement.Assign("i", AstNode.intLiteral(0, new Location(0, 13)),
				                                        new Location(0, 5))
		             ),
		                               AstNode.lt(AstNode.varRead("i", new Location(0, 16)),
		                                          AstNode.intLiteral(10, new Location(0, 20)),
		                                          new Location(0, 18)),
		                               new Statement.Compound(List.of(
				                               new Statement.Print(AstNode.varRead("i", new Location(1, 8)), new Location(1, 2))
		                               )),
		                               List.of(
				                               new SimpleStatement.Assign("i", AstNode.add(AstNode.varRead("i", new Location(0, 28)),
				                                                                           AstNode.intLiteral(1, new Location(0, 32)),
				                                                                           new Location(0, 30)),
				                                                          new Location(0, 24))
		                               ),
		                               new Location(0, 0)),
		             new Parser(new Lexer("""
				                                  for (var i = 0; i < 10; i = i + 1) {
				                                    print i;
				                                  }""")).parse());

		assertEquals(new Statement.Compound(List.of(
				             new SimpleStatement.Assign("i", AstNode.intLiteral(1, new Location(1, 8)),
				                                        new Location(1, 0)),
				             new Statement.For(List.of(),
				                               AstNode.lt(AstNode.varRead("i", new Location(2, 7)),
				                                          AstNode.intLiteral(10, new Location(2, 11)),
				                                          new Location(2, 9)),
				                               new Statement.Compound(List.of(
						                               new Statement.Print(AstNode.varRead("i", new Location(3, 8)), new Location(3, 2))
				                               )),
				                               List.of(
						                               new SimpleStatement.Assign("i", AstNode.add(AstNode.varRead("i", new Location(2, 19)),
						                                                                           AstNode.intLiteral(1, new Location(2, 23)),
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
				                                  }""")).parse());

		assertEquals(new Statement.Compound(List.of(
				             new SimpleStatement.Assign("i", AstNode.intLiteral(5, new Location(1, 8)),
				                                        new Location(1, 0)),
				             new Statement.For(List.of(),
				                               AstNode.gt(AstNode.varRead("i", new Location(2, 6)),
				                                          AstNode.intLiteral(0, new Location(2, 10)),
				                                          new Location(2, 8)),
				                               new Statement.Compound(List.of(
						                               new Statement.Print(AstNode.varRead("i", new Location(3, 8)), new Location(3, 2)),
						                               new SimpleStatement.Assign("i", AstNode.sub(AstNode.varRead("i", new Location(4, 6)),
						                                                                           AstNode.intLiteral(1, new Location(4, 10)),
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

	private static void assertEquals(@Nullable AstNode expectedNode, @Nullable AstNode currentNode) {
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