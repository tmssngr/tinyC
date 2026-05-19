package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record Function(@NotNull String name, @NotNull String typeString, @Nullable Type returnType, @NotNull List<Parameter> parameters, @NotNull List<Variable> localVars, @NotNull List<Statement> statements, @NotNull List<String> asmLines, @NotNull Location location) {

	public static Function typedInstance(@NotNull String name, @NotNull String typeString, @NotNull Type returnType, @NotNull List<Parameter> parameters, @NotNull List<Variable> localVars, @NotNull List<Statement> statements, List<String> asmLines, @NotNull Location location) {
		return new Function(name, typeString, returnType, parameters, localVars, statements, asmLines, location);
	}

	public static Function createInstance(@NotNull String name, @NotNull String typeString, @NotNull List<Parameter> parameters, @NotNull List<Statement> statements, @NotNull Location location) {
		return new Function(name, typeString, null, parameters, List.of(), statements, List.of(), location);
	}

	public static Function createAsmInstance(@NotNull String name, @NotNull String typeString, @NotNull List<Parameter> parameters, @NotNull List<String> asmLines, @NotNull Location location) {
		return new Function(name, typeString, null, parameters, List.of(), List.of(), asmLines, location);
	}

	@NotNull
	@Override
	public String toString() {
		return typeString + " " + name;
	}

	@NotNull
	public Type returnTypeNotNull() {
		return Objects.requireNonNull(returnType);
	}

	public record Parameter(@NotNull String typeString, @Nullable Type type, @NotNull String name, @NotNull Location location) {
		public Parameter(@NotNull String typeString, @NotNull String name, @NotNull Location location) {
			this(typeString, null, name, location);
		}

		@NotNull
		public Type typeNotNull() {
			return Objects.requireNonNull(type);
		}
	}
}
