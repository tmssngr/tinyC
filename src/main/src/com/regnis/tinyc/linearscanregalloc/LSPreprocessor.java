package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.cfg.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class LSPreprocessor {

	@NotNull
	public static Pair<IRVarInfos, List<IRInstruction>> process(@NotNull IRFunction function, @NotNull LSCallingConventionProvider callingConventionProvider, boolean isX86, Type pointerIntType) {
		final LSCallingConvention callingConvention = callingConventionProvider.getCallingConvention(function.returnType(), function.varInfos().getArgumentTypes());

		final IRLocalVarFactory tempVarFactory = new IRLocalVarFactory(function.varInfos(), pointerIntType);

		final var resultLayer = new LSPreprocessorResultLayer();
		LSPreprocessorLayer nextLayer = new LSPreprocessorCallingConventionLayer(function.varInfos(), tempVarFactory, callingConventionProvider, resultLayer);
		if (isX86) {
			nextLayer = new LSPreprocessorX86OperationsLayer(nextLayer);
		}

		// storing register parameters on the stack is done before the global var handler
		// because this store is not considered a modification (for later save again); see `printChar`
		final List<IRInstruction> instructions = function.instructions();
		storeRegisterArgsInVars(function.varInfos(), callingConvention.argRegisters(), instructions, nextLayer);

		final var globalVarPreprocessor = new LSPreprocessorCachedVarLayer(function.varInfos(), tempVarFactory, nextLayer);
		LSPreprocessorLayer.process(globalVarPreprocessor, instructions);

		final IRVarInfos varInfos = tempVarFactory.createVarInfos();
		return new Pair<>(varInfos, resultLayer.instructions);
	}

	private static void storeRegisterArgsInVars(IRVarInfos varInfos, List<Integer> argRegisters, List<IRInstruction> instructions, LSPreprocessorLayer layer) {
		final ControlFlowGraph cfg = CfgGenerator.create("name", instructions);
		DetectVarLiveness.process(cfg, varInfos.cantBeRegister(), false);
		final Set<IRVar> liveBefore = cfg.blocks().getFirst().getLiveBefore();

		for (IRVarDef def : varInfos.vars()) {
			final IRVar var = def.var();
			if (var.scope() != VariableScope.parameter) {
				break;
			}

			if (!liveBefore.contains(var)) {
				continue;
			}

			final int index = var.index();
			if (index >= argRegisters.size()) {
				continue;
			}

			final int argRegister = argRegisters.get(index);
			layer.process(new IRMove(var, var.asRegister(argRegister),
			                         Location.DUMMY));
		}
	}
}
