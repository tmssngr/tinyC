package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class VariableTypes {

	private final Map<String, Pair<Type, Location>> variables = new HashMap<>();
	private final VariableTypes parent;

	public VariableTypes() {
		this.parent = null;
	}

	public VariableTypes(@NotNull VariableTypes parent) {
		this.parent = parent;
	}

	@Nullable
	public Type getVariableType(@NotNull String name) {
		final Pair<Type, Location> pair = variables.get(name);
		return pair != null ? pair.left() : null;
	}

	@NotNull
	public Type getType(@NotNull String type, @NotNull Location location) {
		return switch (type) {
			case "void" -> Type.VOID;
			case "u8" -> Type.U8;
			case "i16" -> Type.I16;
			default -> throw new SyntaxException("Unknown type '" + type + "'", location);
		};
	}

	@Nullable
	public Location addVariable(@NotNull String varName, @NotNull Type type, @NotNull Location location) {
		final Pair<Type, Location> pair = variables.get(varName);
		if (pair != null) {
			return pair.right();
		}
		variables.put(varName, new Pair<>(type, location));
		return null;
	}
}
