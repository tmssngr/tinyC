package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public interface LSArchitecture {

	Type getPointerIntType();

	int registerCount();

	@NotNull
	LSCallingConventionProvider getCallingConventionProvider();

	class X86_64 implements LSArchitecture, LSCallingConventionProvider {
		private final int argRegisterCount;
		private final int otherVolatileRegisterCount;
		private final int nonVolatileRegisterCount;
		private final LSCallingConvention callingConvention;
		private final X86Registers registers;

		public X86_64(int argRegisterCount, int otherVolatileRegisterCount, int nonVolatileRegisterCount, X86Registers registers) {
			this.argRegisterCount = argRegisterCount;
			this.otherVolatileRegisterCount = otherVolatileRegisterCount;
			this.nonVolatileRegisterCount = nonVolatileRegisterCount;
			this.registers = registers;
			this.callingConvention = LSCallingConvention.createX86CallingConvention(argRegisterCount, otherVolatileRegisterCount);
		}

		@Override
		public Type getPointerIntType() {
			return Type.I64;
		}

		@Override
		public int registerCount() {
			return 1 + argRegisterCount + otherVolatileRegisterCount + nonVolatileRegisterCount;
		}

		@NotNull
		@Override
		public LSCallingConventionProvider getCallingConventionProvider() {
			return this;
		}

		@NotNull
		@Override
		public LSCallingConvention getCallingConvention(@NotNull Type targetType, @NotNull List<Type> argTypes) {
			return callingConvention;
		}

		@NotNull
		public X86Registers getRegisters() {
			return registers;
		}

		public int getArgCountInRegisters() {
			return argRegisterCount;
		}
	}

	class Z8 implements LSArchitecture, LSCallingConventionProvider {
		public Z8() {
		}

		@Override
		public Type getPointerIntType() {
			return Type.I16;
		}

		@NotNull
		@Override
		public LSCallingConventionProvider getCallingConventionProvider() {
			return this;
		}

		@Override
		public int registerCount() {
			return 16;
		}

		@NotNull
		@Override
		public LSCallingConvention getCallingConvention(@NotNull Type targetType, @NotNull List<Type> argTypes) {
			final List<Integer> argRegisters = new ArrayList<>();
			if (targetType == Type.VOID) {
				targetType = Type.U8;
			}

			int argRegister = Math.max(Type.getSize(targetType, getPointerIntType()), 2);
			for (Type type : argTypes) {
				if (argRegister >= 8) {
					break;
				}
				argRegisters.add(argRegister);
				final int size = Type.getSize(type, getPointerIntType());
				argRegister += size;
			}
			return new LSCallingConvention(argRegisters, 16);
		}
	}
}
