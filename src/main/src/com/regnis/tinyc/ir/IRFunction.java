package com.regnis.tinyc.ir;

import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRFunction(@NotNull String name, @NotNull String label, @NotNull Type returnType, @NotNull List<IRVarDef> localVars, @NotNull List<IRInstruction> instructions, List<String> asmLines) {

	@Override
	public String toString() {
		return returnType + " " + name;
	}

	@NotNull
	public IRFunction derive(List<IRInstruction> instructions) {
		return new IRFunction(name(), label(), returnType(), localVars(),
		                      instructions, List.of());
	}
}
