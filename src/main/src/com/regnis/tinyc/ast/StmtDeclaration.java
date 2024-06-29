package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;
import com.regnis.tinyc.types.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record StmtDeclaration(@NotNull String typeString, @Nullable Type type, @NotNull String varName, @NotNull Expression expression, @NotNull Location location) implements Statement.Simple {

	public StmtDeclaration(@NotNull String typeString, @NotNull String varName, @NotNull Expression expression, @NotNull Location location) {
		this(typeString, null, varName, expression, location);
	}

	@Override
	public String toString() {
		return typeString + " " + varName + " = " + expression;
	}

	@NotNull
	@Override
	public Simple determineTypes(VariableTypes types) {
		Expression expression = this.expression.determineType(types);
		expression.typeNotNull();
		final Type type = types.getType(typeString, location);
		if (!type.equals(expression.typeNotNull())) {
			if (type == Type.U8) {
				throw new SyntaxException("Expected type " + type + " but got " + expression.typeNotNull(), location);
			}

			expression = new ExprCast(expression, expression.typeNotNull(), type, expression.location());
		}
		final Location prevDeclaration = types.addVariable(varName, type, location);
		if (prevDeclaration != null) {
			throw new SyntaxException("Variable '" + varName + "' has already been declared at " + prevDeclaration, location);
		}
		return new StmtDeclaration(typeString, type, varName, expression, location);
	}

	@NotNull
	public Type type() {
		return Objects.requireNonNull(type);
	}
}
