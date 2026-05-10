package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRAddConst(IRVar var, int offset) implements IRInstruction {

	public IRAddConst {
		Utils.assertTrue(offset != 0);
	}

	@NotNull
	@Override
	public String toString() {
		return toString(false);
	}

	@Override
	public String toString(boolean comment) {
		final String varString = var.toString(comment);
		if (offset > 0) {
			return offset == 1
					? "inc " + varString
					: "add " + varString + ", " + offset;
		}

		return offset == -1
				? "dec " + varString
				: "sub " + varString + ", " + (-offset);
	}
}
