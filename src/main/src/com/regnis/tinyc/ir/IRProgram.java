package com.regnis.tinyc.ir;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRProgram(@NotNull List<IRFunction> functions,
                        @NotNull List<IRAsmFunction> asmFunctions,
                        @NotNull IRVarInfos varInfos,
                        @NotNull List<IRStringLiteral> stringLiterals) {

	public IRProgram derive(List<IRFunction> functions) {
		return new IRProgram(functions, asmFunctions, varInfos, stringLiterals);
	}
}
