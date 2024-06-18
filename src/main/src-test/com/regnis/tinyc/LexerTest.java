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
				assertIdentifier("foo");
				assertText(TokenType.COMMENT, "/* bar\nbazz* / */");
				assertIdentifier("blupp");
				assertEof();
			}
		}.test();
	}

	@Test
	public void textAssignment() {
		new LexerTester("var foo = bar - bazz - blup") {
			@Override
			protected void test() {
				assertType(TokenType.VAR);
				assertIdentifier("foo");
				assertType(TokenType.EQUAL);
				assertIdentifier("bar");
				assertType(TokenType.MINUS);
				assertIdentifier("bazz");
				assertType(TokenType.MINUS);
				assertIdentifier("blup");
				assertEof();
			}
		}.test();
	}

	@Test
	public void testComparisonSigns() {
		new LexerTester("< <= == != >= > !") {
			@Override
			protected void test() {
				assertType(TokenType.LT);
				assertType(TokenType.LT_EQ);
				assertType(TokenType.EQ_EQ);
				assertType(TokenType.EXCL_EQ);
				assertType(TokenType.GT_EQ);
				assertType(TokenType.GT);
				assertType(TokenType.EXCL);
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