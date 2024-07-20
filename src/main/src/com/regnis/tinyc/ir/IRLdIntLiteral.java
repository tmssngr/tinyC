package com.regnis.tinyc.ir;

/**
 * @author Thomas Singer
 */
public record IRLdIntLiteral(int valueReg, int constant, int size) implements IRInstruction {
	@Override
	public String toString() {
		return "ld r" + valueReg + ", " + constant + " (" + size + ")";
	}
}
