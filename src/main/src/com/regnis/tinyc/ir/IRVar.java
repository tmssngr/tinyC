package com.regnis.tinyc.ir;

import com.regnis.tinyc.ast.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRVar(@NotNull String name, int index, @NotNull VariableScope scope, @NotNull Type type, boolean canBeRegister) {
	@NotNull
	public static IRVar createRegisterVar(int i, Type type) {
		return new IRVar("r." + i, i, VariableScope.register, type, true);
	}

	@Override
	public String toString() {
		return name + "(" + index + "@" + scope + "," + type + ")";
	}

	@NotNull
	public String toShortString() {
		return name + "(" + index + ")";
	}
}
