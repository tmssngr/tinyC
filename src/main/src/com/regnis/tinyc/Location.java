package com.regnis.tinyc;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record Location(int line, int column) {

	public static final Location DUMMY = new Location(0, 0);

	@NotNull
	@Override
	public String toString() {
		return (line + 1) + ":" + (column + 1);
	}
}
