package com.regnis.tinyc.ir;

/**
 * @author Thomas Singer
 */
public record IRGlobalVar(String name, int index, int size) {
	@Override
	public String toString() {
		return index + ": " + name + " (" + size + ")";
	}
}
