package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record Function(@NotNull String name, @NotNull String typeString, @Nullable Type returnType, @NotNull List<Arg> args, @NotNull List<Variable> localVars, @NotNull List<Statement> statements, @NotNull List<String> asmLines, @NotNull Location location) {

	public static Function typedInstance(@NotNull String name, @NotNull String typeString, @NotNull Type returnType, @NotNull List<Arg> args, @NotNull List<Variable> localVars, @NotNull List<Statement> statements, List<String> asmLines, @NotNull Location location) {
		return new Function(name, typeString, returnType, args, localVars, statements, asmLines, location);
	}

	public static Function createInstance(@NotNull String name, @NotNull String typeString, @NotNull List<Arg> args, @NotNull List<Statement> statements, @NotNull Location location) {
		return new Function(name, typeString, null, args, List.of(), statements, List.of(), location);
	}

	public static Function createAsmInstance(@NotNull String name, @NotNull String typeString, @NotNull List<Arg> args, @NotNull List<String> asmLines, @NotNull Location location) {
		return new Function(name, typeString, null, args, List.of(), List.of(), asmLines, location);
	}

	@Override
	public String toString() {
		return typeString + " " + name;
	}

	@NotNull
	public Type returnTypeNotNull() {
		return Objects.requireNonNull(returnType);
	}

	public record Arg(@NotNull String typeString, @Nullable Type type, @NotNull String name, @NotNull Location location) {
		public Arg(@NotNull String typeString, @NotNull String name, @NotNull Location location) {
			this(typeString, null, name, location);
		}

		@NotNull
		public Type typeNotNull() {
			return Objects.requireNonNull(type);
		}
	}
}
