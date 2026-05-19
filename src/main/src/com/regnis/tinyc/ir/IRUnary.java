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
		return op.toString().toLowerCase() + " " + target + ", " + source;
	}

	public enum Op {
		Not, Neg, NotLog
	}
}
