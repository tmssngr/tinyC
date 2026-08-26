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
				new IRLiteral(varT32, 1),
				new IRMove(varT31, varPattern),
				new IRMove(varT32.asRegister(1), varT32),
				new IRBinary(varT31, IRBinary.Op.ShiftLeft, varT31, varT32.asRegister(1))
		), List.of(
				new IRLiteral(varT32, 1),
				new IRMove(varT31, varPattern),
				new IRBinary(varT31, IRBinary.Op.ShiftLeft, varT31, varT32)
		));
	}

	private void testX86DivMod(IRBinary.Op op, int expectedOutputReg) {
		final IRVar varT6 = new IRVar("t6", 4, VariableScope.function, Type.I64);
		final IRVar varRemainder = new IRVar("remainder", 5, VariableScope.function, Type.I64);
		final IRVar varNumber = new IRVar("number", 6, VariableScope.function, Type.I64);

		check(List.of(
				      new IRLiteral(varT6, 10),
				      new IRMove(varRemainder, varNumber),
				      new IRMove(varRemainder.asRegister(0), varRemainder),
				      new IRBinary(varRemainder.asRegister(expectedOutputReg), op, varRemainder.asRegister(0), varT6),
				      new IRMove(varRemainder, varRemainder.asRegister(expectedOutputReg))
		      ),
		      List.of(
				      new IRLiteral(varT6, 10),
				      new IRMove(varRemainder, varNumber),
				      new IRBinary(varRemainder, op, varRemainder, varT6)
		      ));
	}

	private static void check(List<IRInstruction> expectedOutput, List<IRInstruction> input) {
		final LSPreprocessorResultLayer resultLayer = new LSPreprocessorResultLayer();
		LSPreprocessorLayer.process(new LSPreprocessorX86OperationsLayer(X86Registers.WINDOWS, resultLayer),
		                            input);
		IRTestUtils.assertEqualsInstructions(expectedOutput, resultLayer.instructions);
	}
}