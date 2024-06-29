package com.regnis.tinyc.ast;

import com.regnis.tinyc.Location;
import com.regnis.tinyc.types.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record Function(String name, String typeString, @Nullable Type type, Statement statement, Location location) {

	public Function(String name, String typeString, Statement statement, Location location) {
		this(name, typeString, null, statement, location);
	}

	@Override
	public String toString() {
		return typeString + " " + name;
	}

	@NotNull
	public Function determineTypes(@NotNull VariableTypes types) {
		final Type type = types.getType(typeString, location);
		final Statement newStatement = statement.determineTypes(types);
		return new Function(name, typeString, type, newStatement, location);
	}
}
