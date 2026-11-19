package com.regnis.tinyc;

import java.util.*;

import org.junit.*;

import static org.junit.Assert.*;

/**
 * @author Thomas Singer
 */
public class LexerTest {

	@Test
	public void testEmptyInput() {
		new LexerTester("") {
			@Override
			protected void test() {
				nextEof(0, 0);
				nextEof(0, 0);
			}
		}.test();
	}

	@Test
	public void testWhitespaceAndLineBreaks() {
		new LexerTester(" \t\r\n\n\t \n \t") {
			@Override
			protected void test() {
				nextWhitespace(" \t", 0, 0);
				nextText(TokenType.LINEBREAK, "\r\n\n", 0, 2);
				nextWhitespace("\t ", 2, 0);
				nextLineBreak(2, 2);
				nextWhitespace(" \t", 3, 0);
				nextEof(3, 2);
			}
		}.test();
	}

	@Test
	public void testStandaloneCarriageReturn() {
		final Lexer lexer = new LexerImpl("\r");
		assertEquals(new Token(TokenType.LINEBREAK, 0, "\r", new Location(0, 0)), lexer.next());
		assertEquals(TokenType.EOF, lexer.next().type());
	}

	@Test
	public void testComments() {
		new LexerTester("""
				                // line
				                foo /* bar
				                bazz* / */ blupp""") {
			@Override
			protected void test() {
				nextText(TokenType.COMMENT, "// line", 0, 0);
				nextLineBreak(0, 7);
				nextIdentifier("foo", 1, 0);
				nextWhitespace(" ", 1, 3);
				nextText(TokenType.COMMENT, "/* bar\nbazz* / */", 1, 4);
				nextWhitespace(" ", 2, 10);
				nextIdentifier("blupp", 2, 11);
				nextEof(2, 16);
			}
		}.test();

		new LexerTester("""
				                 /*
				                bla""") {
			@Override
			protected void test() {
				nextWhitespace(" ", 0, 0);
				nextInvalidTokenException(Messages.unterminatedBlockComment(), 0, 1);
			}
		}.test();
	}

	@Test
	public void testCommentBoundaries() {
		new LexerTester("a/**//* outer /* inner **/b//\r\n// eof") {
			@Override
			protected void test() {
				nextIdentifier("a", 0, 0);
				nextText(TokenType.COMMENT, "/**/", 0, 1);
				nextText(TokenType.COMMENT, "/* outer /* inner **/", 0, 5);
				nextIdentifier("b", 0, 26);
				nextText(TokenType.COMMENT, "//", 0, 27);
				nextText(TokenType.LINEBREAK, "\r\n", 0, 29);
				nextText(TokenType.COMMENT, "// eof", 1, 0);
				nextEof(1, 6);
			}
		}.test();

		assertInvalidToken("/*/", Messages.unterminatedBlockComment(), 0);
	}

	@Test
	public void testLiterals() {
		//               012345678901234567890123456789
		new LexerTester("1 2_3 0b10 0x20 0xCafe 10i16 '0'") {
			@Override
			protected void test() {
				nextIntValue(1, 0, 0);
				nextWhitespace(" ", 0, 1);
				nextIntValue(23, 0, 2);
				nextWhitespace(" ", 0, 5);
				nextIntValue(2, 0, 6);
				nextWhitespace(" ", 0, 10);
				nextIntValue(0x20, 0, 11);
				nextWhitespace(" ", 0, 15);
				nextIntValue(0xCafe, 0, 16);
				nextWhitespace(" ", 0, 22);
				nextIntValue(10, "i16", 0, 23);
				nextWhitespace(" ", 0, 28);
				nextIntValue('0', 0, 29);
				nextEof(0, 32);
			}
		}.test();

		new LexerTester("""
				                 'a
				               """) {
			@Override
			protected void test() {
				nextWhitespace("  ", 0, 0);
				nextInvalidTokenException(Messages.unterminatedCharacterLiteral(), 0, 2);
			}
		}.test();

		new LexerTester("""
				                 'ab""") {
			@Override
			protected void test() {
				nextInvalidTokenException(Messages.invalidCharLiteral(), 0, 2);
			}
		}.test();

		new LexerTester("""
				                 ''""") {
			@Override
			protected void test() {
				nextInvalidTokenException(Messages.invalidCharLiteral(), 0, 1);
			}
		}.test();

		new LexerTester("""
				                 'a""") {
			@Override
			protected void test() {
				nextInvalidTokenException(Messages.unterminatedCharacterLiteral(), 0, 0);
			}
		}.test();
	}

	@Test
	public void testIntegerLiteralBoundaries() {
		new LexerTester("""
				                0 007 -1
				                0b1_01u8 0xF_fi16
				                2_147_483_647 0x7fff_ffff
				                0b111_1111_1111_1111_1111_1111_1111_1111""") {
			@Override
			protected void test() {
				nextIntValue(0, 0, 0);
				nextWhitespace(" ", 0, 1);
				nextIntValue(7, 0, 2);
				nextWhitespace(" ", 0, 5);
				nextType(TokenType.MINUS, 0, 6);
				nextIntValue(1, 0, 7);
				nextLineBreak(0, 8);
				nextIntValue(5, "u8", 1, 0);
				nextWhitespace(" ", 1, 8);
				nextIntValue(255, "i16", 1, 9);
				nextLineBreak(1, 17);
				nextIntValue(Integer.MAX_VALUE, 2, 0);
				nextWhitespace(" ", 2, 13);
				nextIntValue(Integer.MAX_VALUE, 2, 14);
				nextLineBreak(2, 25);
				nextIntValue(Integer.MAX_VALUE, 3, 0);
				nextEof(3, 40);
			}
		}.test();
	}

	@Test
	public void testIntegerSuffixesAndSeparators() {
		new LexerTester("0b102 0x1g 12unknown 12__34") {
			@Override
			protected void test() {
				nextIntValue(2, "2", 0, 0);
				nextWhitespace(" ", 0, 5);
				nextIntValue(1, "g", 0, 6);
				nextWhitespace(" ", 0, 10);
				nextIntValue(12, "unknown", 0, 11);
				nextWhitespace(" ", 0, 20);
				nextIntValue(1234, 0, 21);
				nextEof(0, 27);
			}
		}.test();
	}

	@Test
	public void testInvalidPrefixedIntegers() {
		for (String input : List.of("0b", "0b2", "0b_1", "0b1_", "0b1_u8", "0b1000_0000_0000_0000_0000_0000_0000_0000",
		                            "0x", "0xG", "0x_1", "0x1_", "0x1_u8", "0x80000000")) {
			assertInvalidToken(input, "Invalid number", 0);
		}

		new LexerTester("\r\n\t0x") {
			@Override
			protected void test() {
				nextText(TokenType.LINEBREAK, "\r\n", 0, 0);
				nextWhitespace("\t", 1, 0);
				nextInvalidTokenException("Invalid number", 1, 1);
			}
		}.test();
	}

	@Test
	public void testDecimalFallbackToIdentifier() {
		for (String input : List.of("_12", "12_", "12_i16", "2147483648")) {
			assertSingleToken(input, TokenType.IDENTIFIER, input);
		}
	}

	@Test
	public void testStringLiterals() {
		new LexerTester("""
				                 "\\"\\x1234"
				                """) {
			@Override
			protected void test() {
				nextWhitespace(" ", 0, 0);
				nextText(TokenType.STRING, "\"\u1234", 0, 1);

				nextLineBreak(0, 11);
				nextEof(1, 0);
			}
		}.test();

		new LexerTester("""
				                 "a
				               """) {
			@Override
			protected void test() {
				nextWhitespace("  ", 0, 0);
				nextInvalidTokenException(Messages.unterminatedStringLiteral(), 0, 2);
			}
		}.test();
	}

	@Test
	public void testEmptyAndEscapedStrings() {
		new LexerTester("\"\"\"\\t\\n\\r\\0\\\\\\\"\\'\\q\"") {
			@Override
			protected void test() {
				nextText(TokenType.STRING, "", 0, 0);
				nextText(TokenType.STRING, "\t\n\r\0\\\"'q", 0, 2);
				nextEof(0, 20);
			}
		}.test();
	}

	@Test
	public void testHexEscapes() {
		assertSingleToken("\"\\x1Z\\x09Af:\\x1ffff!\\x0g\"", TokenType.STRING, "\1Z\u09af:\uffff!\0g");
	}

	@Test
	public void testEscapedCharacterLiterals() {
		new LexerTester("'\\'' '\\\\' '\\xFF' '\u00e9'") {
			@Override
			protected void test() {
				nextIntValue('\'', 0, 0);
				nextWhitespace(" ", 0, 4);
				nextIntValue('\\', 0, 5);
				nextWhitespace(" ", 0, 9);
				nextIntValue(255, 0, 10);
				nextWhitespace(" ", 0, 16);
				nextIntValue('\u00e9', 0, 17);
				nextEof(0, 20);
			}
		}.test();

		assertInvalidToken("'\\nq'", Messages.invalidCharLiteral(), 3);
	}

	@Test
	public void testInvalidHexEscapes() {
		assertInvalidToken("\"a\\x\"", "Invalid char escape", 2);
		assertInvalidToken("\"\\xG\"", "Invalid char escape", 1);
		assertInvalidToken("\"\\x", "Invalid char escape", 1);
		assertInvalidToken("'\\x'", "Invalid char escape", 1);
	}

	@Test
	public void testUnterminatedLiterals() {
		for (String input : List.of("\"", "\"a", "\"a\\", "\"\\x1", "\"a\\\r\n")) {
			assertInvalidToken(input, Messages.unterminatedStringLiteral(), 0);
		}
		for (String input : List.of("'", "'\\", "'\\'")) {
			assertInvalidToken(input, Messages.unterminatedCharacterLiteral(), 0);
		}
	}

	@Test
	public void textIdentifiers() {
		//               012345678901234567890
		new LexerTester("const BOARD_CAP = 30;") {
			@Override
			protected void test() {
				nextText(TokenType.CONST, "const", 0, 0);
				nextWhitespace(" ", 0, 5);
				nextIdentifier("BOARD_CAP", 0, 6);
				nextWhitespace(" ", 0, 15);
				nextType(TokenType.EQUAL, 0, 16);
				nextWhitespace(" ", 0, 17);
				nextIntValue(30, 0, 18);
				nextType(TokenType.SEMI, 0, 20);
				nextEof(0, 21);
			}
		}.test();
	}

	@Test
	public void testKeywordsAndDirectives() {
		assertSingleToken("true", TokenType.TRUE, "true");
		assertSingleToken("false", TokenType.FALSE, "false");
		assertSingleToken("return", TokenType.RETURN, "return");
		assertSingleToken("for", TokenType.FOR, "for");
		assertSingleToken("break", TokenType.BREAK, "break");
		assertSingleToken("continue", TokenType.CONTINUE, "continue");
		assertSingleToken("typedef", TokenType.TYPEDEF, "typedef");
		assertSingleToken("struct", TokenType.STRUCT, "struct");
		assertSingleToken("#include", TokenType.HASH_INCLUDE, "#include");
		assertSingleToken("#ifdef", TokenType.HASH_IFDEF, "#ifdef");
		assertSingleToken("#else", TokenType.HASH_ELSE, "#else");
		assertSingleToken("#endif", TokenType.HASH_ENDIF, "#endif");
		assertSingleToken("asm", TokenType.ASM, "asm");
		assertSingleToken("as", TokenType.AS, "as");
	}

	@Test
	public void testKeywordBoundaries() {
		for (String input : List.of("if0", "IF", "_if", "true_value", "#ifdefExtra")) {
			assertSingleToken(input, TokenType.IDENTIFIER, input);
		}
	}

	@Test
	public void textAssignment() {
		//               012345678901234567890123456
		new LexerTester("i16 foo = bar - bazz - blup") {
			@Override
			protected void test() {
				nextIdentifier("i16", 0, 0);
				nextWhitespace(" ", 0, 3);
				nextIdentifier("foo", 0, 4);
				nextWhitespace(" ", 0, 7);
				nextType(TokenType.EQUAL, 0, 8);
				nextWhitespace(" ", 0, 9);
				nextIdentifier("bar", 0, 10);
				nextWhitespace(" ", 0, 13);
				nextType(TokenType.MINUS, 0, 14);
				nextWhitespace(" ", 0, 15);
				nextIdentifier("bazz", 0, 16);
				nextWhitespace(" ", 0, 20);
				nextType(TokenType.MINUS, 0, 21);
				nextWhitespace(" ", 0, 22);
				nextIdentifier("blup", 0, 23);
				nextEof(0, 27);
			}
		}.test();

		//               012345678901
		new LexerTester("u8 one = 1;") {
			@Override
			protected void test() {
				nextIdentifier("u8", 0, 0);
				nextWhitespace(" ", 0, 2);
				nextIdentifier("one", 0, 3);
				nextWhitespace(" ", 0, 6);
				nextType(TokenType.EQUAL, 0, 7);
				nextWhitespace(" ", 0, 8);
				nextIntValue(1, 0, 9);
				nextType(TokenType.SEMI, 0, 10);
				nextEof(0, 11);
			}
		}.test();

		//               012345678901
		new LexerTester("u8 qm = '?';") {
			@Override
			protected void test() {
				nextIdentifier("u8", 0, 0);
				nextWhitespace(" ", 0, 2);
				nextIdentifier("qm", 0, 3);
				nextWhitespace(" ", 0, 5);
				nextType(TokenType.EQUAL, 0, 6);
				nextWhitespace(" ", 0, 7);
				nextIntValue('?', 0, 8);
				nextType(TokenType.SEMI, 0, 11);
				nextEof(0, 12);
			}
		}.test();
	}

	@Test
	public void testComparisonSigns() {
		//               01234567890123456
		new LexerTester("< <= == != >= > !") {
			@Override
			protected void test() {
				nextType(TokenType.LT, 0, 0);
				nextWhitespace(" ", 0, 1);
				nextType(TokenType.LT_EQ, 0, 2);
				nextWhitespace(" ", 0, 4);
				nextType(TokenType.EQ_EQ, 0, 5);
				nextWhitespace(" ", 0, 7);
				nextType(TokenType.EXCL_EQ, 0, 8);
				nextWhitespace(" ", 0, 10);
				nextType(TokenType.GT_EQ, 0, 11);
				nextWhitespace(" ", 0, 13);
				nextType(TokenType.GT, 0, 14);
				nextWhitespace(" ", 0, 15);
				nextType(TokenType.EXCL, 0, 16);
				nextEof(0, 17);
			}
		}.test();
	}

	@Test
	public void testOperatorsAndPunctuationAtEof() {
		assertSingleToken("+", TokenType.PLUS, "");
		assertSingleToken("+=", TokenType.PLUS_EQ, "");
		assertSingleToken("-=", TokenType.MINUS_EQ, "");
		assertSingleToken("*=", TokenType.STAR_EQ, "");
		assertSingleToken("/", TokenType.SLASH, "");
		assertSingleToken("/=", TokenType.SLASH_EQ, "");
		assertSingleToken("%", TokenType.PERCENT, "");
		assertSingleToken("%=", TokenType.PERCENT_EQ, "");
		assertSingleToken("&=", TokenType.AMP_EQ, "");
		assertSingleToken("&&", TokenType.AMP_AMP, "");
		assertSingleToken("|", TokenType.PIPE, "");
		assertSingleToken("|=", TokenType.PIPE_EQ, "");
		assertSingleToken("||", TokenType.PIPE_PIPE, "");
		assertSingleToken("^", TokenType.CARET, "");
		assertSingleToken("^=", TokenType.CARET_EQ, "");
		assertSingleToken("<<", TokenType.LT_LT, "");
		assertSingleToken("<<=", TokenType.LT_LT_EQ, "");
		assertSingleToken(">>", TokenType.GT_GT, "");
		assertSingleToken(">>=", TokenType.GT_GT_EQ, "");
		assertSingleToken("~", TokenType.TILDE, "");
		assertSingleToken(".", TokenType.DOT, "");
		assertSingleToken(",", TokenType.COMMA, "");
		assertSingleToken("[", TokenType.L_BRACKET, "");
		assertSingleToken("]", TokenType.R_BRACKET, "");
	}

	@Test
	public void testAdjacentOperators() {
		new LexerTester("a++--<<==>>=&&&=|||=!==/=/b") {
			@Override
			protected void test() {
				nextIdentifier("a", 0, 0);
				nextType(TokenType.PLUS, 0, 1);
				nextType(TokenType.PLUS, 0, 2);
				nextType(TokenType.MINUS, 0, 3);
				nextType(TokenType.MINUS, 0, 4);
				nextType(TokenType.LT_LT_EQ, 0, 5);
				nextType(TokenType.EQUAL, 0, 8);
				nextType(TokenType.GT_GT_EQ, 0, 9);
				nextType(TokenType.AMP_AMP, 0, 12);
				nextType(TokenType.AMP_EQ, 0, 14);
				nextType(TokenType.PIPE_PIPE, 0, 16);
				nextType(TokenType.PIPE_EQ, 0, 18);
				nextType(TokenType.EXCL_EQ, 0, 20);
				nextType(TokenType.EQUAL, 0, 22);
				nextType(TokenType.SLASH_EQ, 0, 23);
				nextType(TokenType.SLASH, 0, 25);
				nextIdentifier("b", 0, 26);
				nextEof(0, 27);
			}
		}.test();
	}

	@Test
	public void testIfElse() {
		new LexerTester("""
				                if (1 < 2) {
				                  print(1);
				                }
				                else {
				                  print(2);
				                }""") {
			@Override
			protected void test() {
				nextText(TokenType.IF, "if", 0, 0);
				nextWhitespace(" ", 0, 2);
				nextType(TokenType.L_PAREN, 0, 3);
				nextIntValue(1, 0, 4);
				nextWhitespace(" ", 0, 5);
				nextType(TokenType.LT, 0, 6);
				nextWhitespace(" ", 0, 7);
				nextIntValue(2, 0, 8);
				nextType(TokenType.R_PAREN, 0, 9);
				nextWhitespace(" ", 0, 10);
				nextType(TokenType.L_BRACE, 0, 11);

				nextLineBreak(0, 12);

				nextWhitespace("  ", 1, 0);
				nextIdentifier("print", 1, 2);
				nextType(TokenType.L_PAREN, 1, 7);
				nextIntValue(1, 1, 8);
				nextType(TokenType.R_PAREN, 1, 9);
				nextType(TokenType.SEMI, 1, 10);

				nextLineBreak(1, 11);

				nextType(TokenType.R_BRACE, 2, 0);

				nextLineBreak(2, 1);

				nextText(TokenType.ELSE, "else", 3, 0);
				nextWhitespace(" ", 3, 4);
				nextType(TokenType.L_BRACE, 3, 5);

				nextLineBreak(3, 6);

				nextWhitespace("  ", 4, 0);
				nextIdentifier("print", 4, 2);
				nextType(TokenType.L_PAREN, 4, 7);
				nextIntValue(2, 4, 8);
				nextType(TokenType.R_PAREN, 4, 9);
				nextType(TokenType.SEMI, 4, 10);

				nextLineBreak(4, 11);

				nextType(TokenType.R_BRACE, 5, 0);

				nextEof(5, 1);
			}
		}.test();
	}

	@Test
	public void testWhile() {
		new LexerTester("""
				                while (i > 0) {
				                  print(i);
				                  i = i - 1;
				                }""") {
			@Override
			protected void test() {
				nextText(TokenType.WHILE, "while", 0, 0);
				nextWhitespace(" ", 0, 5);
				nextType(TokenType.L_PAREN, 0, 6);
				nextIdentifier("i", 0, 7);
				nextWhitespace(" ", 0, 8);
				nextType(TokenType.GT, 0, 9);
				nextWhitespace(" ", 0, 10);
				nextIntValue(0, 0, 11);
				nextType(TokenType.R_PAREN, 0, 12);
				nextWhitespace(" ", 0, 13);
				nextType(TokenType.L_BRACE, 0, 14);

				nextLineBreak(0, 15);

				nextWhitespace("  ", 1, 0);
				nextIdentifier("print", 1, 2);
				nextType(TokenType.L_PAREN, 1, 7);
				nextIdentifier("i", 1, 8);
				nextType(TokenType.R_PAREN, 1, 9);
				nextType(TokenType.SEMI, 1, 10);

				nextLineBreak(1, 11);

				nextWhitespace("  ", 2, 0);
				nextIdentifier("i", 2, 2);
				nextWhitespace(" ", 2, 3);
				nextType(TokenType.EQUAL, 2, 4);
				nextWhitespace(" ", 2, 5);
				nextIdentifier("i", 2, 6);
				nextWhitespace(" ", 2, 7);
				nextType(TokenType.MINUS, 2, 8);
				nextWhitespace(" ", 2, 9);
				nextIntValue(1, 2, 10);
				nextType(TokenType.SEMI, 2, 11);

				nextLineBreak(2, 12);

				nextType(TokenType.R_BRACE, 3, 0);

				nextEof(3, 1);
			}
		}.test();
	}

	@Test
	public void testPointer() {
		new LexerTester("""
				                u8 char = 0x20;
				                u8 *ptrToChar = &char;""") {
			@Override
			protected void test() {
				nextIdentifier("u8", 0, 0);
				nextWhitespace(" ", 0, 2);
				nextIdentifier("char", 0, 3);
				nextWhitespace(" ", 0, 7);
				nextType(TokenType.EQUAL, 0, 8);
				nextWhitespace(" ", 0, 9);
				nextIntValue(32, 0, 10);
				nextType(TokenType.SEMI, 0, 14);

				nextLineBreak(0, 15);

				nextIdentifier("u8", 1, 0);
				nextWhitespace(" ", 1, 2);
				nextType(TokenType.STAR, 1, 3);
				nextIdentifier("ptrToChar", 1, 4);
				nextWhitespace(" ", 1, 13);
				nextType(TokenType.EQUAL, 1, 14);
				nextWhitespace(" ", 1, 15);
				nextType(TokenType.AMP, 1, 16);
				nextIdentifier("char", 1, 17);
				nextType(TokenType.SEMI, 1, 21);
				nextEof(1, 22);
			}
		}.test();
	}

	private static void assertSingleToken(String input, TokenType expectedType, String expectedText) {
		final Lexer lexer = new LexerImpl(input);
		assertEquals(input, new Token(expectedType, 0, expectedText, new Location(0, 0)), lexer.next());
		assertEquals(input, new Token(TokenType.EOF, 0, "", new Location(0, input.length())), lexer.next());
	}

	private static void assertInvalidToken(String input, String expectedMessage, int expectedColumn) {
		new LexerTester(input) {
			@Override
			protected void test() {
				nextInvalidTokenException(expectedMessage, 0, expectedColumn);
			}
		}.test();
	}

	private abstract static class LexerTester {
		protected abstract void test();

		private final Lexer lexer;

		public LexerTester(String text) {
			this.lexer = new LexerImpl(text);
		}

		public void nextType(TokenType expectedType, int expectedLine, int expectedColumn) {
			nextToken(expectedType, 0, "", expectedLine, expectedColumn);
		}

		public void nextText(TokenType expectedType, String expectedText, int expectedLine, int expectedColumn) {
			nextToken(expectedType, 0, expectedText, expectedLine, expectedColumn);
		}

		public void nextIntValue(int expectedValue, int expectedLine, int expectedColumn) {
			nextIntValue(expectedValue, "", expectedLine, expectedColumn);
		}

		public void nextIntValue(int expectedValue, String expectedText, int expectedLine, int expectedColumn) {
			nextToken(TokenType.INT_LITERAL, expectedValue, expectedText, expectedLine, expectedColumn);
		}

		public void nextIdentifier(String expectedText, int expectedLine, int expectedColumn) {
			nextText(TokenType.IDENTIFIER, expectedText, expectedLine, expectedColumn);
		}

		public void nextLineBreak(int expectedLine, int expectedColumn) {
			nextText(TokenType.LINEBREAK, "\n", expectedLine, expectedColumn);
		}

		public void nextWhitespace(String expectedText, int expectedLine, int expectedColumn) {
			nextText(TokenType.WHITESPACE, expectedText, expectedLine, expectedColumn);
		}

		public void nextEof(int expectedLine, int expectedColumn) {
			nextType(TokenType.EOF, expectedLine, expectedColumn);
		}

		public void nextInvalidTokenException(String expectedMessage, int expectedLine, int expectedColumn) {
			final Location expectedLocation = new Location(expectedLine, expectedColumn);
			try {
				fail("Expected an invalid token but got " + fetchToken());
			}
			catch (InvalidTokenException ex) {
				assertEquals(expectedLocation, ex.location);
				assertEquals((expectedLine + 1) + ":" + (expectedColumn + 1) + " " + expectedMessage, ex.getMessage());
			}
		}

		private void nextToken(TokenType expectedType, int expectedIntValue, String expectedText,
		                       int expectedLine, int expectedColumn) {
			final Token token = fetchToken();
			assertEquals(expectedType, token.type());
			assertEquals(expectedIntValue, token.intValue());
			assertEquals(expectedText, token.text());
			final Location location = token.location();
			assertEquals(expectedLine, location.line());
			assertEquals(expectedColumn, location.column());
		}

		private Token fetchToken() {
			return lexer.next();
		}
	}
}
