package com.regnis.tinyc.ast;

import org.junit.*;

import static com.regnis.tinyc.ParserTest.loc;
import static org.junit.Assert.assertEquals;

/**
 * @author Thomas Singer
 */
public class ArithmeticSimplifierTest {

	@Test
	public void testUnary() {
		assertEquals(new ExprIntLiteral(~1, Type.I16, loc(3, 4)),
		             ArithmeticSimplifier.simplify(new ExprUnary(ExprUnary.Op.Com,
		                                                         new ExprIntLiteral(1, Type.I16, loc(1, 2)),
		                                                         Type.I16, loc(3, 4))
		             )
		);
		assertEquals(new ExprIntLiteral(-2, Type.I16, loc(3, 4)),
		             ArithmeticSimplifier.simplify(new ExprUnary(ExprUnary.Op.Neg,
		                                                         new ExprIntLiteral(2, Type.I16, loc(1, 2)),
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
}