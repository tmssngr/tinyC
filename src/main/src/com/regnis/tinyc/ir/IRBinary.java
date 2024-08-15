package com.regnis.tinyc.ir;

import com.regnis.tinyc.ast.*;

import java.util.*;

/**
 * @author Thomas Singer
 */
public record IRBinary(Op op, int targetReg, int sourceReg, Type type) implements IRInstruction {
	@Override
	public String toString() {
		return op.toString().toLowerCase(Locale.ROOT) + " r" + targetReg + ", r" + sourceReg + " (" + type + ")";
	}

	public enum Op {
		Sub, Mul, Div, Mod, And, Or, Xor, Add
	}
}
