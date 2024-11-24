package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRBinary(@NotNull IRVar target, @NotNull Op op, @NotNull IRVar left, @NotNull IRVar right, @NotNull Location location) implements IRInstruction {
	public IRBinary {
		Utils.assertTrue(Objects.equals(target.type(), left.type()), target.type() + " vs. " + left.type());
		Utils.assertTrue(Objects.equals(target.type(), right.type()), target.type() + " vs. " + right.type());
	}

	@Override
	public String toString() {
		return op.toString().toLowerCase() + " " + target + ", " + left + ", " + right;
	}

	public enum Op {
		Add, Sub, Mul, Div, Mod,
		ShiftLeft, ShiftRight,
		And, Or, Xor,
	}
}
