package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public interface LSArchitecture extends LSCallingConventionProvider {

	int registerCount();

	boolean isX86();

	class Win_X86_64 implements LSArchitecture {
		private final int argRegisterCount;
		private final int otherVolatileRegisterCount;
		private final int nonVolatileRegisterCount;
		private final LSCallingConvention callingConvention;

		public Win_X86_64(int argRegisterCount, int otherVolatileRegisterCount, int nonVolatileRegisterCount) {
			this.argRegisterCount = argRegisterCount;
			this.otherVolatileRegisterCount = otherVolatileRegisterCount;
			this.nonVolatileRegisterCount = nonVolatileRegisterCount;
			this.callingConvention = LSCallingConvention.createX86CallingConvention(argRegisterCount, otherVolatileRegisterCount);
		}

		@Override
		public int registerCount() {
			return 1 + argRegisterCount + otherVolatileRegisterCount + nonVolatileRegisterCount;
		}

		@Override
		public boolean isX86() {
			return true;
		}

		@Override
		public LSCallingConvention getCallingConvention(@NotNull Type targetType, @NotNull List<Type> argTypes) {
			return callingConvention;
		}
	}
}
