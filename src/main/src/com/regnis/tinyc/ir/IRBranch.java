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
		return toString(false);
	}

	@Override
	public String toString(boolean comment) {
		final StringBuilder buffer = new StringBuilder();
		buffer.append("branch ");
		buffer.append(conditionVar.toString(comment));
		buffer.append(", ");
		buffer.append(jumpOnTrue);
		buffer.append(", ");
		buffer.append(target);
		if (nextLabel.length() > 0) {
			buffer.append(", ");
			buffer.append(nextLabel);
		}
		return buffer.toString();
	}
}
