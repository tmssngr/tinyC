package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;

import org.junit.*;

/**
 * @author Thomas Singer
 */
public class TypeCheckerTest {

	@Test
	public void testBinaryOp() {
		testBinaryOp("");
		testBinaryOp("u8* prev = ptr1 + 1;");
		testBinaryOp("u8* prev = ptr1 - 2;");
		testBinaryOp("u8 cmp = ptr1 == ptr2;");
		testIllegalBinaryOp("u8  diff = ptr1 - ptr2;");
		testIllegalBinaryOp("u8  prev = ptr1 - 1;");
		testIllegalBinaryOp("u8* prev = ptr1 * 1;");
		testIllegalBinaryOp("u8* prev = ptr1 / 1;");
		testIllegalBinaryOp("u8 cmp = ptr1 < ptr2;");
		testIllegalBinaryOp("u8 cmp = ptr1 <= ptr2;");
		testIllegalBinaryOp("u8 cmp = ptr1 >= ptr2;");
		testIllegalBinaryOp("u8 cmp = ptr1 > ptr2;");
	}

	private void testIllegalBinaryOp(String illegalOperation) {
		try {
			testBinaryOp(illegalOperation);
			Assert.fail();
		}
		catch (SyntaxException ignored) {
		}
	}

	private void testBinaryOp(String illegalOperation) {
		final Program program = new Parser(new Lexer("""
				                                             u8 space = ' ';
				                                             u8* ptr1 = &space;
				                                             u8* ptr2 = &space;
				                                             void main() {
				                                                %s
				                                             }""".formatted(illegalOperation))).parse();
		new TypeChecker(Type.I64).check(program);
	}
}
