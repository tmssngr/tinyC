package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public class CleanupLocalUnusedVariables extends CleanupUnusedVariables {

	public static IRFunction optimize(IRFunction function) {
		final CleanupLocalUnusedVariables cleanup = new CleanupLocalUnusedVariables();
		return cleanup.process(function);
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
		collectUsedVars(function.instructions());

		final LocalVarReplacer replacer = new LocalVarReplacer(function.varInfos(), usedFunctionVars);

		final List<IRInstruction> instructions = new ArrayList<>();
		for (IRInstruction instruction : function.instructions()) {
			instructions.add(replacer.replaceFor(instruction));
		}
		return derive(function, instructions, replacer.newVarInfos);
	}

	private void collectUsedVars(List<IRInstruction> instructions) {
		for (IRInstruction instruction : instructions) {
			process(instruction);
		}
	}

	@NotNull
	private IRFunction derive(IRFunction function, List<IRInstruction> instructions, IRVarInfos varInfos) {
		return new IRFunction(function.name(), function.label(), function.returnType(), varInfos, instructions);
	}

	private static final class LocalVarReplacer extends IRVarReplacer {
		private final Map<IRVar, IRVar> oldToNewVar = new HashMap<>();
		private final IRVarInfos newVarInfos;

		public LocalVarReplacer(IRVarInfos varInfos, Set<Integer> usedFunctionVars) {
			final List<IRVarDef> localVars = varInfos.vars();

			final List<IRVarDef> newLocalVars = new ArrayList<>();
			final Set<IRVar> newCantBeRegister = new HashSet<>();

			int newIndex = 0;
			for (IRVarDef def : localVars) {
				final IRVar var = def.var();
				if (var.scope() == VariableScope.argument) {
					oldToNewVar.put(var, var);
					newLocalVars.add(def);
					newIndex++;
					continue;
				}

				if (!usedFunctionVars.contains(var.index())) {
					continue;
				}

				final IRVar newVar = new IRVar(var.name(), newIndex, var.scope(), var.type());
				oldToNewVar.put(var, newVar);
				if (!varInfos.canBeRegister(var)) {
					newCantBeRegister.add(newVar);
				}

				newLocalVars.add(new IRVarDef(newVar, def.size(), def.isArray()));

				newIndex++;
			}

			newVarInfos = new IRVarInfos(newLocalVars, newCantBeRegister, Objects.requireNonNull(varInfos.global()));
		}

		@NotNull
		@Override
		protected IRVar replace(@NotNull IRVar var) {
			if (var.scope() != VariableScope.function) {
				return var;
			}

			return oldToNewVar.get(var);
		}
	}
}
