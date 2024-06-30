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
				assertText(TokenType.COMMENT, "// line");
				assertLocation(0, 0);
				assertIdentifier("foo");
				assertLocation(1, 0);
				assertText(TokenType.COMMENT, "/* bar\nbazz* / */");
				assertLocation(1, 4);
				assertIdentifier("blupp");
				assertLocation(2, 11);
				assertEof();
			}
		}.test();
	}

	@Test
	public void textAssignment() {
		//               012345678901234567890123456
		new LexerTester("i16 foo = bar - bazz - blup") {
			@Override
			protected void test() {
				assertIdentifier("i16");
				assertLocation(0, 0);
				assertIdentifier("foo");
				assertLocation(0, 4);
				assertType(TokenType.EQUAL);
				assertLocation(0, 8);
				assertIdentifier("bar");
				assertLocation(0, 10);
				assertType(TokenType.MINUS);
				assertLocation(0, 14);
				assertIdentifier("bazz");
				assertLocation(0, 16);
				assertType(TokenType.MINUS);
				assertLocation(0, 21);
				assertIdentifier("blup");
				assertLocation(0, 23);
				assertEof();
			}
		}.test();

		//               012345678901
		new LexerTester("u8 one = 1;") {
			@Override
			protected void test() {
				assertIdentifier("u8");
				assertLocation(0, 0);
				assertIdentifier("one");
				assertLocation(0, 3);
				assertType(TokenType.EQUAL);
				assertLocation(0, 7);
				assertIntLiteral(1);
				assertLocation(0, 9);
			}
		}.test();
	}

	@Test
	public void testComparisonSigns() {
		//               01234567890123456
		new LexerTester("< <= == != >= > !") {
			@Override
			protected void test() {
				assertType(TokenType.LT);
				assertLocation(0, 0);
				assertType(TokenType.LT_EQ);
				assertLocation(0, 2);
				assertType(TokenType.EQ_EQ);
				assertLocation(0, 5);
				assertType(TokenType.EXCL_EQ);
				assertLocation(0, 8);
				assertType(TokenType.GT_EQ);
				assertLocation(0, 11);
				assertType(TokenType.GT);
				assertLocation(0, 14);
				assertType(TokenType.EXCL);
				assertLocation(0, 16);
				assertEof();
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
				assertType(TokenType.IF);
				assertLocation(0, 0);
				assertType(TokenType.L_PAREN);
				assertLocation(0, 3);
				assertIntLiteral(1);
				assertLocation(0, 4);
				assertType(TokenType.LT);
				assertLocation(0, 6);
				assertIntLiteral(2);
				assertLocation(0, 8);
				assertType(TokenType.R_PAREN);
				assertLocation(0, 9);
				assertType(TokenType.L_BRACE);
				assertLocation(0, 11);

				assertIdentifier("print");
				assertLocation(1, 2);
				assertType(TokenType.L_PAREN);
				assertLocation(1, 7);
				assertIntLiteral(1);
				assertLocation(1, 8);
				assertType(TokenType.R_PAREN);
				assertLocation(1, 9);
				assertType(TokenType.SEMI);
				assertLocation(1, 10);

				assertType(TokenType.R_BRACE);
				assertLocation(2, 0);

				assertType(TokenType.ELSE);
				assertLocation(3, 0);
				assertType(TokenType.L_BRACE);
				assertLocation(3, 5);

				assertIdentifier("print");
				assertLocation(4, 2);
				assertType(TokenType.L_PAREN);
				assertLocation(4, 7);
				assertIntLiteral(2);
				assertLocation(4, 8);
				assertType(TokenType.R_PAREN);
				assertLocation(4, 9);
				assertType(TokenType.SEMI);
				assertLocation(4, 10);

				assertType(TokenType.R_BRACE);
				assertLocation(5, 0);

				assertEof();
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
				assertType(TokenType.WHILE);
				assertLocation(0, 0);
				assertType(TokenType.L_PAREN);
				assertLocation(0, 6);
				assertIdentifier("i");
				assertLocation(0, 7);
				assertType(TokenType.GT);
				assertLocation(0, 9);
				assertIntLiteral(0);
				assertLocation(0, 11);
				assertType(TokenType.R_PAREN);
				assertLocation(0, 12);
				assertType(TokenType.L_BRACE);
				assertLocation(0, 14);

				assertIdentifier("print");
				assertLocation(1, 2);
				assertType(TokenType.L_PAREN);
				assertLocation(1, 7);
				assertIdentifier("i");
				assertLocation(1, 8);
				assertType(TokenType.R_PAREN);
				assertLocation(1, 9);
				assertType(TokenType.SEMI);
				assertLocation(1, 10);

				assertIdentifier("i");
				assertLocation(2, 2);
				assertType(TokenType.EQUAL);
				assertLocation(2, 4);
				assertIdentifier("i");
				assertLocation(2, 6);
				assertType(TokenType.MINUS);
				assertLocation(2, 8);
				assertIntLiteral(1);
				assertLocation(2, 10);
				assertType(TokenType.SEMI);
				assertLocation(2, 11);

				assertType(TokenType.R_BRACE);
				assertLocation(3, 0);

				assertEof();
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
				assertIdentifier("u8");
				assertLocation(0, 0);
				assertIdentifier("char");
				assertLocation(0, 3);
				assertType(TokenType.EQUAL);
				assertLocation(0, 8);
				assertIntLiteral(32);
				assertLocation(0, 10);
				assertType(TokenType.SEMI);
				assertLocation(0, 14);

				assertIdentifier("u8");
				assertLocation(1, 0);
				assertType(TokenType.STAR);
				assertLocation(1, 3);
				assertIdentifier("ptrToChar");
				assertLocation(1, 4);
				assertType(TokenType.EQUAL);
				assertLocation(1, 14);
				assertType(TokenType.AMP);
				assertLocation(1, 16);
				assertIdentifier("char");
				assertLocation(1, 17);
				assertType(TokenType.SEMI);
				assertLocation(1, 21);
				assertEof();
			}
		}.test();
	}

	private abstract static class LexerTester {
		protected abstract void test();

		private final Lexer lexer;

		public LexerTester(String text) {
			this.lexer = new Lexer(text);
		}

		public void assertLocation(int expectedLine, int expectedColumn) {
			final Location location = lexer.getLocation();
			assertEquals(expectedLine, location.line());
			assertEquals(expectedColumn, location.column());
		}

		public void assertEof() {
			assertType(TokenType.EOF);
		}

		public void assertIdentifier(String expected) {
			assertText(TokenType.IDENTIFIER, expected);
		}

		public void assertIntLiteral(int expected) {
			assertValue(TokenType.INT_LITERAL, expected);
		}

		public void assertInvalidTokenException(String expectedMsg, int expectedLine, int expectedColumn) {
			try {
				next();
				fail();
			}
			catch (InvalidTokenException ex) {
				assertEquals(expectedMsg, ex.getMessage());
				assertEquals(expectedLine, ex.location.line());
				assertEquals(expectedColumn, ex.location.column());
			}
		}

		public void assertType(TokenType type) {
			final TokenType next = next();
			assertEquals(type, next);
		}

		public void assertText(TokenType type, String expected) {
			assertType(type);
			assertEquals(expected, lexer.getText());
		}

		private void assertValue(TokenType type, int expected) {
			assertType(type);
			assertEquals(expected, lexer.getIntValue());
		}

		private TokenType next() {
			TokenType type;
			do {
				type = lexer.next();
			}
			while (type == TokenType.WHITESPACE);
			return type;
		}
	}
}