package com.regnis.tinyc.ast;

import com.regnis.tinyc.Location;

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
}
