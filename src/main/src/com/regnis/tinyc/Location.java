package com.regnis.tinyc;

/**
 * @author Thomas Singer
 */
public record Location(int line, int column) {

	public static final Location DUMMY = new Location(0, 0);

	@Override
	public String toString() {
		return (line + 1) + ":" + (column + 1);
	}
}
