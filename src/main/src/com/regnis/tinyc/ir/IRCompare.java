package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRCompare(@NotNull IRVar target, @NotNull Op op, @NotNull IRVar left, @NotNull IRVar right, @NotNull Location location) implements IRInstruction {
	public IRCompare {
		Utils.assertTrue(Objects.equals(left.type(), right.type()), left.type() + " vs. " + right.type());
		Utils.assertTrue(Objects.equals(target.type(), Type.BOOL), String.valueOf(target.type()));
	}

	@NotNull
	@Override
	public String toString() {
		return toString(false);
	}

	@Override
	public String toString(boolean comment) {
		return op.toString().toLowerCase() + " " + target.toString(comment) + ", " + left.toString(comment) + ", " + right.toString(comment);
	}

	public enum Op {
		Lt, LtEq, Equals, NotEquals, GtEq, Gt;
	}
}
