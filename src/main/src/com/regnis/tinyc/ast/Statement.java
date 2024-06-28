package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public interface Statement {
	record Compound(List<Statement> statements) implements Statement {}

	record Print(Expression expression, Location location) implements Statement {}

	record If(Expression condition, Statement thenStatement, @Nullable Statement elseStatement, Location location) implements Statement {}

	record While(Expression condition, Statement bodyStatement, Location location) implements Statement {}

	record For(List<SimpleStatement> initialization, Expression condition, Statement bodyStatement, List<SimpleStatement> iteration, Location location) implements Statement {}
}
