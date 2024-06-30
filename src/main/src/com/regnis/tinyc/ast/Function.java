package com.regnis.tinyc.ast;

import com.regnis.tinyc.Location;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record Function(String name, String typeString, @Nullable Type returnType, List<Arg> args, Statement statement, Location location) {

	public Function(String typeString, String name, List<Arg> args, Statement statement, Location location) {
		this(name, typeString, null, args, statement, location);
	}

	@Override
	public String toString() {
		return typeString + " " + name;
	}

	public record Arg(String typeString, @Nullable Type type, String name, Location location) {
		public Arg(String typeString, String name, Location location) {
			this(typeString, null, name, location);
		}
	}
}
