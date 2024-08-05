package com.regnis.tinyc.ir;

/**
 * @author Thomas Singer
 */
public record IRMemStore(int addrReg, int valueReg, int size) implements IRInstruction {
	@Override
	public String toString() {
		return "store [r" + addrReg + "], r" + valueReg + " (" + size + ")";
	}
}
