package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRPhi(@NotNull IRVar target, @NotNull List<IRVar> sources) implements IRInstruction {
	public IRPhi {
		Utils.assertTrue(target.scope() == VariableScope.function);
		Utils.assertTrue(sources.size() > 1);
		for (IRVar fromVar : sources) {
			Utils.assertTrue(fromVar != null);
		}
	}

	@NotNull
	@Override
	public String toString() {
		return toString(false);
	}

	@Override
	public String toString(boolean comment) {
		final StringBuilder buffer = new StringBuilder();
		buffer.append("phi ");
		buffer.append(target.toString(comment));
		buffer.append("=[");
		for (int i = 0; i < sources.size(); i++) {
			final IRVar var = sources.get(i);
			if (i > 0) {
				buffer.append(", ");
			}
			buffer.append(var.toString(comment));
		}
		buffer.append("]");
		return buffer.toString();
	}
}
