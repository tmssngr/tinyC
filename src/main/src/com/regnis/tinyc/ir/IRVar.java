package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRVar(@NotNull String name, int index, @NotNull VariableScope scope, @NotNull Type type) {
	@NotNull
	@Override
	public String toString() {
		return toString(false);
	}

	public String toString(boolean comment) {
		final StringBuilder buffer = new StringBuilder();
		if (!comment && scope == VariableScope.register) {
			buffer.append("r");
			buffer.append(index);
		}
		else {
			buffer.append(name);
			if (scope == VariableScope.register) {
				buffer.append("{r");
				buffer.append(index);
				buffer.append("}");
			}
		}
		return buffer.toString();
	}

	@NotNull
	public IRVar asRegister(int register) {
		Utils.assertTrue(register >= 0);
		Utils.assertTrue(scope != VariableScope.register);
		return new IRVar(name, register, VariableScope.register, type);
	}
}
