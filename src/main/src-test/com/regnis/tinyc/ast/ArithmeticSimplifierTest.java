package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;
import org.junit.*;

import static com.regnis.tinyc.ParserTest.loc;
import static org.junit.Assert.assertEquals;

/**
 * @author Thomas Singer
 */
public class ArithmeticSimplifierTest {

	@Test
	public void testUnary() {
		assertEquals(literal(~1, loc(3, 4)),
		             ArithmeticSimplifier.simplify(new ExprUnary(ExprUnary.Op.Com,
		                                                         literal(1),
		                                                         Type.I16, loc(3, 4))
		             )
		);
		assertEquals(literal(-2, loc(3, 4)),
		             ArithmeticSimplifier.simplify(new ExprUnary(ExprUnary.Op.Neg,
		                                                         literal(2),
		                                                         Type.I16, loc(3, 4))
		             )
		);
		assertEquals(new ExprBoolLiteral(true, loc(3, 4)),
		             ArithmeticSimplifier.simplify(new ExprUnary(ExprUnary.Op.NotLog,
		                                                         new ExprBoolLiteral(false, loc(1, 2)),
		                                                         Type.BOOL, loc(3, 4))
		             )
		);
	}

	@Test
	public void testBinaryAddOrXor() {
		for (ExprBinary.Op op : List.of(ExprBinary.Op.Add, ExprBinary.Op.Or, ExprBinary.Op.Xor)) {
			testSwapped(variable("a"), op, variable("a"), 0);
			assertEquals(new ExprBinary(op, Type.I16,
			                            variable("c"),
			                            literal(1),
			                            loc(3, 4)),
			             ArithmeticSimplifier.simplify(new ExprBinary(op, Type.I16,
			                                                          literal(1),
			                                                          variable("c"),
			                                                          loc(3, 4))));
		}

		assertEquals(literal(10, loc(3, 4)),
		             ArithmeticSimplifier.simplify(new ExprBinary(ExprBinary.Op.Add, Type.I16,
		                                                          literal(4),
		                                                          literal(6),
		                                                          loc(3, 4))));
		assertEquals(literal(6, loc(3, 4)),
		             ArithmeticSimplifier.simplify(new ExprBinary(ExprBinary.Op.Or, Type.I16,
		                                                          literal(4),
		                                                          literal(6),
		                                                          loc(3, 4))));
		assertEquals(literal(2, loc(3, 4)),
		             ArithmeticSimplifier.simplify(new ExprBinary(ExprBinary.Op.Xor, Type.I16,
		                                                          literal(4),
		                                                          literal(6),
		                                                          loc(3, 4))));
	}

	@Test
	public void testBinarySub() {
		final ExprBinary.Op op = ExprBinary.Op.Sub;
		assertEquals(variable("a"),
		             ArithmeticSimplifier.simplify(new ExprBinary(op, Type.I16,
		                                                          variable("a"),
		                                                          literal(0),
		                                                          loc(3, 4))));
		assertEquals(new ExprBinary(op, Type.I16,
		                            literal(0),
		                            variable("b"),
		                            loc(3, 4)),
		             ArithmeticSimplifier.simplify(new ExprBinary(op, Type.I16,
		                                                          literal(0),
		                                                          variable("b"),
		                                                          loc(3, 4))));
		assertEquals(literal(-1, loc(3, 4)),
		             ArithmeticSimplifier.simplify(new ExprBinary(op, Type.I16,
		                                                          literal(5),
		                                                          literal(6),
		                                                          loc(3, 4))));
	}

	@Test
	public void testBinaryAnd() {
		final ExprBinary.Op op = ExprBinary.Op.And;
		testSwapped(literal(0, loc(3, 4)), op,
		            variable("a"),
		            0);
		assertEquals(new ExprBinary(op, Type.I16,
		                            variable("b"),
		                            literal(1),
		                            loc(3, 4)),
		             ArithmeticSimplifier.simplify(new ExprBinary(op, Type.I16,
		                                                          literal(1),
		                                                          variable("b"),
		                                                          loc(3, 4))));
		assertEquals(literal(4, loc(3, 4)),
		             ArithmeticSimplifier.simplify(new ExprBinary(op, Type.I16,
		                                                          literal(5),
		                                                          literal(6),
		                                                          loc(3, 4))));
	}

	@Test
	public void testBinaryMultiply() {
		final ExprBinary.Op op = ExprBinary.Op.Multiply;
		testSwapped(literal(0, loc(3, 4)), op,
		            variable("a"),
		            0);
		testSwapped(variable("a"), op,
		            variable("a"),
		            1);
		testSwapped(new ExprUnary(ExprUnary.Op.Neg, variable("a"), Type.I16, loc(3, 4)), op,
		            variable("a"),
		            -1);
		testSwapped(new ExprBinary(ExprBinary.Op.ShiftLeft, Type.I16,
		                           variable("a"),
		                           literal(3),
		                           loc(3, 4)),
		            op,
		            variable("a"),
		            8);
		assertEquals(literal(10, loc(3, 4)),
		             ArithmeticSimplifier.simplify(new ExprBinary(op, Type.I16,
		                                                          literal(2),
		                                                          literal(5),
		                                                          loc(3, 4))));
	}

	@Test
	public void testBinaryDiv() {
		final ExprBinary.Op op = ExprBinary.Op.Divide;
		assertEquals(variable("a"),
		             ArithmeticSimplifier.simplify(new ExprBinary(op, Type.I16,
		                                                          variable("a"),
		                                                          literal(1),
		                                                          loc(3, 4))));
		assertEquals(new ExprBinary(ExprBinary.Op.ShiftRight, Type.I16,
		                            variable("b"),
		                            literal(1),
		                            loc(3, 4)),
		             ArithmeticSimplifier.simplify(new ExprBinary(op, Type.I16,
		                                                          variable("b"),
		                                                          literal(2),
		                                                          loc(3, 4))));
		assertEquals(literal(3, loc(3, 4)),
		             ArithmeticSimplifier.simplify(new ExprBinary(op, Type.I16,
		                                                          literal(10),
		                                                          literal(3),
		                                                          loc(3, 4))));
	}

	@Test
	public void testBinaryMod() {
		final ExprBinary.Op op = ExprBinary.Op.Mod;
		assertEquals(new ExprBinary(ExprBinary.Op.And, Type.I16,
		                            variable("b"),
		                            literal(15),
		                            loc(3, 4)),
		             ArithmeticSimplifier.simplify(new ExprBinary(op, Type.I16,
		                                                          variable("b"),
		                                                          literal(16),
		                                                          loc(3, 4))));
		assertEquals(literal(1, loc(3, 4)),
		             ArithmeticSimplifier.simplify(new ExprBinary(op, Type.I16,
		                                                          literal(10),
		                                                          literal(3),
		                                                          loc(3, 4))));
	}

	@Test
	public void testBinaryShiftLeft() {
		final ExprBinary.Op op = ExprBinary.Op.ShiftLeft;
		assertEquals(variable("a"),
		             ArithmeticSimplifier.simplify(new ExprBinary(op, Type.I16,
		                                                          variable("a"),
		                                                          literal(0),
		                                                          loc(3, 4))));
		assertEquals(literal(20, loc(3, 4)),
		             ArithmeticSimplifier.simplify(new ExprBinary(op, Type.I16,
		                                                          literal(5),
		                                                          literal(2),
		                                                          loc(3, 4))));
	}

	@Test
	public void testBinaryShiftRight() {
		final ExprBinary.Op op = ExprBinary.Op.ShiftRight;
		assertEquals(variable("a"),
		             ArithmeticSimplifier.simplify(new ExprBinary(op, Type.I16,
		                                                          variable("a"),
		                                                          literal(0),
		                                                          loc(3, 4))));
		assertEquals(literal(25, loc(3, 4)),
		             ArithmeticSimplifier.simplify(new ExprBinary(op, Type.I16,
		                                                          literal(100),
		                                                          literal(2),
		                                                          loc(3, 4))));
	}

	@Test
	public void testBinaryAssign() {
		final ExprBinary.Op op = ExprBinary.Op.Assign;
		assertEquals(new ExprBinary(op, Type.I16,
		                            variable("a"),
		                            literal(0),
		                            loc(3, 4)),
		             ArithmeticSimplifier.simplify(new ExprBinary(op, Type.I16,
		                                                          variable("a"),
		                                                          literal(0),
		                                                          loc(3, 4))));
	}

	@Test
	public void testBinaryRelation() {
		testBinaryRelation(ExprBinary.Op.Gt, ExprBinary.Op.Lt);
		testBinaryRelation(ExprBinary.Op.GtEq, ExprBinary.Op.LtEq);
		testBinaryRelation(ExprBinary.Op.Equals, ExprBinary.Op.Equals);
		testBinaryRelation(ExprBinary.Op.NotEquals, ExprBinary.Op.NotEquals);
		testBinaryRelation(ExprBinary.Op.LtEq, ExprBinary.Op.GtEq);
		testBinaryRelation(ExprBinary.Op.Lt, ExprBinary.Op.Gt);
	}

	private void testBinaryRelation(ExprBinary.Op expectedSwappedOp, ExprBinary.Op op) {
		final ExprVarAccess a = variable("a");
		// keep
		assertEquals(new ExprBinary(op, Type.BOOL,
		                            a,
		                            literal(0),
		                            loc(3, 4)),
		             ArithmeticSimplifier.simplify(new ExprBinary(op, Type.BOOL,
		                                                          a,
		                                                          literal(0),
		                                                          loc(3, 4))));
		// swap
		assertEquals(new ExprBinary(expectedSwappedOp, Type.BOOL,
		                            a,
		                            literal(0),
		                            loc(3, 4)),
		             ArithmeticSimplifier.simplify(new ExprBinary(op, Type.BOOL,
		                                                          literal(0),
		                                                          a,
		                                                          loc(3, 4))));
	}

	private static void testSwapped(Expression expectedResult, ExprBinary.Op op, ExprVarAccess expression, int literal) {
		assertEquals(expectedResult,
		             ArithmeticSimplifier.simplify(new ExprBinary(op, Type.I16,
		                                                          expression,
		                                                          literal(literal),
		                                                          loc(3, 4))));
		assertEquals(expectedResult,
		             ArithmeticSimplifier.simplify(new ExprBinary(op, Type.I16,
		                                                          literal(literal),
		                                                          expression,
		                                                          loc(3, 4))));
	}

	@NotNull
	private static ExprIntLiteral literal(int value) {
		return literal(value, loc(1, 2));
	}

	@NotNull
	private static ExprIntLiteral literal(int value, Location loc) {
		return new ExprIntLiteral(value, Type.I16, loc);
	}

	@NotNull
	private static ExprVarAccess variable(String name) {
		return variable(name, loc(5, 6));
	}

	@NotNull
	private static ExprVarAccess variable(String name, Location loc) {
		return new ExprVarAccess(name, 0, VariableScope.global, Type.I16, false, loc);
	}
}