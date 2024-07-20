package com.regnis.tinyc.ast;

import com.regnis.tinyc.Location;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record Function(@NotNull String name, @NotNull String typeString, @Nullable Type returnType, @NotNull List<Arg> args, @NotNull List<Variable> localVars, @NotNull Statement statement, @NotNull Location location) {

	public Function(@NotNull String name, @NotNull String typeString, @NotNull List<Arg> args, @NotNull Statement statement, @NotNull Location location) {
		this(name, typeString, null, args, List.of(), statement, location);
	}

	@Override
	public String toString() {
		return typeString + " " + name;
	}

	public record Arg(@NotNull String typeString, @Nullable Type type, @NotNull String name, @NotNull Location location) {
		public Arg(@NotNull String typeString, @NotNull String name, @NotNull Location location) {
			this(typeString, null, name, location);
		}
	}
}
