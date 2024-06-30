package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record StmtFor(@NotNull List<Simple> initialization, @NotNull Expression condition, @NotNull Statement bodyStatement, @NotNull List<Simple> iteration, @NotNull Location location) implements Statement {
	@NotNull
	@Override
	public Statement determineTypes(VariableTypes types) {
		final List<Simple> initialization = determineTypes(this.initialization, types);

		final Expression condition = this.condition.determineType(types);
		if (condition.typeNotNull() != Type.U8) {
			throw new SyntaxException("Expected type u8 for the condition", location);
		}

		final List<Simple> iteration = determineTypes(this.iteration, types);

		final Statement bodyStatement = this.bodyStatement.determineTypes(types);
		return new StmtFor(initialization, condition, bodyStatement, iteration, location);
	}

	@NotNull
	private static List<Simple> determineTypes(@NotNull List<Simple> initialization, VariableTypes types) {
		final List<Simple> newInit = new ArrayList<>();
		for (Simple statement : initialization) {
			final Simple newStatement = statement.determineTypes(types);
			newInit.add(newStatement);
		}
		return newInit;
	}
}
