package com.regnis.tinyc.ir;

import com.regnis.tinyc.ast.*;

/**
 * @author Thomas Singer
 */
public record IRCompare(ExprBinary.Op op, int resultReg, int leftReg, int rightReg, Type type) implements IRInstruction {
	@Override
	public String toString() {
		return "cmp r" + resultReg + ", (r" + leftReg + " " + op + " r" + rightReg + ") (" + type + ")";
	}
}
