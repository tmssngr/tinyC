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
		new LexerTester("var foo = bar - bazz - blup") {
			@Override
			protected void test() {
				assertType(TokenType.VAR);
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
		new LexerTester("var one = 1;") {
			@Override
			protected void test() {
				assertType(TokenType.VAR);
				assertLocation(0, 0);
				assertIdentifier("one");
				assertLocation(0, 4);
				assertType(TokenType.EQUAL);
				assertLocation(0, 8);
				assertIntLiteral(1);
				assertLocation(0, 10);
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