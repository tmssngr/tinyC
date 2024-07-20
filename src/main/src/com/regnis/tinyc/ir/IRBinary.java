package com.regnis.tinyc.ir;

import com.regnis.tinyc.ast.*;

/**
 * @author Thomas Singer
 */
public record IRBinary(ExprBinary.Op op, int targetReg, int sourceReg, int size) implements IRInstruction {
	public IRBinary(ExprBinary.Op op, int valueReg, int sourceReg) {
		this(op, valueReg, sourceReg, 0);
	}

	@Override
	public String toString() {
		return "binary" + op + " r" + targetReg + ", r" + sourceReg + " (" + size + ")";
	}
}
