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
		final StringBuilder buffer = new StringBuilder();
		buffer.append("branch ");
		buffer.append(conditionVar);
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
