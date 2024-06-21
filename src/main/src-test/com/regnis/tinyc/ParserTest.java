package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;

import org.junit.*;

/**
 * @author Thomas Singer
 */
public class ParserTest {

	@Test
	public void testAssignment() {
		assertEquals(AstNode.assign("foo", AstNode.intLiteral(1, new Location(0, 10)),
		                            new Location(0, 0)),
		             new Parser(new Lexer("var foo = 1;")).parse());

		assertEquals(AstNode.assign("foo", AstNode.add(AstNode.intLiteral(1, new Location(1, 12)),
		                                               AstNode.intLiteral(2, new Location(1, 16)),
		                                               new Location(1, 14)),
		                            new Location(1, 2)),
		             new Parser(new Lexer("\n  var foo = 1 + 2;")).parse());

		assertEquals(AstNode.assign("foo", AstNode.add(AstNode.add(AstNode.intLiteral(1, new Location(0, 10)),
		                                                           AstNode.intLiteral(2, new Location(0, 14)),
		                                                           new Location(0, 12)),
		                                               AstNode.intLiteral(3, new Location(0, 18)),
		                                               new Location(0, 16)),
		                            new Location(0, 0)),
		             new Parser(new Lexer("var foo = 1 + 2 + 3;")).parse());

		assertEquals(AstNode.assign("foo", AstNode.add(AstNode.sub(AstNode.intLiteral(1, new Location(0, 10)),
		                                                           AstNode.intLiteral(2, new Location(0, 14)),
		                                                           new Location(0, 12)),
		                                               AstNode.intLiteral(3, new Location(0, 18)),
		                                               new Location(0, 16)),
		                            new Location(0, 0)),
		             new Parser(new Lexer("var foo = 1 - 2 + 3;")).parse());

		assertEquals(AstNode.assign("foo", AstNode.sub(AstNode.add(AstNode.intLiteral(1, new Location(0, 10)),
		                                                           AstNode.intLiteral(2, new Location(0, 14)),
		                                                           new Location(0, 12)),
		                                               AstNode.intLiteral(3, new Location(0, 18)),
		                                               new Location(0, 16)),
		                            new Location(0, 0)),
		             new Parser(new Lexer("var foo = 1 + 2 - 3;")).parse());

		assertEquals(
				AstNode.assign("foo", AstNode.add(AstNode.multiply(AstNode.intLiteral(1, new Location(0, 10)),
				                                                   AstNode.intLiteral(3, new Location(0, 14)),
				                                                   new Location(0, 12)),
				                                  AstNode.multiply(AstNode.intLiteral(2, new Location(0, 18)),
				                                                   AstNode.intLiteral(4, new Location(0, 22)),
				                                                   new Location(0, 20)),
				                                  new Location(0, 16)),
				               new Location(0, 0)),
				new Parser(new Lexer("var foo = 1 * 3 + 2 * 4;")).parse());

		assertEquals(AstNode.assign("foo", AstNode.gt(AstNode.add(AstNode.intLiteral(1, new Location(0, 10)),
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
	public void testChain() {
		assertEquals(AstNode.chain(AstNode.assign("foo", AstNode.intLiteral(10, new Location(0, 10)),
		                                          new Location(0, 0)),
		                           AstNode.assign("bar", AstNode.intLiteral(20, new Location(1, 10)),
		                                          new Location(1, 0))),
		             new Parser(new Lexer("""
				                                  var foo = 10;
				                                  var bar = 20;""")).parse());
	}

	@Test
	public void testIf() {
		assertEquals(AstNode.ifElse(AstNode.lt(AstNode.intLiteral(1, new Location(0, 4)),
		                                       AstNode.intLiteral(2, new Location(0, 8)),
		                                       new Location(0, 6)),
		                            AstNode.chain(
				                            AstNode.print(AstNode.intLiteral(1, new Location(1, 8)), new Location(1, 2)),
				                            AstNode.print(AstNode.intLiteral(2, new Location(4, 8)), new Location(4, 2))
		                            ),
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
		assertEquals(AstNode.chain(AstNode.assign("i", AstNode.intLiteral(5, new Location(0, 8)),
		                                          new Location(0, 0)),
		                           AstNode.whileStatement(
				                           AstNode.gt(AstNode.varRead("i", new Location(1, 7)),
				                                      AstNode.intLiteral(0, new Location(1, 11)),
				                                      new Location(1, 9)),
				                           AstNode.chain(
						                           AstNode.print(AstNode.varRead("i", new Location(2, 8)), new Location(2, 2)),
						                           AstNode.assign("i", AstNode.sub(AstNode.varRead("i", new Location(3, 6)),
						                                                           AstNode.intLiteral(1, new Location(3, 10)),
						                                                           new Location(3, 8)),
						                                          new Location(3, 2))
				                           ),
				                           new Location(1, 0)
		                           )
		             ),
		             new Parser(new Lexer("""
				                                  var i = 5;
				                                  while (i > 0) {
				                                    print i;
				                                    i = i - 1;
				                                  }""")).parse());
	}

	private static void assertEquals(AstNode expectedNode, AstNode currentNode) {
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