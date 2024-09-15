package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;
import org.junit.*;

import static com.regnis.tinyc.ParserTest.*;

/**
 * @author Thomas Singer
 */
public class TypeCheckerTest {

	@Test
	public void testNeg() {
		testIllegal(Messages.expectedIntegerExpression(), 2, 10,
		            """
				            void main() {
				              bool a = true;
				              u8 b = -a;
				            }""");
	}

	@Test
	public void testAutoCast() {
		testStatement("sint16 = uint8;");
		testIllegalStatement(Messages.needExplicitCast(Type.I16, Type.U8), 6,
		                     "uint8 = sint16;");
	}

	@Test
	public void testFunction() {
		testIllegal(Messages.functionAlreadDeclaredAt("foo", loc(0, 0)), 1, 0,
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
		testIllegal(Messages.duplicateArgumentName("a"), 0, 15,
		            // 234567890123456789012
		            "void bar(u8 a, u8 a) {}");
	}

	@Test
	public void testVariables() {
		testIllegal(Messages.variableAlreadyDeclaredAt("foo", loc(0, 0)), 1, 0,
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
		checkType("""
				          u8   a = 'a';
				          u8*  b = &a;
				          u8** c = &b;
				          u8   d = **c;""");
		checkType("""
				          void main() {
				            u8 a = 'a';
				            u8* b = &a;
				            *b = 'b';
				          }""");
		testIllegal(Messages.expectedPointerButGot(Type.U8), 1, 7,
		            """
				            u8 a = 'a';
				            u8 c = *a;""");

		testStatement("");
		testStatement("u8* prev = ptr1 + 1;");
		testStatement("u8* prev = ptr1 - 2;");
		testStatement("bool cmp = ptr1 == ptr2;");
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
		testIllegal(Messages.arraysAreImmutable(), 2, 2,
		            """
				            u8 array[12];
				            void main() {
				              array = 1;
				            }""");
	}

	@Test
	public void testAddrOf() {
		testIllegal(Messages.expectedAddressableObject(), 1, 13,
		            """
				            void main() {
				              u8* foo = &1;
				            }""");
	}

	@Test
	public void testIf() {
		testIllegal(Messages.expectedBoolExpression(), 1, 6,
		            """
				            void main() {
				              if (1) {
				              }
				            }""");
	}

	@Test
	public void testWhile() {
		testIllegal(Messages.expectedExpression(), 1, 8,
		            """
				            void foo() {
				              while() {
				              };
				            }""");

		testIllegal(Messages.expectedBoolExpression(), 1, 9,
		            """
				            void main() {
				              while (1) {
				              }
				            }""");
	}

	@Test
	public void testArrays() {
		assertEquals(new Program(List.of(), List.of(),
		                         List.of(
				                         Function.typedInstance("main", "void", Type.VOID, List.of(),
				                                                List.of(
						                                                new Variable("first", 0, VariableScope.function, Type.U8, 0, loc(2, 2)),
						                                                new Variable("second", 1, VariableScope.function, Type.pointer(Type.U8), 0, loc(5, 2)),
						                                                new Variable("s", 2, VariableScope.function, Type.U8, 0, loc(6, 2))
				                                                ),
				                                                List.of(
						                                                assign("first", 0, VariableScope.function, Type.U8,
						                                                       new ExprArrayAccess(new ExprVarAccess("array", 0, VariableScope.global, Type.pointer(Type.U8), true, loc(2, 13)),
						                                                                           Type.U8,
						                                                                           new ExprIntLiteral(0, Type.I64, loc(2, 19))),
						                                                       loc(2, 2)),
						                                                new StmtExpr(new ExprBinary(ExprBinary.Op.Assign,
						                                                                            Type.U8,
						                                                                            new ExprArrayAccess(new ExprVarAccess("array", 0, VariableScope.global, Type.pointer(Type.U8), true, loc(3, 2)),
						                                                                                                Type.U8,
						                                                                                                new ExprIntLiteral(0, Type.I64, loc(3, 8))),
						                                                                            new ExprArrayAccess(new ExprVarAccess("array", 0, VariableScope.global, Type.pointer(Type.U8), true, loc(3, 13)),
						                                                                                                Type.U8,
						                                                                                                new ExprIntLiteral(1, Type.I64, loc(3, 19))),
						                                                                            loc(3, 11))),
						                                                new StmtExpr(new ExprBinary(ExprBinary.Op.Assign,
						                                                                            Type.U8,
						                                                                            new ExprArrayAccess(new ExprVarAccess("array", 0, VariableScope.global, Type.pointer(Type.U8), true, loc(4, 2)),
						                                                                                                Type.U8,
						                                                                                                new ExprIntLiteral(1, Type.I64, loc(4, 8))),
						                                                                            new ExprVarAccess("first", 0, VariableScope.function, Type.U8, false, loc(4, 13)),
						                                                                            loc(4, 11))),
						                                                assign("second", 1, VariableScope.function, Type.pointer(Type.U8),
						                                                       new ExprUnary(ExprUnary.Op.AddrOf,
						                                                                     new ExprArrayAccess(new ExprVarAccess("array", 0, VariableScope.global, Type.pointer(Type.U8), true, loc(5, 16)),
						                                                                                         Type.U8,
						                                                                                         new ExprIntLiteral(1, Type.I64, loc(5, 22))),
						                                                                     Type.pointer(Type.U8),
						                                                                     loc(5, 15)),
						                                                       loc(5, 2)),
						                                                assign("s", 2, VariableScope.function, Type.U8,
						                                                       new ExprArrayAccess(new ExprVarAccess("second", 1, VariableScope.function, Type.pointer(Type.U8), false, loc(6, 9)),
						                                                                           Type.U8,
						                                                                           new ExprIntLiteral(0, Type.I64, loc(6, 16))),
						                                                       loc(6, 2))
				                                                ),
				                                                List.of(), loc(1, 0))
		                         ),
		                         List.of(
				                         new Variable("array", 0, VariableScope.global, Type.pointer(Type.U8), 2, loc(0, 0))
		                         ),
		                         List.of()
		             ),
		             checkType("""
				                       u8 array[2];
				                       void main() {
				                         u8 first = array[0];
				                         array[0] = array[1];
				                         array[1] = first;
				                         u8* second = &array[1];
				                         u8 s = second[0];
				                       }"""));

		testIllegal(Messages.arraysAreImmutable(), 2, 2,
		            """
				            u8 array[12];
				            void main() {
				              array = 1;
				            }""");
		testIllegal(Messages.addressOfArray(), 2, 12,
		            """
				            u8 array[12];
				            void main() {
				              u8* foo = &array;
				            }""");
		testIllegal(Messages.arrayIndexMustBeInt(), 3, 8,
		            """
				            u8 array[12];
				            void main() {
				              u8* foo = array;
				              array[foo] = 1;
				            }""");
	}

	@Test
	public void testFlattenNestedCompounds() {
		assertEquals(new Program(List.of(), List.of(),
		                         List.of(
				                         Function.typedInstance("main", "void", Type.VOID, List.of(),
				                                                List.of(
						                                                new Variable("x", 0, VariableScope.function, Type.U8, 0, loc(2, 4))
				                                                ),
				                                                List.of(
						                                                assign("x", 0, VariableScope.function, Type.U8,
						                                                       new ExprIntLiteral(0, Type.U8, loc(2, 11)),
						                                                       loc(2, 4))
				                                                ), List.of(), loc(0, 0))),
		                         List.of(),
		                         List.of()),
		             checkType("""
				                       void main() {
				                         {
				                           u8 x = 0;
				                         }
				                       }
				                       """));
	}

	@Test
	public void testLocalVars() {
		assertEquals(new Program(List.of(), List.of(),
		                         List.of(
				                         Function.typedInstance("main", "void", Type.VOID, List.of(),
				                                                List.of(
						                                                new Variable("a", 0, VariableScope.function, Type.U8, 0, loc(1, 2))
				                                                ),
				                                                List.of(
						                                                assign("a", 0, VariableScope.function, Type.U8,
						                                                       new ExprIntLiteral(10,
						                                                                          Type.U8,
						                                                                          loc(1, 9)),
						                                                       loc(1, 2)),
						                                                new StmtExpr(
								                                                new ExprFuncCall("prInt", Type.VOID,
								                                                                 List.of(
										                                                                 ExprCast.autocast(new ExprVarAccess("a", 0, VariableScope.function, Type.U8, false, loc(2, 8)),
										                                                                                   Type.I64)
								                                                                 ), loc(2, 2))
						                                                )
				                                                ),
				                                                List.of(), loc(0, 0)),
				                         Function.typedInstance("foo", "void", Type.VOID, List.of(),
				                                                List.of(
						                                                new Variable("a", 0, VariableScope.function, Type.U8, 0, loc(6, 2))
				                                                ),
				                                                List.of(
						                                                assign("a", 0, VariableScope.function, Type.U8,
						                                                       new ExprIntLiteral(20,
						                                                                          Type.U8,
						                                                                          loc(6, 9)),
						                                                       loc(6, 2)),
						                                                new StmtExpr(
								                                                new ExprFuncCall("prInt", Type.VOID, List.of(
										                                                ExprCast.autocast(new ExprVarAccess("a", 0, VariableScope.function, Type.U8, false, loc(7, 8)),
										                                                                  Type.I64)
								                                                ), loc(7, 2))
						                                                )
				                                                ),
				                                                List.of(), loc(5, 0)),
				                         Function.typedInstance("prInt", "void", Type.VOID, List.of(
						                                                new Function.Arg("i64", Type.I64, "x", loc(10, 11))
				                                                ),
				                                                List.of(
						                                                new Variable("x", 0, VariableScope.argument, Type.I64, 0, loc(10, 11))
				                                                ),
				                                                List.of(), List.of(), loc(10, 0))
		                         ),
		                         List.of(), List.of()
		             ),
		             checkType("""
				                       void main() {
				                         u8 a = 10;
				                         prInt(a);
				                       }

				                       void foo() {
				                         u8 a = 20;
				                         prInt(a);
				                       }

				                       void prInt(i64 x) {}
				                       """));

		assertEquals(new Program(List.of(), List.of(),
		                         List.of(
				                         Function.typedInstance("main", "void", Type.VOID, List.of(),
				                                                List.of(
						                                                new Variable("a", 0, VariableScope.function, Type.U8, 0, loc(1, 2)),
						                                                new Variable("b", 1, VariableScope.function, Type.U8, 0, loc(3, 4)),
						                                                new Variable("b", 2, VariableScope.function, Type.I16, 0, loc(7, 4))
				                                                ),
				                                                List.of(
						                                                assign("a", 0, VariableScope.function, Type.U8,
						                                                       new ExprIntLiteral(10,
						                                                                          Type.U8,
						                                                                          loc(1, 9)),
						                                                       loc(1, 2)),
						                                                new StmtIf(new ExprBinary(ExprBinary.Op.Gt, Type.BOOL,
						                                                                          new ExprVarAccess("a", 0, VariableScope.function, Type.U8, false, loc(2, 6)),
						                                                                          new ExprIntLiteral(0, loc(2, 10)),
						                                                                          loc(2, 8)),
						                                                           List.of(
								                                                           assign("b", 1, VariableScope.function, Type.U8,
								                                                                  new ExprIntLiteral(1, Type.U8, loc(3, 11)),
								                                                                  loc(3, 4)),
								                                                           new StmtExpr(
										                                                           new ExprFuncCall("prInt", Type.VOID,
										                                                                            List.of(
												                                                                            ExprCast.autocast(new ExprVarAccess("b", 1, VariableScope.function, Type.U8, false, loc(4, 10)),
												                                                                                              Type.I64)
										                                                                            ), loc(4, 4))
								                                                           )
						                                                           ),
						                                                           List.of(
								                                                           assign("b", 2, VariableScope.function, Type.I16,
								                                                                  new ExprIntLiteral(2, Type.I16, loc(7, 12)),
								                                                                  loc(7, 4)),
								                                                           new StmtExpr(
										                                                           new ExprFuncCall("prInt", Type.VOID,
										                                                                            List.of(
												                                                                            ExprCast.autocast(new ExprVarAccess("b", 2, VariableScope.function, Type.I16, false, loc(8, 10)),
												                                                                                              Type.I64)
										                                                                            ), loc(8, 4))
								                                                           )
						                                                           ),
						                                                           loc(2, 2))
				                                                ),
				                                                List.of(), loc(0, 0)),
				                         Function.typedInstance("prInt", "void", Type.VOID, List.of(
						                                                new Function.Arg("i64", Type.I64, "x", loc(12, 11))
				                                                ),
				                                                List.of(
						                                                new Variable("x", 0, VariableScope.argument, Type.I64, 0, loc(12, 11))
				                                                ),
				                                                List.of(), List.of(), loc(12, 0))
		                         ),
		                         List.of(), List.of()
		             ),
		             checkType("""
				                       void main() {
				                         u8 a = 10;
				                         if (a > 0) {
				                           u8 b = 1;
				                           prInt(b);
				                         }
				                         else {
				                           i16 b = 2;
				                           prInt(b);
				                         }
				                       }

				                       void prInt(i64 x) {}"""));
	}

	@Test
	public void testMemberAccess() {
		testIllegal(Messages.cantRedefineDefaultTypes(), 0, 0,
		            "typedef u8 (u8 x);");
		testIllegal(Messages.memberAlreadyDefinedAt("x", loc(0, 13)), 0, 19,
		            "typedef Foo (u8 x, u8 x);");
		testIllegal(Messages.typeAlreadyDefined("Foo", loc(0, 0)), 1, 0,
		            """
				            typedef Foo (u8 x);
				            typedef Foo (u8 y);
				            """);
		testIllegal(Messages.unknownType("Foo"), 0, 0,
		            "Foo foo = 1;");
		testIllegal(Messages.structDoesNotHaveMember("Foo", "y"), 4, 10,
		            """
				            typedef Foo (u8 x);

				            void bla() {
				              Foo foos[10];
				              foos[0].y = foos[0].y + 1;
				            }""");
		assertEquals(new Program(List.of(
				             new TypeDef("Foo", Type.struct("Foo"), List.of(
						             new TypeDef.Part("x", "u8", Type.U8, loc(0, 13)),
						             new TypeDef.Part("y", "u8", Type.U8, loc(0, 19))
				             ), loc(0, 0))
		             ),
		                         List.of(),
		                         List.of(
				                         Function.typedInstance("bla", "void", Type.VOID, List.of(),
				                                                List.of(
						                                                new Variable("foos", 0, VariableScope.function, Type.pointer(Type.struct("Foo")), 10, loc(3, 2))
				                                                ),
				                                                List.of(
						                                                new StmtExpr(new ExprBinary(ExprBinary.Op.Assign,
						                                                                            Type.U8,
						                                                                            new ExprMemberAccess(new ExprArrayAccess(new ExprVarAccess("foos", 0, VariableScope.function, Type.pointer(Type.struct("Foo")), true, loc(4, 2)),
						                                                                                                                     Type.struct("Foo"),
						                                                                                                                     new ExprIntLiteral(0, Type.I64, loc(4, 7))),
						                                                                                                 "x",
						                                                                                                 Type.U8,
						                                                                                                 loc(4, 10)),
						                                                                            new ExprIntLiteral(1, Type.U8, loc(4, 14)),
						                                                                            loc(4, 12)))
				                                                ),
				                                                List.of(), loc(2, 0))
		                         ),
		                         List.of(),
		                         List.of()
		             ),
		             checkType("""
				                       typedef Foo (u8 x, u8 y);

				                       void bla() {
				                         Foo foos[10];
				                         foos[0].x = 1;
				                       }"""));

		testIllegal(Messages.expectedStruct("u8"), 2, 11,
		            """
				            void main() {
				              u8 i = 0;
				              u8 b = i.a;
				            }""");
	}

	private void testIllegalStatement(String expectedMessage, int column, String illegalOperation) {
		try {
			testStatement(illegalOperation);
			Assert.fail();
		}
		catch (SyntaxException ex) {
			Assert.assertEquals(loc(6, column) + " " + expectedMessage, ex.toString());
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
			Assert.fail("no exception thrown");
		}
		catch (SyntaxException ex) {
			Assert.assertEquals(loc(row, column) + " " + expectedMessage, ex.toString());
		}
	}

	@NotNull
	private Program checkType(String input) {
		final Program program = Parser.parse(input, Set.of());
		final TypeChecker checker = new TypeChecker(Type.I64);
		return checker.check(program);
	}

	@NotNull
	private static Statement assign(String varName, int index, VariableScope scope, Type type, Expression expression, Location location) {
		return new StmtExpr(new ExprBinary(ExprBinary.Op.Assign,
		                                   type,
		                                   new ExprVarAccess(varName, index, scope, type, false, location),
		                                   expression,
		                                   location));
	}
}
