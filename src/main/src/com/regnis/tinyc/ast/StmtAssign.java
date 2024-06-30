package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record StmtAssign(@NotNull String varName, @NotNull Expression expression, @NotNull Location location) implements Statement.Simple {

	@Override
	public String toString() {
		return varName + " = " + expression;
	}
}
