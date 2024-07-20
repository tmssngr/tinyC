package com.regnis.tinyc.ir;

import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRFunction(@NotNull String name, @NotNull String label, @NotNull Type type, @NotNull List<IRInstruction> instructions, @NotNull List<IRLocalVar> localVars) {

	@Override
	public String toString() {
		return type + " " + name;
	}
}
