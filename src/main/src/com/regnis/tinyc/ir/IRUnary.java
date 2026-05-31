package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRUnary(@NotNull Op op, @NotNull IRVar target, @NotNull IRVar source) implements IRInstruction {
	public IRUnary {
		Utils.assertTrue(Objects.equals(target.type(), source.type()));
	}

	@NotNull
	@Override
	public String toString() {
		return toString(false);
	}

	@Override
	public String toString(boolean comment) {
		return op.toString().toLowerCase() + " " + target.toString(comment) + ", " + source.toString(comment);
	}

	public enum Op {
		Not, Neg, NotLog
	}
}
