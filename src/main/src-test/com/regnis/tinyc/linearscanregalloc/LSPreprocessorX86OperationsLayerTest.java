package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.junit.*;

import static org.junit.Assert.*;

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

		final IRConverterResultLayer resultLayer = new IRConverterResultLayer();
		IRConverterLayer.process(new LSPreprocessorX86OperationsLayer(X86Registers.WINDOWS, resultLayer),
		                         List.of(
				                         new IRMove(varT32, 1),
				                         new IRMove(varT31, varPattern),
				                         new IRBinary(varT31, IRBinary.Op.ShiftLeft, varT31, varT32)
		                         ));
		final Iterator<IRInstruction> i = resultLayer.instructions.iterator();
		assertEquals(new IRMove(varT32, 1), i.next());
		assertEquals(new IRMove(varT31, varPattern), i.next());
		assertEquals(new IRMove(varT32.asRegister(1), varT32), i.next());
		assertEquals(new IRBinary(varT31, IRBinary.Op.ShiftLeft, varT31, varT32.asRegister(1)), i.next());
		assertFalse(i.hasNext());
	}

	private void testX86DivMod(IRBinary.Op op, int expectedOutputReg) {
		final IRVar varT6 = new IRVar("t6", 4, VariableScope.function, Type.I64);
		final IRVar varRemainder = new IRVar("remainder", 5, VariableScope.function, Type.I64);
		final IRVar varNumber = new IRVar("number", 6, VariableScope.function, Type.I64);

		final IRConverterResultLayer resultLayer = new IRConverterResultLayer();
		IRConverterLayer.process(new LSPreprocessorX86OperationsLayer(X86Registers.WINDOWS, resultLayer),
		                         List.of(
				                         new IRMove(varT6, 10),
				                         new IRMove(varRemainder, varNumber),
				                         new IRBinary(varRemainder, op, varRemainder, varT6)
		                         ));
		final Iterator<IRInstruction> i = resultLayer.instructions.iterator();
		assertEquals(new IRMove(varT6, 10), i.next());
		assertEquals(new IRMove(varRemainder, varNumber), i.next());
		assertEquals(new IRMove(varRemainder.asRegister(0), varRemainder), i.next());
		assertEquals(new IRBinary(varRemainder.asRegister(expectedOutputReg), op, varRemainder.asRegister(0), varT6), i.next());
		assertEquals(new IRMove(varRemainder, varRemainder.asRegister(expectedOutputReg)), i.next());
		assertFalse(i.hasNext());
	}
}
