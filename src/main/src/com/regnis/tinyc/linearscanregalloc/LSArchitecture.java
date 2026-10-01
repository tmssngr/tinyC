package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;
import java.util.function.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public interface LSArchitecture {

	Type getPointerIntType();

	int registerCount();

	@NotNull
	LSCallingConventionProvider getCallingConventionProvider();

	@NotNull
	IRLocalOptimizer.PlatformSpecificInstructionBehavior getIROptimizationBehavior();

	class X86_64 implements LSArchitecture, LSCallingConventionProvider, IRLocalOptimizer.PlatformSpecificInstructionBehavior {
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
		@Override
		public IRLocalOptimizer.PlatformSpecificInstructionBehavior getIROptimizationBehavior() {
			return this;
		}

		@Nullable
		@Override
		public IntPredicate getClobberedRegisters(@NotNull IRInstruction instruction) {
			switch (instruction) {
			case IRBinary binary -> {
				switch (binary.op()) {
				case Div, Mod -> {
					// https://www.felixcloutier.com/x86/idiv
					return index -> index == registers.rax() || index == registers.rdx();
				}
				}
			}
			case IRCall ignored -> {
				final int volatileRegCount = 1 + argRegisterCount + otherVolatileRegisterCount;
				return index -> index < volatileRegCount;
			}
			default -> {}
			}
			return null;
		}

		@NotNull
		public X86Registers getRegisters() {
			return registers;
		}

		public int getArgCountInRegisters() {
			return argRegisterCount;
		}
	}

	class Z8 implements LSArchitecture, IRLocalOptimizer.PlatformSpecificInstructionBehavior {
		public Z8() {
		}

		@Override
		public Type getPointerIntType() {
			return Z8CallingConventionProvider.POINTER_INT_TYPE;
		}

		@NotNull
		@Override
		public LSCallingConventionProvider getCallingConventionProvider() {
			return Z8CallingConventionProvider.INSTANCE;
		}

		@Override
		public int registerCount() {
			return 16;
		}

		@NotNull
		@Override
		public IRLocalOptimizer.PlatformSpecificInstructionBehavior getIROptimizationBehavior() {
			return this;
		}

		@Nullable
		@Override
		public IntPredicate getClobberedRegisters(@NotNull IRInstruction instruction) {
			return Z8CallingConventionProvider.getClobberedRegisters(instruction);
		}

		@Override
		public boolean isUsefulToBeReplacedWithMove(@NotNull IRInstruction instruction) {
			switch (instruction) {
			case IRBinary binary -> {
				final IRBinary.Op op = binary.op();
				if (op == IRBinary.Op.Add || op == IRBinary.Op.Sub) {
					final IRValue right = binary.right();
					if (right.type() == Type.I16
					    && right.var() == null && right.value() == 1) {
						return false;
					}
				}
			}
			case IRMove ignored -> {
				return false;
			}
			default -> {}
			}
			return true;
		}
	}
}
