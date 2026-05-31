package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRCall(@Nullable IRVar target, @NotNull Type type, @NotNull String name, @NotNull List<IRVar> args, @NotNull Location location) implements IRInstruction {
	public IRCall(@Nullable IRVar target, @NotNull Type type, @NotNull String name, @NotNull List<IRVar> args) {
		this(target, type, name, args, Location.DUMMY);
	}

	public IRCall {
		if (target != null) {
			Utils.assertTrue(type.equals(target.type()));
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
		buffer.append("call ");
		if (type != Type.VOID) {
			buffer.append(target != null ? target.toString(comment) : "_");
			buffer.append(" = ");
		}
		buffer.append(name);
		buffer.append("[");
		for (int i = 0; i < args.size(); i++) {
			final IRVar arg = args.get(i);
			if (i > 0) {
				buffer.append(", ");
			}
			buffer.append(arg.toString(comment));
		}
		buffer.append("]");
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
