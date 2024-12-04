package com.regnis.tinyc.ir;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRVarDef(@NotNull IRVar var, int size, boolean isArray) {
	public IRVarDef(@NotNull IRVar var, int size) {
		this(var, size, false);
	}

	@Override
	public String toString() {
		final StringBuilder buffer = new StringBuilder();
		buffer.append(var);
		if (isArray) {
			buffer.append("[]");
		}
		buffer.append("/");
		buffer.append(size);
		return buffer.toString();
	}

	@NotNull
	public String getString() {
		final StringBuilder buffer = new StringBuilder();
		buffer.append(var.index());
		buffer.append(": ");
		buffer.append(var.name());
		if (isArray) {
			buffer.append("[]");
		}
		buffer.append(" (");
		buffer.append(var.type());
		buffer.append("/");
		buffer.append(size());
		buffer.append(")");
		return buffer.toString();
	}
}
