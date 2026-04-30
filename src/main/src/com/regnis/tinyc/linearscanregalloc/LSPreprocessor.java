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
	public static Result process(List<IRInstruction> instructions, IRVarInfos varInfos, Type returnType, @NotNull LSCallingConventionProvider callingConventionProvider, boolean isX86) {
		final LSCallingConvention callingConvention = callingConventionProvider.getCallingConvention(returnType, varInfos.getArgumentTypes());

		final LSTempRegisterVars tempRegisterVars = new LSTempRegisterVars(varInfos);

		final var resultLayer = new LSPreprocessorResultLayer();
		LSPreprocessorLayer nextLayer = new LSPreprocessorCallingConventionLayer(varInfos, tempRegisterVars, callingConventionProvider, resultLayer);
		if (isX86) {
			nextLayer = new LSPreprocessorX86OperationsLayer(nextLayer);
		}
		final var globalVarPreprocessor = new LSPreprocessorCachedVarLayer(varInfos, tempRegisterVars, nextLayer);

		storeRegisterArgsInVars(varInfos, callingConvention.argRegisters(), instructions, globalVarPreprocessor);
		LSPreprocessorLayer.process(globalVarPreprocessor, instructions);

		final IRVarInfos derivedVarInfos = tempRegisterVars.createVarInfos();
		return new Result(derivedVarInfos, resultLayer.instructions);
	}

	private static void storeRegisterArgsInVars(IRVarInfos varInfos, List<Integer> argRegisters, List<IRInstruction> instructions, LSPreprocessorLayer layer) {
		final ControlFlowGraph cfg = CfgGenerator.create("name", instructions);
		DetectVarLiveness.process(cfg, varInfos.cantBeRegister(), false);
		final Set<IRVar> liveBefore = cfg.blocks().getFirst().getLiveBefore();

		for (IRVarDef def : varInfos.vars()) {
			final IRVar var = def.var();
			if (var.scope() != VariableScope.parameter) {
				continue;
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

	public record Result(IRVarInfos varInfos, List<IRInstruction> instructions) {
	}
}
