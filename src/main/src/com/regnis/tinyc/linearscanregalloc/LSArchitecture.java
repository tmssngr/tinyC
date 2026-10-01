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
public record LSArchitecture(int argRegisterCount, int otherVolatileRegisterCount, int nonVolatileRegisterCount, boolean isX86) implements LSCallingConventionProvider, IRLocalOptimizer.PlatformSpecificInstructionBehavior {

	public static final LSArchitecture WIN_X86_64 = new LSArchitecture(4, 1, 2, true);

	public LSArchitecture {
		Utils.assertTrue(argRegisterCount > 0);
		Utils.assertTrue(otherVolatileRegisterCount >= 0);
		Utils.assertTrue(nonVolatileRegisterCount >= 0);
	}

	@NotNull
	@Override
	public LSCallingConvention getCallingConvention(@NotNull Type targetType, @NotNull List<Type> argTypes) {
		return LSCallingConvention.createX86CallingConvention(argRegisterCount, otherVolatileRegisterCount);
	}

	@NotNull
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
				return index -> index == X86Registers.WINDOWS.rax() || index == X86Registers.WINDOWS.rdx();
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

	public int registerCount() {
		return 1 + argRegisterCount + otherVolatileRegisterCount + nonVolatileRegisterCount;
	}
}
