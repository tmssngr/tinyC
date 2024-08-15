package com.regnis.tinyc.ir;

/**
 * @author Thomas Singer
 */
public record IRBranch(int conditionReg, boolean jumpOnTrue, String target, String nextLabel) implements IRInstruction {
	@Override
	public String toString() {
		return "branch-" + jumpOnTrue + " r" + conditionReg + ", " + target + " (else: " + nextLabel + ")";
	}
}
