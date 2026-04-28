package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRFunction(@NotNull String name, @NotNull String label, @NotNull Type returnType, @NotNull IRVarInfos varInfos, @NotNull List<IRInstruction> instructions) {

	public static void checkInstructions(@NotNull List<IRInstruction> instructions) {
		boolean expectLabel = false;
		for (IRInstruction instruction : instructions) {
			if (instruction instanceof IRLabel) {
				expectLabel = false;
				continue;
			}

			Utils.assertTrue(!expectLabel, () -> "Expected label, but got " + instruction);
			expectLabel = instruction instanceof IRJump;
		}
	}

	public IRFunction {
		checkInstructions(instructions);
	}

	@Override
	public String toString() {
		return returnType + " " + name;
	}

	@NotNull
	public IRFunction derive(List<IRInstruction> instructions) {
		return new IRFunction(name, label, returnType, varInfos,
		                      instructions);
	}
}
