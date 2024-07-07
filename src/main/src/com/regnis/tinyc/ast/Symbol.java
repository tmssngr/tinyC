package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public interface Symbol {

	@NotNull
	Location location();

	record Variable(@NotNull Type type, @NotNull Location location) implements Symbol {
	}

	record Func(@NotNull Type returnType, @NotNull List<Type> argTypes, @NotNull Location location) implements Symbol {
		public Func(Type returnType, List<Type> argTypes, Location location) {
			this.returnType = returnType;
			this.argTypes = List.copyOf(argTypes);
			this.location = location;
		}
	}
}
