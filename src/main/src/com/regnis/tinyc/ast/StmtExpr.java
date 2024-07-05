package com.regnis.tinyc.ast;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record StmtExpr(@NotNull Expression expression) implements Statement {

	@Override
	public String toString() {
		return expression.toString();
	}
}
