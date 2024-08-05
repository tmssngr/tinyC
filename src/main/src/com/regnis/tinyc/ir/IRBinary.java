package com.regnis.tinyc.ir;

import java.util.*;

/**
 * @author Thomas Singer
 */
public record IRBinary(Op op, int targetReg, int sourceReg, int size) implements IRInstruction {
	public IRBinary(Op op, int valueReg, int sourceReg) {
		this(op, valueReg, sourceReg, 0);
	}

	@Override
	public String toString() {
		return op.toString().toLowerCase(Locale.ROOT) + " r" + targetReg + ", r" + sourceReg + " (" + size + ")";
	}

	public enum Op {
		Sub, Mul, Div, And, Or, Xor, Add
	}
}
