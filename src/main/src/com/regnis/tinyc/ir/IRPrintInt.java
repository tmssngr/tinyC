package com.regnis.tinyc.ir;

/**
 * @author Thomas Singer
 */
public record IRPrintInt(int reg) implements IRInstruction {
	@Override
	public String toString() {
		return "printint r" + reg;
	}
}
