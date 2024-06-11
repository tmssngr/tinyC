package com.regnis.tinyc;

/**
 * @author Thomas Singer
 */
public record Location(int line, int column) {

	@Override
	public String toString() {
		return (line + 1) + ":" + (column + 1);
	}
}
