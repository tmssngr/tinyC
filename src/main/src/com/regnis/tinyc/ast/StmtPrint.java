package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record StmtPrint(@NotNull Expression expression, @NotNull Location location) implements Statement {
	@NotNull
	@Override
	public Statement determineTypes(VariableTypes types) {
		final Expression expression = this.expression.determineType(types);
		return new StmtPrint(expression, location);
	}
}
