package com.regnis.tinyc.ir;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRBranch(@NotNull IRVar conditionVar, boolean jumpOnTrue, @NotNull String target,
                       @NotNull String nextLabel) implements IRInstruction {
	@NotNull
	@Override
	public String toString() {
		return toString(false);
	}

	@Override
	public String toString(boolean comment) {
		return "branch " + conditionVar.toString(comment) + ", " + jumpOnTrue + ", " + target;
	}
}
