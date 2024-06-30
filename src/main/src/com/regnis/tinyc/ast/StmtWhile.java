package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record StmtWhile(@NotNull Expression condition, @NotNull Statement bodyStatement, @NotNull Location location) implements Statement {
	@NotNull
	@Override
	public Statement determineTypes(VariableTypes types) {
		final Expression condition = this.condition.determineType(types);
		if (condition.typeNotNull() != Type.U8) {
			throw new SyntaxException("Expected type u8 for the condition", location);
		}
		final Statement bodyStatement = this.bodyStatement.determineTypes(types);
		return new StmtWhile(condition, bodyStatement, location);
	}
}
