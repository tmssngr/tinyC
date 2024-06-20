package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;

import org.junit.*;

/**
 * @author Thomas Singer
 */
public class ParserTest {

	@Test
	public void testAssignment() {
		assertEquals(AstNode.assign(AstNode.intLiteral(1, new Location(0, 10)),
		                            AstNode.lhs("foo", new Location(0, 0)),
		                            new Location(0, 0)),
		             new Parser(new Lexer("var foo = 1;")).parse());

		assertEquals(AstNode.assign(AstNode.add(AstNode.intLiteral(1, new Location(1, 12)),
		                                        AstNode.intLiteral(2, new Location(1, 16)),
		                                        new Location(1, 14)),
		                            AstNode.lhs("foo", new Location(1, 2)),
		                            new Location(1, 2)),
		             new Parser(new Lexer("\n  var foo = 1 + 2;")).parse());

		assertEquals(AstNode.assign(AstNode.add(AstNode.add(AstNode.intLiteral(1, new Location(0, 10)),
		                                                    AstNode.intLiteral(2, new Location(0, 14)),
		                                                    new Location(0, 12)),
		                                        AstNode.intLiteral(3, new Location(0, 18)),
		                                        new Location(0, 16)),
		                            AstNode.lhs("foo", new Location(0, 0)),
		                            new Location(0, 0)),
		             new Parser(new Lexer("var foo = 1 + 2 + 3;")).parse());

		assertEquals(AstNode.assign(AstNode.add(AstNode.sub(AstNode.intLiteral(1, new Location(0, 10)),
		                                                    AstNode.intLiteral(2, new Location(0, 14)),
		                                                    new Location(0, 12)),
		                                        AstNode.intLiteral(3, new Location(0, 18)),
		                                        new Location(0, 16)),
		                            AstNode.lhs("foo", new Location(0, 0)),
		                            new Location(0, 0)),
		             new Parser(new Lexer("var foo = 1 - 2 + 3;")).parse());

		assertEquals(AstNode.assign(AstNode.sub(AstNode.add(AstNode.intLiteral(1, new Location(0, 10)),
		                                                    AstNode.intLiteral(2, new Location(0, 14)),
		                                                    new Location(0, 12)),
		                                        AstNode.intLiteral(3, new Location(0, 18)),
		                                        new Location(0, 16)),
		                            AstNode.lhs("foo", new Location(0, 0)),
		                            new Location(0, 0)),
		             new Parser(new Lexer("var foo = 1 + 2 - 3;")).parse());

		assertEquals(
				AstNode.assign(AstNode.add(AstNode.multiply(AstNode.intLiteral(1, new Location(0, 10)),
				                                            AstNode.intLiteral(3, new Location(0, 14)),
				                                            new Location(0, 12)),
				                           AstNode.multiply(AstNode.intLiteral(2, new Location(0, 18)),
				                                            AstNode.intLiteral(4, new Location(0, 22)),
				                                            new Location(0, 20)),
				                           new Location(0, 16)),
				               AstNode.lhs("foo", new Location(0, 0)),
				               new Location(0, 0)),
				new Parser(new Lexer("var foo = 1 * 3 + 2 * 4;")).parse());

		assertEquals(AstNode.assign(AstNode.gt(AstNode.add(AstNode.intLiteral(1, new Location(0, 10)),
		                                                   AstNode.intLiteral(3, new Location(0, 14)),
		                                                   new Location(0, 12)),
		                                       AstNode.multiply(AstNode.intLiteral(2, new Location(0, 18)),
		                                                        AstNode.intLiteral(4, new Location(0, 22)),
		                                                        new Location(0, 20)),
		                                       new Location(0, 16)),
		                            AstNode.lhs("foo", new Location(0, 0)),
		                            new Location(0, 0)),
		             new Parser(new Lexer("var foo = 1 + 3 > 2 * 4;")).parse());
	}

	@Test
	public void testChain() {
		assertEquals(AstNode.chain(AstNode.assign(AstNode.intLiteral(10, new Location(0, 10)),
		                                          AstNode.lhs("foo", new Location(0, 0)),
		                                          new Location(0, 0)),
		                           AstNode.assign(AstNode.intLiteral(20, new Location(1, 10)),
		                                          AstNode.lhs("bar", new Location(1, 0)),
		                                          new Location(1, 0))),
		             new Parser(new Lexer("""
				                                  var foo = 10;
				                                  var bar = 20;""")).parse());
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