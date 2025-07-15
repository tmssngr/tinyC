package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public interface LSArchitecture extends LSCallingConventionProvider, LSTypeRegisterCountProvider {

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
		public int registerCount(@NotNull Type type) {
			return 1;
		}

		@Override
		public boolean canUseRegister(@NotNull Type type, int register) {
			return true;
		}

		@Override
		public LSCallingConvention getCallingConvention(@NotNull Type targetType, @NotNull List<Type> argTypes) {
			return callingConvention;
		}
	}

	class Z8 implements LSArchitecture {
		private final int registerCount = 16;

		public Z8() {
		}

		@Override
		public int registerCount() {
			return registerCount;
		}

		@Override
		public boolean isX86() {
			return false;
		}

		public int registerCount(@NotNull Type type) {
			Utils.assertTrue(type != Type.VOID);
			if (type.isPointer()) {
				return 2;
			}

			return Type.getSize(type);
		}

		@Override
		public boolean canUseRegister(@NotNull Type type, int register) {
			Utils.assertTrue(type != Type.VOID);
			return !type.isPointer() || (register & 1) == 0;
		}

		@Override
		public LSCallingConvention getCallingConvention(@NotNull Type returnType, @NotNull List<Type> argTypes) {
			final List<Integer> registers = new ArrayList<>();
			int register = 0;
			if (returnType != Type.VOID) {
				register = registerCount(returnType);
			}

			int volatileRegisterCount = registerCount / 2;
			for (Type type : argTypes) {
				final int size = registerCount(type);
				if (!canUseRegister(type, register)) {
					register++;
					Utils.assertTrue(canUseRegister(type, register));
				}

				final int nextRegister = register + size;
				if (nextRegister >= registerCount) {
					volatileRegisterCount = register;
					break;
				}

				registers.add(register);
				register = nextRegister;
			}
			return new LSCallingConvention(registers, volatileRegisterCount);
		}
	}
}
