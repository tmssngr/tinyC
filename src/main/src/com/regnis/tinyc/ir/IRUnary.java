package com.regnis.tinyc.ir;

/**
 * @author Thomas Singer
 */
public record IRUnary(Op op, int valueReg, int size) implements IRInstruction {

	@Override
	public String toString() {
		return op.toString() + " r" + valueReg + " (" + size + ")";
	}

	public enum Op {
		not, notLog, neg
	}
}
