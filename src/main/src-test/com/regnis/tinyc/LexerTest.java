package com.regnis.tinyc;

import org.junit.*;

import static org.junit.Assert.*;

/**
 * @author Thomas Singer
 */
public class LexerTest {

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
				nextInvalidTokenException("1:2 " + Messages.unterminatedBlockComment());
			}
		}.test();
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
				nextInvalidTokenException("1:3 " + Messages.unterminatedCharacterLiteral());
			}
		}.test();

		new LexerTester("""
				                 'ab""") {
			@Override
			protected void test() {
				nextInvalidTokenException("1:3 " + Messages.invalidCharLiteral());
			}
		}.test();

		new LexerTester("""
				                 ''""") {
			@Override
			protected void test() {
				nextInvalidTokenException("1:2 " + Messages.invalidCharLiteral());
			}
		}.test();

		new LexerTester("""
				                 'a""") {
			@Override
			protected void test() {
				nextInvalidTokenException("1:1 " + Messages.unterminatedCharacterLiteral());
			}
		}.test();
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
				nextInvalidTokenException("1:3 " + Messages.unterminatedStringLiteral());
			}
		}.test();
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

		public void nextInvalidTokenException(String expectedMessage) {
			try {
				fetchToken();
				fail();
			}
			catch (InvalidTokenException ex) {
				assertEquals(expectedMessage, ex.getMessage());
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
