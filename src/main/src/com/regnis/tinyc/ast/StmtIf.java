package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;
import com.regnis.tinyc.types.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public
record StmtIf(@NotNull Expression condition, @NotNull Statement thenStatement, @Nullable Statement elseStatement, @NotNull Location location) implements Statement {
	@NotNull
	@Override
	public Statement determineTypes(VariableTypes types) {
		final Expression condition = this.condition.determineType(types);
		if (condition.typeNotNull() != Type.U8) {
			throw new SyntaxException("Expected type u8 for the condition", location);
		}
		final Statement thenStatement = this.thenStatement.determineTypes(types);
		Statement elseStatement = null;
		if (this.elseStatement != null) {
			elseStatement = this.elseStatement.determineTypes(types);
		}
		return new StmtIf(condition, thenStatement, elseStatement, location);
	}
}
