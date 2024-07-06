package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;

import org.junit.*;

/**
 * @author Thomas Singer
 */
public class TypeCheckerTest {

	@Test
	public void testAutoCast() {
		testStatement("sint16 = uint8;");
		testIllegalStatement(Messages.cantCastFromTo(Type.I16, Type.U8), 6,
		                     "uint8 = sint16;");
	}

	@Test
	public void testFunction() {
		testIllegal(Messages.functionAlreadDeclaredAt("foo", new Location(0, 0)), 1, 0,
		            """
				            void foo() {}
				            void foo() {}""");
		testIllegal(Messages.functionMustReturnType(Type.U8), 0, 0,
		            """
				            u8 foo() {
				            }""");
		testIllegal(Messages.returnExpectedExpressionOfType(Type.U8), 3, 4,
		            """
				            u8 a = 1;
				            u8 foo() {
				              if (a > 0)
				                return;
				            }""");
		testIllegal(Messages.cantReturnAnythingFromVoidFunction(), 3, 4,
		            """
				            u8 a = 1;
				            void foo() {
				              if (a > 0)
				                return a;
				            }""");
		testIllegal(Messages.undeclaredFunction("bar"), 1, 2,
		            """
				            void foo() {
				              bar();
				            }""");
		testIllegal(Messages.functionNeedsXArgumentsButGotY("bar", 2, 0), 2, 4,
		            """
				            void bar(u8 a, u8 b) {}
				            void foo() {
				                bar();
				            }""");
	}

	@Test
	public void testVariables() {
		testIllegal(Messages.variableHasAlreadyBeenDeclaredAt("foo", new Location(0, 0)), 1, 0,
		            """
				            u8 foo = 1;
				            i16 foo = 2;""");
		testIllegal(Messages.undeclaredVariable("bar"), 1, 2,
		            """
				            void foo() {
				              bar = 1;
				            }""");
	}

	@Test
	public void testType() {
		testIllegal(Messages.unknownType("xyz"), 1, 0,
		            """
				            u8 foo = 1;
				            xyz bar = 2;""");
	}

	@Test
	public void testPointerOps() {
		checkType("""
				          u8 a = 'a';
				          u8* b = &a;
				          u8 c = *b;""");
		testIllegal(Messages.expectedPointerButGot(Type.U8), 1, 7,
		            """
				            u8 a = 'a';
				            u8 c = *a;""");

		testStatement("");
		testStatement("u8* prev = ptr1 + 1;");
		testStatement("u8* prev = ptr1 - 2;");
		testStatement("u8 cmp = ptr1 == ptr2;");
		testIllegalStatement(Messages.operationNotSupportedForTypes(ExprBinary.Op.Sub, Type.pointer(Type.U8), Type.pointer(Type.U8)), 16,
		                     "u8  diff = ptr1 - ptr2;");
		testIllegalStatement(Messages.operationNotSupportedForTypes(ExprBinary.Op.Sub, Type.U8, Type.pointer(Type.U8)), 13,
		                     "u8  diff = 1 - ptr2;");
		testIllegalStatement(Messages.cantCastFromTo(Type.pointer(Type.U8), Type.U8), 0,
		                     "u8  prev = ptr1 - 1;");
		testIllegalStatement(Messages.operationNotSupportedForTypes(ExprBinary.Op.Multiply, Type.pointer(Type.U8), Type.U8), 16,
		                     "u8* prev = ptr1 * 1;");
		testIllegalStatement(Messages.operationNotSupportedForTypes(ExprBinary.Op.Divide, Type.pointer(Type.U8), Type.U8), 16,
		                     "u8* prev = ptr1 / 1;");
		testIllegalStatement(Messages.operationNotSupportedForTypes(ExprBinary.Op.Lt, Type.pointer(Type.U8), Type.pointer(Type.U8)), 14,
		                     "u8 cmp = ptr1 < ptr2;");
		testIllegalStatement(Messages.operationNotSupportedForTypes(ExprBinary.Op.LtEq, Type.pointer(Type.U8), Type.pointer(Type.U8)), 14,
		                     "u8 cmp = ptr1 <= ptr2;");
		testIllegalStatement(Messages.operationNotSupportedForTypes(ExprBinary.Op.GtEq, Type.pointer(Type.U8), Type.pointer(Type.U8)), 14,
		                     "u8 cmp = ptr1 >= ptr2;");
		testIllegalStatement(Messages.operationNotSupportedForTypes(ExprBinary.Op.Gt, Type.pointer(Type.U8), Type.pointer(Type.U8)), 14,
		                     "u8 cmp = ptr1 > ptr2;");
	}

	@Test
	public void testInvalidLValue() {
		testIllegalStatement(Messages.expectedLValue(), 0, "1 = ptr1;");
		testIllegalStatement(Messages.expectedLValue(), 5, "ptr1 + 1 = ptr2;");
	}

	private void testIllegalStatement(String expectedMessage, int column, String illegalOperation) {
		try {
			testStatement(illegalOperation);
			Assert.fail();
		}
		catch (SyntaxException ex) {
			Assert.assertEquals(new Location(6, column) + " " + expectedMessage, ex.toString());
		}
	}

	private void testStatement(String operation) {
		checkType("""
				          u8 space = ' ';
				          u8* ptr1 = &space;
				          u8* ptr2 = &space;
				          u8 uint8 = 1;
				          i16 sint16 = 300;
				          void main() {
				          %s
				          }""".formatted(operation));
	}

	private void testIllegal(String expectedMessage, int row, int column, String input) {
		try {
			checkType(input);
			Assert.fail();
		}
		catch (SyntaxException ex) {
			Assert.assertEquals(new Location(row, column) + " " + expectedMessage, ex.toString());
		}
	}

	private void checkType(String input) {
		final Program program = new Parser(new Lexer(input)).parse();
		new TypeChecker(Type.I64).check(program);
	}
}
