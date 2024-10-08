package com.regnis.tinyc.ir;

/**
 * @author Thomas Singer
 */
public record IRMemLoad(int valueReg, int addrReg, int size) implements IRInstruction {
	public IRMemLoad(int valueReg, int addrReg) {
		this(valueReg, addrReg, 0);
	}

	@Override
	public String toString() {
		return "load r" + valueReg + ", [r" + addrReg + "] (" + size + ")";
	}
}
