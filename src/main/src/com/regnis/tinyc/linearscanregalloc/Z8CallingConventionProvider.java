package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class Z8CallingConventionProvider implements LSCallingConventionProvider {
	public static final Type POINTER_INT_TYPE = Type.I16;
	public static final LSCallingConventionProvider INSTANCE = new Z8CallingConventionProvider();

	private Z8CallingConventionProvider() {
	}

	@NotNull
	@Override
	public LSCallingConvention getCallingConvention(@NotNull Type targetType, @NotNull List<Type> argTypes) {
		final List<Integer> argRegisters = new ArrayList<>();
		int argRegister = 0;
		for (Type type : argTypes) {
			if (type.isPointer() && (argRegister & 1) == 1) {
				argRegister++;
			}
			if (argRegister >= 8) {
				break;
			}
			argRegisters.add(argRegister);
			final int size = Type.getSize(type, POINTER_INT_TYPE);
			argRegister += size;
		}
		return new LSCallingConvention(argRegisters, Math.max(argRegister, 8));
	}
}
