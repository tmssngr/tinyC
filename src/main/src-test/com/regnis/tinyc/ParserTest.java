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
		Assert.assertEquals(List.of(
				AstNode.assign(AstNode.intLiteral(1, new Location(1, 1)),
				               AstNode.lhs("foo", new Location(1, 1)),
				               new Location(1, 1))
		), new Parser(new Lexer("var foo = 1;")).parse());

		Assert.assertEquals(List.of(
				AstNode.assign(AstNode.add(AstNode.intLiteral(1, new Location(1, 1)),
				                           AstNode.intLiteral(2, new Location(1, 1)),
				                           new Location(1, 1)),
				               AstNode.lhs("foo", new Location(1, 1)),
				               new Location(1, 1))
		), new Parser(new Lexer("var foo = 1 + 2;")).parse());

		Assert.assertEquals(List.of(
				AstNode.assign(AstNode.add(AstNode.add(AstNode.intLiteral(1, new Location(1, 1)),
				                                       AstNode.intLiteral(2, new Location(1, 1)),
				                                       new Location(1, 1)),
				                           AstNode.intLiteral(3, new Location(1, 1)),
				                           new Location(1, 1)),
				               AstNode.lhs("foo", new Location(1, 1)),
				               new Location(1, 1))
		), new Parser(new Lexer("var foo = 1 + 2 + 3;")).parse());

		Assert.assertEquals(List.of(
				AstNode.assign(AstNode.add(AstNode.sub(AstNode.intLiteral(1, new Location(1, 1)),
				                                       AstNode.intLiteral(2, new Location(1, 1)),
				                                       new Location(1, 1)),
				                           AstNode.intLiteral(3, new Location(1, 1)),
				                           new Location(1, 1)),
				               AstNode.lhs("foo", new Location(1, 1)),
				               new Location(1, 1))
		), new Parser(new Lexer("var foo = 1 - 2 + 3;")).parse());

		Assert.assertEquals(List.of(
				AstNode.assign(AstNode.sub(AstNode.add(AstNode.intLiteral(1, new Location(1, 1)),
				                                       AstNode.intLiteral(2, new Location(1, 1)),
				                                       new Location(1, 1)),
				                           AstNode.intLiteral(3, new Location(1, 1)),
				                           new Location(1, 1)),
				               AstNode.lhs("foo", new Location(1, 1)),
				               new Location(1, 1))
		), new Parser(new Lexer("var foo = 1 + 2 - 3;")).parse());

		Assert.assertEquals(List.of(
				AstNode.assign(AstNode.add(AstNode.multiply(AstNode.intLiteral(1, new Location(1, 1)),
				                                            AstNode.intLiteral(3, new Location(1, 1)),
				                                            new Location(1, 1)),
				                           AstNode.multiply(AstNode.intLiteral(2, new Location(1, 1)),
				                                            AstNode.intLiteral(4, new Location(1, 1)),
				                                            new Location(1, 1)),
				                           new Location(1, 1)),
				               AstNode.lhs("foo", new Location(1, 1)),
				               new Location(1, 1))
		), new Parser(new Lexer("var foo = 1 * 3 + 2 * 4;")).parse());
	}
}