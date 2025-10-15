package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRCall(@Nullable IRVar target, @NotNull Type type, @NotNull String name, @NotNull List<IRVar> args, @NotNull Location location) implements IRInstruction {
	public IRCall {
		if (target != null) {
			Utils.assertTrue(type.equals(target.type()));
		}
	}

	@Override
	public String toString() {
		final StringBuilder buffer = new StringBuilder();
		buffer.append("call ");
		if (type != Type.VOID) {
			buffer.append(target != null ? target.toString() : "_");
			buffer.append(" = ");
		}
		buffer.append(name);
		buffer.append(args);
		if (type != Type.VOID) {
			buffer.append(" -> ");
			buffer.append(type);
		}
		return buffer.toString();
	}

	public List<Type> getArgumentTypes() {
		final List<Type> types = new ArrayList<>();
		for (IRVar arg : args) {
			types.add(arg.type());
		}
		return types;
	}
}
