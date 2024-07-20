package com.regnis.tinyc.ir;

/**
 * @author Thomas Singer
 */
public record IRBranch(int conditionReg, boolean jumpOnTrue, String label) implements IRInstruction {
	@Override
	public String toString() {
		return "branch-" + jumpOnTrue + " r" + conditionReg + ", " + label;
	}
}
