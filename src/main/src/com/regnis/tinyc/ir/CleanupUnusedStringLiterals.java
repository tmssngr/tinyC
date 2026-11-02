package com.regnis.tinyc.ir;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class CleanupUnusedStringLiterals {
	@NotNull
	public static IRProgram process(@NotNull IRProgram program) {
		final Set<Integer> usedStringLiteralIndices = new HashSet<>();
		for (IRFunction function : program.functions()) {
			for (IRInstruction instruction : function.instructions()) {
				if (instruction instanceof IRString string) {
					usedStringLiteralIndices.add(string.stringIndex());
				}
			}
		}

		final List<IRStringLiteral> stringLiterals = new ArrayList<>();
		for (IRStringLiteral literal : program.stringLiterals()) {
			if (usedStringLiteralIndices.contains(literal.index())) {
				stringLiterals.add(literal);
			}
		}

		return new IRProgram(program.functions(), program.asmFunctions(), program.varInfos(),
		                     stringLiterals);
	}
}
