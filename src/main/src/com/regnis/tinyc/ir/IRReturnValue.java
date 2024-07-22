package com.regnis.tinyc.ir;

/**
 * @author Thomas Singer
 */
public record IRReturnValue(int reg, int size) implements IRInstruction {
	@Override
	public String toString() {
		return "return r" + reg + " (" + size + ")";
	}
}
