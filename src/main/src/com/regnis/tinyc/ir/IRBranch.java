package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRBranch(@NotNull IRVar conditionVar, boolean jumpOnTrue, @NotNull String target,
                       @NotNull String nextLabel) implements IRInstruction {
	public IRBranch {
		Utils.assertTrue(nextLabel.length() > 0);
	}

	@NotNull
	@Override
	public String toString() {
		return "branch " + conditionVar + ", " + jumpOnTrue + ", " + target;
	}
}
