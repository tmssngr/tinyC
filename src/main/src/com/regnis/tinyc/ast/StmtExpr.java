package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record StmtExpr(@NotNull Expression expression) implements Statement {
	@NotNull
	@Override
	public Location location() {
		return expression.location();
	}

	@NotNull
	@Override
	public String toString() {
		return expression.toString();
	}
}
