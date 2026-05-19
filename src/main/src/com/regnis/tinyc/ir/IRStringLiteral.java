package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRStringLiteral(int index, @NotNull String name, @NotNull String text) {
	@NotNull
	@Override
	public String toString() {
		return "string lit " + index + " " + Utils.escape(text);
	}
}
