package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;

/**
 * @author Thomas Singer
 */
public record LSUse(int pos) {
	public static LSUse write(int pos) {
		Utils.assertTrue((pos & 1) == 1);
		return new LSUse(pos);
	}

	public static LSUse read(int pos) {
		Utils.assertTrue((pos & 1) == 0);
		return new LSUse(pos);
	}

	public LSUse {
		Utils.assertTrue(pos >= 0);
	}

	@Override
	public String toString() {
		final StringBuilder buffer = new StringBuilder();
		buffer.append(pos);
		buffer.append(asChar());
		return buffer.toString();
	}

	public char asChar() {
		return isWrite() ? 'W' : 'R';
	}

	public boolean isWrite() {
		return (pos & 1) != 0;
	}
}
