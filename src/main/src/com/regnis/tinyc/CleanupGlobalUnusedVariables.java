package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public class CleanupGlobalUnusedVariables extends CleanupUnusedVariables {

	public static IRProgram process(IRProgram program) {
		final CleanupGlobalUnusedVariables cleanup = new CleanupGlobalUnusedVariables();
		for (IRFunction function : program.functions()) {
			cleanup.process(function);
		}

		final GlobalVarReplacer replacer = new GlobalVarReplacer(program.globalVars(), cleanup.readGlobalVars);
		final List<IRFunction> functions = new ArrayList<>();
		for (IRFunction function : program.functions()) {
			functions.add(cleanup.replaceGlobalVars(function, replacer));
		}
		return new IRProgram(functions, replacer.globalVars, program.stringLiterals());
	}

	private final Set<Integer> readGlobalVars = new HashSet<>();

	private CleanupGlobalUnusedVariables() {
	}

	protected void process(IRVar var, boolean read) {
		if (read && var.scope() == VariableScope.global) {
			readGlobalVars.add(var.index());
		}
	}

	private void process(IRFunction function) {
		for (IRInstruction instruction : function.instructions()) {
			process(instruction);
		}
	}

	private IRFunction replaceGlobalVars(IRFunction function, GlobalVarReplacer replacer) {
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

		return derive(function, instructions, function.localVars());
	}

	@NotNull
	private IRFunction derive(IRFunction function, List<IRInstruction> instructions, List<IRLocalVar> localVars) {
		return new IRFunction(function.name(), function.label(), function.returnType(), localVars, instructions, List.of());
	}

	private static final class GlobalVarReplacer extends IRVarReplacer {
		private final int[] newGlobalVarIndices;
		private final List<IRGlobalVar> globalVars;

		public GlobalVarReplacer(List<IRGlobalVar> globalVars, Set<Integer> readGlobalVars) {
			newGlobalVarIndices = new int[globalVars.size()];
			Arrays.fill(newGlobalVarIndices, -1);

			this.globalVars = new ArrayList<>();

			int newIndex = 0;
			for (IRGlobalVar var : globalVars) {
				if (!readGlobalVars.contains(var.index())) {
					continue;
				}

				newGlobalVarIndices[var.index()] = newIndex;
				this.globalVars.add(new IRGlobalVar(var.name(), newIndex, var.size()));
				newIndex++;
			}
		}

		@NotNull
		@Override
		protected IRVar replace(@NotNull IRVar var) {
			if (var.scope() != VariableScope.global) {
				return var;
			}

			final int newIndex = newGlobalVarIndices[var.index()];
			Utils.assertTrue(newIndex >= 0);
			return new IRVar(var.name(), newIndex, var.scope(), var.type(), var.canBeRegister());
		}

		@Nullable
		public IRInstruction replace(@NotNull IRInstruction instruction) {
			switch (instruction) {
			case IRLiteral literal -> {
				final IRVar target = literal.target();
				if (isUnusedGlobal(target)) {
					return null;
				}
			}
			case IRString literal -> {
				final IRVar target = literal.target();
				if (isUnusedGlobal(target)) {
					return null;
				}
			}
			case IRCopy copy -> {
				final IRVar target = copy.target();
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
					return new IRCall(null, modifiedCall.name(), modifiedCall.args(), modifiedCall.location());
				}
			}
			default -> {
			}
			}
			return replaceFor(instruction);
		}

		private boolean isUnusedGlobal(IRVar target) {
			return target.scope() == VariableScope.global
			       && newGlobalVarIndices[target.index()] < 0;
		}
	}
}
