package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRVar(@NotNull String name, int index, @NotNull VariableScope scope, @NotNull Type type) {
	@Override
	public String toString() {
		if (scope == VariableScope.register) {
			return "r" + index;
		}
		return name;
	}

	@NotNull
	public IRVar asRegister(int register) {
		Utils.assertTrue(register >= 0);
		Utils.assertTrue(scope != VariableScope.register);
		return new IRVar(name, register, VariableScope.register, type);
	}
}
