package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public class CleanupGlobalUnusedVariables {

	public static IRProgram process(IRProgram program) {
		final Set<Integer> readGlobalVars = new HashSet<>();
		final VarUseTracker varUseTracker = new VarUseTracker(new VarUseTracker.Handler() {
			@Override
			public void read(@NotNull IRVar var) {
				if (var.scope() == VariableScope.global) {
					readGlobalVars.add(var.index());
				}
			}
		});
		for (IRFunction function : program.functions()) {
			varUseTracker.process(function.instructions());
		}

		final GlobalVarReplacer replacer = new GlobalVarReplacer(program.varInfos(), readGlobalVars);
		final List<IRFunction> functions = new ArrayList<>();
		for (IRFunction function : program.functions()) {
			functions.add(replaceGlobalVars(function, replacer));
		}
		return new IRProgram(functions, program.asmFunctions(), replacer.newVarInfos, program.stringLiterals());
	}

	private static IRFunction replaceGlobalVars(IRFunction function, GlobalVarReplacer replacer) {
		if (function.instructions().isEmpty()) {
			return function;
		}

		final List<IRInstruction> instructions = new ArrayList<>();
		for (IRInstruction instruction : function.instructions()) {
			final IRInstruction replacedInstruction = replacer.replace(instruction);
			if (replacedInstruction != null) {
				instructions.add(replacedInstruction);
			}
		}

		final IRVarInfos varInfos = function.varInfos().derive(replacer.newVarInfos);
		return derive(function, instructions, varInfos);
	}

	@NotNull
	private static IRFunction derive(IRFunction function, List<IRInstruction> instructions, IRVarInfos varInfos) {
		return new IRFunction(function.name(), function.returnType(), varInfos, instructions);
	}

	private static final class GlobalVarReplacer extends IRVarReplacer {
		private final Map<IRVar, IRVar> oldToNewVar = new HashMap<>();
		private final IRVarInfos newVarInfos;

		public GlobalVarReplacer(IRVarInfos varInfos, Set<Integer> readGlobalVars) {
			newVarInfos = varInfos.removeIf(var -> !readGlobalVars.contains(var.index()), null, oldToNewVar);
		}

		@NotNull
		@Override
		protected IRVar replace(@NotNull IRVar var) {
			if (var.scope() != VariableScope.global) {
				return var;
			}

			return oldToNewVar.get(var);
		}

		@Nullable
		public IRInstruction replace(@NotNull IRInstruction instruction) {
			switch (instruction) {
			case IRString literal -> {
				final IRVar target = literal.target();
				if (isUnusedGlobal(target)) {
					return null;
				}
			}
			case IRMove move -> {
				final IRVar target = move.target();
				if (isUnusedGlobal(target)) {
					return null;
				}
			}
			case IRBinary binary -> {
				final IRVar target = binary.target();
				if (isUnusedGlobal(target)) {
					return null;
				}
			}
			case IRUnary unary -> {
				final IRVar target = unary.target();
				if (isUnusedGlobal(target)) {
					return null;
				}
			}
			case IRCast unary -> {
				final IRVar target = unary.target();
				if (isUnusedGlobal(target)) {
					return null;
				}
			}
			case IRMemLoad load -> {
				final IRVar target = load.target();
				if (isUnusedGlobal(target)) {
					return null;
				}
			}
			case IRCall call -> {
				final IRVar target = call.target();
				if (target != null && isUnusedGlobal(target)) {
					final IRCall modifiedCall = (IRCall)replaceFor(instruction);
					return new IRCall(null, call.type(), modifiedCall.name(), modifiedCall.args(), modifiedCall.location());
				}
			}
			default -> {
			}
			}
			return replaceFor(instruction);
		}

		private boolean isUnusedGlobal(IRVar target) {
			return target.scope() == VariableScope.global
			       && !oldToNewVar.containsKey(target);
		}
	}
}
