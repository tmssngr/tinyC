package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;

import java.util.*;

import org.junit.*;

/**
 * @author Thomas Singer
 */
public class ParserTest {

	@Test
	public void test() {
		final Parser parser = new Parser(new Lexer("var foo = 1;"));
		final List<AstNode> nodes = parser.parse();
		Assert.assertEquals(List.of(
				AstNode.assign(AstNode.intLiteral(1),
				               AstNode.lhs("foo"))
		                    ), nodes);
	}
}