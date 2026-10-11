package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record LSUse(int pos, boolean read, boolean write) {
	public static LSUse write(int pos) {
		return new LSUse(pos, false, true);
	}

	public static LSUse read(int pos) {
		return new LSUse(pos, true, false);
	}

	public static LSUse readWrite(int pos) {
		return new LSUse(pos, true, true);
	}

	public LSUse {
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
		if (!write) {
			return 'R';
		}
		if (!read) {
			return 'W';
		}
		return 'X';
	}
}
