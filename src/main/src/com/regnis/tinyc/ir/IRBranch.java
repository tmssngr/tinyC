package com.regnis.tinyc.ir;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRBranch(@NotNull IRVar conditionVar, boolean jumpOnTrue, @NotNull String target,
                       @NotNull String nextLabel) implements IRInstruction {
	@Override
	public String toString() {
		return "branch " + conditionVar + ", " + jumpOnTrue + ", " + target;
	}
}
