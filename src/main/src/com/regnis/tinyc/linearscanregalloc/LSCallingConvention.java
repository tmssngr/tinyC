package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;

/**
 * @author Thomas Singer
 */
public record LSCallingConvention(int argRegisterCount, int otherVolatileRegisterCount) {

	public LSCallingConvention {
		Utils.assertTrue(argRegisterCount > 0);
		Utils.assertTrue(otherVolatileRegisterCount >= 0);
	}

	public int firstArgRegister() {
		return 1;
	}

	public int volatileRegisterCount() {
		return 1 + argRegisterCount + otherVolatileRegisterCount;
	}
}
