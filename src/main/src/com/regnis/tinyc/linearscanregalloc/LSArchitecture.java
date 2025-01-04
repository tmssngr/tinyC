package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;

/**
 * @author Thomas Singer
 */
public record LSArchitecture(int argRegisterCount, int otherVolatileRegisterCount, int nonVolatileRegisterCount, boolean isX86) {

	public static final LSArchitecture WIN_X86_64 = new LSArchitecture(4, 1, 2, true);
	public static final LSArchitecture Z8 = new LSArchitecture(3, 1, 2, false);

	public LSArchitecture {
		Utils.assertTrue(argRegisterCount > 0);
		Utils.assertTrue(otherVolatileRegisterCount >= 0);
		Utils.assertTrue(nonVolatileRegisterCount >= 0);
	}

	public LSCallingConvention callingConvention() {
		return new LSCallingConvention(argRegisterCount, otherVolatileRegisterCount);
	}

	public int registerCount() {
		return 1 + argRegisterCount + otherVolatileRegisterCount + nonVolatileRegisterCount;
	}
}
