package com.regnis.tinyc.ir;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRProgram(@NotNull List<IRFunction> functions,
                        @NotNull List<IRVarDef> globalVars,
                        @NotNull List<IRStringLiteral> stringLiterals) {

	public IRProgram derive(List<IRFunction> functions) {
		return new IRProgram(functions, globalVars, stringLiterals);
	}
}
