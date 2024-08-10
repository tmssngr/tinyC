package com.regnis.tinyc.ir;

import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRFunction(@NotNull String name, @NotNull String label, @NotNull Type returnType, @NotNull List<IRLocalVar> localVars, @NotNull List<IRInstruction> instructions, List<String> asmLines) {

	@Override
	public String toString() {
		return returnType + " " + name;
	}
}
