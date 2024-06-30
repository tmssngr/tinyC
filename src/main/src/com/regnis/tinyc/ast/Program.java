package com.regnis.tinyc.ast;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record Program(@NotNull List<Function> functions) {
	@NotNull
	public Program determineTypes() {
		final VariableTypes types = new VariableTypes();
		final List<Function> functions = new ArrayList<>();
		for (Function function : this.functions) {
			final Function newFunction = function.determineTypes(types);
			functions.add(newFunction);
		}
		return new Program(functions);
	}
}
