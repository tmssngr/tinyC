package com.regnis.tinyc.ir;

import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRFunction(@NotNull String name, @NotNull String label, @NotNull Type returnType, @NotNull IRVarInfos varInfos, @NotNull List<IRInstruction> instructions) {

	@NotNull
	@Override
	public String toString() {
		return returnType + " " + name;
	}

	@NotNull
	public IRFunction derive(@NotNull List<IRInstruction> instructions) {
		return derive(instructions, varInfos);
	}

	@NotNull
	public IRFunction derive(@NotNull List<IRInstruction> instructions, @NotNull IRVarInfos varInfos) {
		return new IRFunction(name, label, returnType, varInfos,
		                      instructions);
	}
}
