package com.regnis.tinyc.ir;

/**
 * @author Thomas Singer
 */
public record IRMul(int reg, int factor) implements IRInstruction {
	@Override
	public String toString() {
		return "mul r" + reg + ", " + factor;
	}
}
