package com.regnis.tinyc.ir;

/**
 * @author Thomas Singer
 */
public record IRCopy(int targetReg, int sourceReg, int size) implements IRInstruction {
	@Override
	public String toString() {
		return "ld r" + targetReg + ", r" + sourceReg;
	}
}
