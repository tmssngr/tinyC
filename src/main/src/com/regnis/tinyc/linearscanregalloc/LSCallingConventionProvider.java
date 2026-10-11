package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public interface LSCallingConventionProvider {

	@NotNull
	LSCallingConvention getCallingConvention(@NotNull Type targetType, @NotNull List<Type> argTypes);
}
