package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record LSUse2(int pos, boolean write, boolean requiresRegister) {
	public LSUse2 {
		Utils.assertTrue(pos >= 0);
	}

	@NotNull
	@Override
	public String toString() {
		final StringBuilder buffer = new StringBuilder();
		buffer.append(pos);
		buffer.append(asChar());
		return buffer.toString();
	}

	public char asChar() {
		return write ? 'W' : 'R';
	}
}
