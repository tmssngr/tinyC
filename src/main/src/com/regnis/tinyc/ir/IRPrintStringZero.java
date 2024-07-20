package com.regnis.tinyc.ir;

/**
 * @author Thomas Singer
 */
public record IRPrintStringZero(int addrReg) implements IRInstruction {
	@Override
	public String toString() {
		return "printStringZero r" + addrReg;
	}
}
