package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record TypeDef(String name, @Nullable Type type, List<Part> parts, Location location) {

	@NotNull
	public Type typeNotNull() {
		return Objects.requireNonNull(type);
	}

	public record Part(String name, String typeName, @Nullable Type type, Location location) {
		@NotNull
		public Type typeNotNull() {
			return Objects.requireNonNull(type);
		}
	}
}
