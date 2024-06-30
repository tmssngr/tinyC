package com.regnis.tinyc.ast;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record StmtCompound(List<Statement> statements) implements Statement {
	@NotNull
	@Override
	public Statement determineTypes(VariableTypes types) {
		final List<Statement> statements = new ArrayList<>();
		for (Statement statement : this.statements) {
			final Statement newStatement = statement.determineTypes(types);
			statements.add(newStatement);
		}
		return new StmtCompound(statements);
	}
}
