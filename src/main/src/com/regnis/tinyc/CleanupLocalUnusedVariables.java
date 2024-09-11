package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public class CleanupLocalUnusedVariables extends CleanupUnusedVariables {

	public static IRProgram process(IRProgram program) {
		final CleanupLocalUnusedVariables command = new CleanupLocalUnusedVariables();
		final List<IRFunction> functions = new ArrayList<>();
		for (IRFunction function : program.functions()) {
			functions.add(command.process(function));
		}

		return new IRProgram(functions, program.globalVars(), program.stringLiterals());
	}

	private final Set<Integer> usedFunctionVars = new HashSet<>();

	private CleanupLocalUnusedVariables() {
	}

	protected void process(IRVar var, boolean read) {
		if (var.scope() == VariableScope.function) {
			usedFunctionVars.add(var.index());
		}
	}

	private IRFunction process(IRFunction function) {
		if (function.instructions().isEmpty()) {
			return function;
		}

		usedFunctionVars.clear();
		for (IRInstruction instruction : function.instructions()) {
			process(instruction);
		}

		final LocalVarReplacer replacer = new LocalVarReplacer(function.localVars(), usedFunctionVars);

		final List<IRInstruction> instructions = new ArrayList<>();
		for (IRInstruction instruction : function.instructions()) {
			instructions.add(replacer.replaceFor(instruction));
		}
		return derive(function, instructions, replacer.localVars);
	}

	@NotNull
	private IRFunction derive(IRFunction function, List<IRInstruction> instructions, List<IRLocalVar> localVars) {
		return new IRFunction(function.name(), function.label(), function.returnType(), localVars, instructions, List.of());
	}

	private static final class LocalVarReplacer extends IRVarReplacer {
		private final int[] newFunctionVarIndices;
		private final List<IRLocalVar> localVars;

		public LocalVarReplacer(List<IRLocalVar> localVars, Set<Integer> usedFunctionVars) {
			newFunctionVarIndices = new int[localVars.size()];
			Arrays.fill(newFunctionVarIndices, -1);

			this.localVars = new ArrayList<>();

			int newIndex = 0;
			for (IRLocalVar var : localVars) {
				if (var.isArg()) {
					this.localVars.add(var);
					newIndex++;
					continue;
				}

				if (!usedFunctionVars.contains(var.index())) {
					continue;
				}

				newFunctionVarIndices[var.index()] = newIndex;
				this.localVars.add(new IRLocalVar(var.name(), newIndex, false, var.size()));

				newIndex++;
			}
		}

		@NotNull
		@Override
		protected IRVar replace(@NotNull IRVar var) {
			if (var.scope() != VariableScope.function) {
				return var;
			}

			final int newIndex = newFunctionVarIndices[var.index()];
			Utils.assertTrue(newIndex >= 0);
			return new IRVar(var.name(), newIndex, var.scope(), var.type(), var.canBeRegister());
		}
	}
}
