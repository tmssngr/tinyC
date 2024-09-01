package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRBinary(@NotNull IRVar target, @NotNull Op op, @NotNull IRVar left, @NotNull IRVar right, @NotNull Location location) implements IRInstruction {
	public IRBinary {
		if (op.relational) {
			Utils.assertTrue(Objects.equals(left.type(), right.type()), left.type() + " vs. " + right.type());
			Utils.assertTrue(Objects.equals(target.type(), Type.BOOL), String.valueOf(target.type()));
		}
		else {
			Utils.assertTrue(Objects.equals(target.type(), left.type()), target.type() + " vs. " + left.type());
			Utils.assertTrue(Objects.equals(target.type(), right.type()), target.type() + " vs. " + right.type());
		}
	}

	@Override
	public String toString() {
		return op.toString().toLowerCase() + " " + target + ", " + left + ", " + right;
	}

	public enum Op {
		Add(false), Sub(false), Mul(false), Div(false), Mod(false),
		ShiftLeft(false), ShiftRight(false),
		And(false), Or(false), Xor(false),
		Lt(true), LtEq(true), Equals(true), NotEquals(true), GtEq(true), Gt(true);

		private final boolean relational;

		Op(boolean relational) {
			this.relational = relational;
		}
	}
}
