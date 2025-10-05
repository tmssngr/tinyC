package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRCompareConst(@NotNull IRVar target, @NotNull IRCompareOp op, @NotNull IRVar left, int value, @NotNull Location location) implements IRInstruction {
	public IRCompareConst {
		Utils.assertTrue(left.type().isInt());
		Utils.assertTrue(Objects.equals(target.type(), Type.BOOL), String.valueOf(target.type()));
	}

	@NotNull
	@Override
	public String toString() {
		return toString(false);
	}

	@Override
	public String toString(boolean comment) {
		return op.toString().toLowerCase() + " " + target.toString(comment) + ", " + left.toString(comment) + ", " + value;
	}
}
