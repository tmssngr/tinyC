package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

/**
 * @author Thomas Singer
 */
public record IRStringLiteral(int index, String name, String text) {
	@Override
	public String toString() {
		return "string lit " + index + " " + Utils.escape(text);
	}
}
