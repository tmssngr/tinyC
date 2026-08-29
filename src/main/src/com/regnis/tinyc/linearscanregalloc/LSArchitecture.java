package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record LSArchitecture(int argRegisterCount, int otherVolatileRegisterCount, int nonVolatileRegisterCount, boolean isX86) implements LSCallingConventionProvider {

	public static final LSArchitecture WIN_X86_64 = new LSArchitecture(4, 1, 2, true);

	public LSArchitecture {
		Utils.assertTrue(argRegisterCount > 0);
		Utils.assertTrue(otherVolatileRegisterCount >= 0);
		Utils.assertTrue(nonVolatileRegisterCount >= 0);
	}

	@Override
	public LSCallingConvention getCallingConvention(@NotNull Type targetType, @NotNull List<Type> argTypes) {
		return LSCallingConvention.createX86CallingConvention(argRegisterCount, otherVolatileRegisterCount);
	}

	public int registerCount() {
		return 1 + argRegisterCount + otherVolatileRegisterCount + nonVolatileRegisterCount;
	}
}
