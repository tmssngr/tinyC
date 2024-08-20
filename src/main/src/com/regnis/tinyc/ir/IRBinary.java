package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRBinary(@NotNull IRVar target, @NotNull Op op, @NotNull IRVar left, @NotNull IRVar right, @NotNull Location location) implements IRInstruction {
	@Override
	public String toString() {
		return op.toString().toLowerCase() + " " + target + ", " + left + ", " + right;
	}

	public enum Op {
		Add, Sub, Mul, Div, Mod,
		ShiftLeft, ShiftRight,
		And, Or, Xor,
		Lt, LtEq, Equals, NotEquals, GtEq, Gt
	}
}
