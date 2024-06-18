package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;

import java.util.*;

import org.junit.*;

/**
 * @author Thomas Singer
 */
public class ParserTest {

	@Test
	public void testAssignment() {
		assertEquals(List.of(
				AstNode.assign(AstNode.intLiteral(1, new Location(0, 10)),
				               AstNode.lhs("foo", new Location(0, 0)),
				               new Location(0, 0))
		), new Parser(new Lexer("var foo = 1;")).parse());
		//                       012345678901

		assertEquals(List.of(
				AstNode.assign(AstNode.add(AstNode.intLiteral(1, new Location(1, 12)),
				                           AstNode.intLiteral(2, new Location(1, 16)),
				                           new Location(1, 14)),
				               AstNode.lhs("foo", new Location(1, 2)),
				               new Location(1, 2))
		), new Parser(new Lexer("\n  var foo = 1 + 2;")).parse());
		//                       0 01234567890123456

		assertEquals(List.of(
				AstNode.assign(AstNode.add(AstNode.add(AstNode.intLiteral(1, new Location(0, 10)),
				                                       AstNode.intLiteral(2, new Location(0, 14)),
				                                       new Location(0, 12)),
				                           AstNode.intLiteral(3, new Location(0, 18)),
				                           new Location(0, 16)),
				               AstNode.lhs("foo", new Location(0, 0)),
				               new Location(0, 0))
		), new Parser(new Lexer("var foo = 1 + 2 + 3;")).parse());
		//                       0123456789012345678

		assertEquals(List.of(
				AstNode.assign(AstNode.add(AstNode.sub(AstNode.intLiteral(1, new Location(0, 10)),
				                                       AstNode.intLiteral(2, new Location(0, 14)),
				                                       new Location(0, 12)),
				                           AstNode.intLiteral(3, new Location(0, 18)),
				                           new Location(0, 16)),
				               AstNode.lhs("foo", new Location(0, 0)),
				               new Location(0, 0))
		), new Parser(new Lexer("var foo = 1 - 2 + 3;")).parse());
		//                       0123456789012345678

		assertEquals(List.of(
				AstNode.assign(AstNode.sub(AstNode.add(AstNode.intLiteral(1, new Location(0, 10)),
				                                       AstNode.intLiteral(2, new Location(0, 14)),
				                                       new Location(0, 12)),
				                           AstNode.intLiteral(3, new Location(0, 18)),
				                           new Location(0, 16)),
				               AstNode.lhs("foo", new Location(0, 0)),
				               new Location(0, 0))
		), new Parser(new Lexer("var foo = 1 + 2 - 3;")).parse());
		//                       0123456789012345678

		assertEquals(List.of(
				AstNode.assign(AstNode.add(AstNode.multiply(AstNode.intLiteral(1, new Location(0, 10)),
				                                            AstNode.intLiteral(3, new Location(0, 14)),
				                                            new Location(0, 12)),
				                           AstNode.multiply(AstNode.intLiteral(2, new Location(0, 18)),
				                                            AstNode.intLiteral(4, new Location(0, 22)),
				                                            new Location(0, 20)),
				                           new Location(0, 16)),
				               AstNode.lhs("foo", new Location(0, 0)),
				               new Location(0, 0))
		), new Parser(new Lexer("var foo = 1 * 3 + 2 * 4;")).parse());
		//                       012345678901234567890123

		assertEquals(List.of(
				AstNode.assign(AstNode.gt(AstNode.add(AstNode.intLiteral(1, new Location(0, 10)),
				                                      AstNode.intLiteral(3, new Location(0, 14)),
				                                      new Location(0, 12)),
				                          AstNode.multiply(AstNode.intLiteral(2, new Location(0, 18)),
				                                           AstNode.intLiteral(4, new Location(0, 22)),
				                                           new Location(0, 20)),
				                          new Location(0, 16)),
				               AstNode.lhs("foo", new Location(0, 0)),
				               new Location(0, 0))
		), new Parser(new Lexer("var foo = 1 + 3 > 2 * 4;")).parse());
		//                       012345678901234567890123
	}

	private void assertEquals(List<AstNode> expectedNodes, List<AstNode> currentNodes) {
		Assert.assertEquals(expectedNodes.size(), currentNodes.size());
		final Iterator<AstNode> expectedIt = expectedNodes.iterator();
		final Iterator<AstNode> currentIt = currentNodes.iterator();
		while (expectedIt.hasNext()) {
			final AstNode expectedNode = expectedIt.next();
			final AstNode currentNode = currentIt.next();

			assertEquals(expectedNode, currentNode);
		}
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