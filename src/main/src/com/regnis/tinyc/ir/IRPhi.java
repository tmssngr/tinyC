package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRPhi(@NotNull IRVar var, @NotNull List<IRVar> vars) implements IRInstruction {
	public IRPhi {
		Utils.assertTrue(var.scope() == VariableScope.function);
		Utils.assertTrue(vars.size() > 1);
		for (IRVar fromVar : vars) {
			Utils.assertTrue(fromVar != null);
			Utils.assertTrue(fromVar.scope() == VariableScope.function);
		}
	}

	@NotNull
	@Override
	public String toString() {
		final StringBuilder buffer = new StringBuilder();
		buffer.append("phi ");
		buffer.append(var);
		buffer.append("=[");
		for (int i = 0; i < vars.size(); i++) {
			final IRVar var = vars.get(i);
			if (i > 0) {
				buffer.append(", ");
			}
			buffer.append(var);
		}
		buffer.append("]");
		return buffer.toString();
	}
}
