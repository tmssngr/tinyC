package com.regnis.tinyc.ir;

/**
 * @author Thomas Singer
 */
public record IRJump(String target) implements IRInstruction {
	@Override
	public String toString() {
		return "jmp " + target;
	}
}
