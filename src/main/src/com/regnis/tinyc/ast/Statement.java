package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public interface Statement {
	record Compound(List<Statement> statements) implements Statement {}

	record Print(AstNode expression, Location location) implements Statement {}

	record If(AstNode condition, Statement thenStatement, @Nullable Statement elseStatement, Location location) implements Statement {}

	record While(AstNode condition, Statement bodyStatement, Location location) implements Statement {}

	record For(List<SimpleStatement> initialization, AstNode condition, Statement bodyStatement, List<SimpleStatement> iteration, Location location) implements Statement {}
}
