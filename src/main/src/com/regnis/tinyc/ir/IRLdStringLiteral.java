package com.regnis.tinyc.ir;

/**
 * @author Thomas Singer
 */
public record IRLdStringLiteral(int addrReg, int literalIndex) implements IRInstruction {

	@Override
	public String toString() {
		return "load r" + addrReg + ", stringlit-" + literalIndex;
	}
}
