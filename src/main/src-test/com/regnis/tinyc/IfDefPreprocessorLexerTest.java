package com.regnis.tinyc;

import java.util.*;

import org.junit.*;

import static org.junit.Assert.*;

/**
 * @author Thomas Singer
 */
public class IfDefPreprocessorLexerTest {

	@Test
	public void testReturnsTokensOutsideConditionals() {
		assertEquals(List.of(
			token(TokenType.IDENTIFIER, "a", 0, 0),
			token(TokenType.WHITESPACE, " ", 0, 1),
			token(TokenType.COMMENT, "/*c*/", 0, 2),
			token(TokenType.WHITESPACE, " ", 0, 7),
			token(TokenType.IDENTIFIER, "b", 0, 8),
			token(TokenType.LINEBREAK, "\n", 0, 9),
			eof(1, 0)
		), readTokens("a /*c*/ b\n", Set.of()));
	}

	@Test
	public void testSelectsIfDefBranchAndElseBranch() {
		final String input = """
				{
				#ifdef A
				  1
				#else
				  2
				#endif
				}
				""";

		assertEquals(List.of(
			token(TokenType.L_BRACE, "", 0, 0),
			intToken(1, 2, 2),
			token(TokenType.R_BRACE, "", 6, 0),
			eof(7, 0)
		), readSignificantTokens(input, Set.of("A")));

		assertEquals(List.of(
			token(TokenType.L_BRACE, "", 0, 0),
			intToken(2, 4, 2),
			token(TokenType.R_BRACE, "", 6, 0),
			eof(7, 0)
		), readSignificantTokens(input, Set.of()));
	}

	@Test
	public void testIfDefWithoutElse() {
		final String input = """
				#ifdef A
				  5
				#endif
				""";

		assertEquals(List.of(intToken(5, 1, 2), eof(3, 0)), readSignificantTokens(input, Set.of("A")));
		assertEquals(List.of(eof(3, 0)), readSignificantTokens(input, Set.of()));
	}

	@Test
	public void testSeparateIfDefs() {
		final String input = """
				#ifdef A
				  1
				#endif
				#ifdef B
				  2
				#endif
				""";

		assertEquals(List.of(intToken(1, 1, 2), eof(6, 0)), readSignificantTokens(input, Set.of("A")));
		assertEquals(List.of(intToken(2, 4, 2), eof(6, 0)), readSignificantTokens(input, Set.of("B")));
		assertEquals(List.of(intToken(1, 1, 2), intToken(2, 4, 2), eof(6, 0)),
		             readSignificantTokens(input, Set.of("A", "B")));
		assertEquals(List.of(eof(6, 0)), readSignificantTokens(input, Set.of()));
	}

	@Test
	public void testNestedIfDefsWithoutElse() {
		final String input = """
				#ifdef A
				  #ifdef B
				    1
				  #endif
				  #ifdef C
				    2
				  #endif
				#endif
				""";

		assertEquals(List.of(intToken(1, 2, 4), eof(8, 0)), readSignificantTokens(input, Set.of("A", "B")));
		assertEquals(List.of(intToken(2, 5, 4), eof(8, 0)), readSignificantTokens(input, Set.of("A", "C")));
		assertEquals(List.of(intToken(1, 2, 4), intToken(2, 5, 4), eof(8, 0)),
		             readSignificantTokens(input, Set.of("A", "B", "C")));
		assertEquals(List.of(eof(8, 0)), readSignificantTokens(input, Set.of("B", "C")));
	}

	@Test
	public void testNestedIfDefsSelectEachCombination() {
		final String input = """
				#ifdef A
				  #ifdef B
				    0
				  #else
				    1
				  #endif
				#else
				  #ifdef B
				    2
				  #else
				    3
				  #endif
				#endif
				""";

		assertEquals(List.of(intToken(0, 2, 4), eof(13, 0)), readSignificantTokens(input, Set.of("A", "B")));
		assertEquals(List.of(intToken(1, 4, 4), eof(13, 0)), readSignificantTokens(input, Set.of("A")));
		assertEquals(List.of(intToken(2, 8, 4), eof(13, 0)), readSignificantTokens(input, Set.of("B")));
		assertEquals(List.of(intToken(3, 10, 4), eof(13, 0)), readSignificantTokens(input, Set.of()));
	}

	@Test
	public void testMalformedAndUnmatchedDirectives() {
		assertSyntaxException("#ifdef\n", Set.of(), "Expected IDENTIFIER but got LINEBREAK", new Location(0, 6));
		assertSyntaxException("#else\n", Set.of(), Messages.elseWithoutIfdef(), new Location(0, 0));
		assertSyntaxException("#endif\n", Set.of(), Messages.endifWithoutIfdef(), new Location(0, 0));
	}

	@Test
	public void testDuplicateElseAndUnclosedIfDef() {
		final String duplicateElse = """
				#ifdef A
				#else
				#else
				""";
		assertSyntaxException(duplicateElse, Set.of("A"), Messages.duplicateElse(new Location(1, 0)), new Location(2, 0));

		final String unclosedIfDef = "#ifdef A\n";
		assertSyntaxException(unclosedIfDef, Set.of(), Messages.unclosedIfdef(), new Location(0, 0));
		assertSyntaxException(unclosedIfDef, Set.of("A"), Messages.unclosedIfdef(), new Location(0, 0));
	}

	private static List<Token> readSignificantTokens(String input, Set<String> defines) {
		return readTokens(input, defines).stream()
			.filter(token -> token.type() != TokenType.WHITESPACE
			                 && token.type() != TokenType.COMMENT
			                 && token.type() != TokenType.LINEBREAK)
			.toList();
	}

	private static List<Token> readTokens(String input, Set<String> defines) {
		final Lexer lexer = new IfDefPreprocessorLexer(new LexerImpl(input), new IfDefHandling(defines));
		final List<Token> tokens = new ArrayList<>();
		while (true) {
			final Token token = lexer.next();
			tokens.add(token);
			if (token.type() == TokenType.EOF) {
				return tokens;
			}
		}
	}

	private static void assertSyntaxException(String input, Set<String> defines, String message, Location location) {
		try {
			readTokens(input, defines);
			fail("Expected syntax exception");
		}
		catch (SyntaxException ex) {
			assertEquals(message, ex.getMessage());
			assertEquals(location, ex.location);
		}
	}

	private static Token intToken(int value, int line, int column) {
		return new Token(TokenType.INT_LITERAL, value, "", new Location(line, column));
	}

	private static Token eof(int line, int column) {
		return token(TokenType.EOF, "", line, column);
	}

	private static Token token(TokenType type, String text, int line, int column) {
		return new Token(type, 0, text, new Location(line, column));
	}
}
