package com.regnis.tinyc.ir;

import com.regnis.tinyc.ast.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRVar(@NotNull String name, int index, @NotNull VariableScope scope, @NotNull Type type, boolean canBeRegister) {
	@NotNull
	public static IRVar createRegisterVar(int register, @NotNull IRVar var) {
		return new IRVar(var.name, register, VariableScope.register, var.type(), true);
	}

	@Override
	public String toString() {
		if (scope == VariableScope.register) {
			return "r" + index + "(" + type + " " + name + ")";
		}
		return name + "(" + index + "@" + scope + "," + type + ")";
	}
}
