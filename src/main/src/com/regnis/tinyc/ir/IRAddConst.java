package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

/**
 * @author Thomas Singer
 */
public record IRAddConst(IRVar var, int offset) implements IRInstruction {

	public IRAddConst {
		Utils.assertTrue(offset != 0);
	}

	@Override
	public String toString() {
		if (offset > 0) {
			return offset == 1
					? "inc " + var
					: "add " + var + ", " + offset;
		}

		return offset == -1
				? "dec " + var
				: "sub " + var + ", " + (-offset);
	}
}
