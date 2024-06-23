package com.regnis.tinyc.ast;

/**
 * @author Thomas Singer
 */
public record Function(String name, String type, Statement statement, com.regnis.tinyc.Location location) {

	@Override
	public String toString() {
		return type + " " + name;
	}
}
