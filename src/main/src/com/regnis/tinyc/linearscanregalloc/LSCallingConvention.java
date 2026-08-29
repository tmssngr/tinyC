package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record LSCallingConvention(@NotNull List<Integer> argRegisters, int volatileRegisterCount) {

	@NotNull
	public static LSCallingConvention createX86CallingConvention(int argRegisterCount, int otherVolatileRegisterCount) {
		final List<Integer> argRegisters = new ArrayList<>();
		int argRegister = 1;
		for (int i = 0; i < argRegisterCount; i++) {
			argRegisters.add(argRegister);
			argRegister++;
		}
		return new LSCallingConvention(List.copyOf(argRegisters), 1 + argRegisterCount + otherVolatileRegisterCount);
	}

	public LSCallingConvention(@NotNull List<Integer> argRegisters, int volatileRegisterCount) {
		Utils.assertTrue(volatileRegisterCount >= 0);

		this.argRegisters = List.copyOf(argRegisters);
		this.volatileRegisterCount = volatileRegisterCount;
	}
}
