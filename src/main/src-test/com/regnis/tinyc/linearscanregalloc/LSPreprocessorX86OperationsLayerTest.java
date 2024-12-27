package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.junit.*;

/**
 * @author Thomas Singer
 */
public class LSPreprocessorX86OperationsLayerTest {

	@Test
	public void testX86DivMod() {
		testX86DivMod(IRBinary.Op.Div, 0);
		testX86DivMod(IRBinary.Op.Mod, 2);
	}

	@Test
	public void testShift() {
		final IRVar varPattern = new IRVar("pattern", 1, VariableScope.function, Type.I16);
		final IRVar varT31 = new IRVar("t31", 2, VariableScope.function, Type.I16);
		final IRVar varT32 = new IRVar("t32", 3, VariableScope.function, Type.I16);

		check(List.of(
				new IRLiteral(varT32, 1, Location.DUMMY),
				new IRMove(varT31, varPattern, Location.DUMMY),
				new IRMove(varT32.asRegister(1), varT32, Location.DUMMY),
				new IRBinary(varT31, IRBinary.Op.ShiftLeft, varT31, varT32.asRegister(1), Location.DUMMY)
		), List.of(
				new IRLiteral(varT32, 1, Location.DUMMY),
				new IRMove(varT31, varPattern, Location.DUMMY),
				new IRBinary(varT31, IRBinary.Op.ShiftLeft, varT31, varT32, Location.DUMMY)
		));
	}

	private void testX86DivMod(IRBinary.Op op, int expectedOutputReg) {
		final IRVar varT6 = new IRVar("t6", 4, VariableScope.function, Type.I64);
		final IRVar varRemainder = new IRVar("remainder", 5, VariableScope.function, Type.I64);
		final IRVar varNumber = new IRVar("number", 6, VariableScope.function, Type.I64);

		check(List.of(
				      new IRLiteral(varT6, 10, Location.DUMMY),
				      new IRMove(varRemainder, varNumber, Location.DUMMY),
				      new IRMove(varRemainder.asRegister(0), varRemainder, Location.DUMMY),
				      new IRBinary(varRemainder.asRegister(expectedOutputReg), op, varRemainder.asRegister(0), varT6, Location.DUMMY),
				      new IRMove(varRemainder, varRemainder.asRegister(expectedOutputReg), Location.DUMMY)
		      ),
		      List.of(
				      new IRLiteral(varT6, 10, Location.DUMMY),
				      new IRMove(varRemainder, varNumber, Location.DUMMY),
				      new IRBinary(varRemainder, op, varRemainder, varT6, Location.DUMMY)
		      ));
	}

	private static void check(List<IRInstruction> expectedOutput, List<IRInstruction> input) {
		final LSPreprocessorResultLayer resultLayer = new LSPreprocessorResultLayer();
		LSPreprocessorLayer.process(new LSPreprocessorX86OperationsLayer(resultLayer),
		                            input);
		IRTestUtils.assertEqualsInstructions(expectedOutput, resultLayer.instructions);
	}
}