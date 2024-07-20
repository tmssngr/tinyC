package com.regnis.tinyc.ir;

/**
 * @author Thomas Singer
 */
public record IRStore(int addrReg, int valueReg, int size) implements IRInstruction {
	@Override
	public String toString() {
		return "store [r" + addrReg + "], r" + valueReg + " (" + size + ")";
	}
}
