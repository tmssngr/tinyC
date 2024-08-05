package com.regnis.tinyc.ir;

/**
 * @author Thomas Singer
 */
public record IRLocalVar(String name, int index, boolean isArg, int size) {
	@Override
	public String toString() {
		return index + ": " + name;
	}
}
