package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;
import com.regnis.tinyc.types.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record StmtAssign(@NotNull String varName, @NotNull Expression expression, @NotNull Location location) implements Statement.Simple {

	@NotNull
	@Override
	public Simple determineTypes(VariableTypes types) {
		Expression expression = this.expression.determineType(types);
		final Type type = types.getVariableType(varName);
		if (type == null) {
			throw new SyntaxException("Undeclared variable '" + varName + "'", location);
		}

		if (!type.equals(expression.typeNotNull())) {
			if (type == Type.U8) {
				throw new SyntaxException("Expected type " + type + " but got " + expression.typeNotNull(), location);
			}

			expression = new ExprCast(expression, expression.typeNotNull(), type, expression.location());
		}
		return new StmtAssign(varName, expression, location);
	}

	@Override
	public String toString() {
		return varName + " = " + expression;
	}
}
