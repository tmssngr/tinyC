package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;
import java.util.function.Function;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class LSPreprocessor {

	@NotNull
	public static Result process(@NotNull IRFunction function, @NotNull LSCallingConventionProvider callingConventionProvider, boolean isX86) {
		final LSCallingConvention callingConvention = callingConventionProvider.getCallingConvention(function.returnType(), function.varInfos().getArgumentTypes());

		final var resultLayer = new LSPreprocessorResultLayer();
		LSPreprocessorLayer nextLayer = new LSPreprocessorCallingConventionLayer(function.varInfos(), callingConventionProvider, resultLayer);
		if (isX86) {
			nextLayer = new LSPreprocessorX86OperationsLayer(nextLayer);
		}
		final LSTempRegisterVars tempRegisterVars = new LSTempRegisterVars(function.varInfos());
		final var globalVarPreprocessor = new LSPreprocessorCachedVarLayer(function.varInfos(), tempRegisterVars, nextLayer);

		storeRegisterArgsInVars(function.varInfos(), callingConvention.argRegisters(), globalVarPreprocessor);
		LSPreprocessorLayer.process(globalVarPreprocessor, function.instructions());

		final IRVarInfos varInfos = tempRegisterVars.createVarInfos();
		final Function<IRVar, IRVar> localCopyToGlobalOriginal = globalVarPreprocessor.getLocalCopyToOriginal(null);
		return new Result(varInfos, resultLayer.instructions, localCopyToGlobalOriginal);
	}

	private static void storeRegisterArgsInVars(IRVarInfos varInfos, List<Integer> argRegisters, LSPreprocessorLayer layer) {
		for (IRVarDef def : varInfos.vars()) {
			final IRVar var = def.var();
			if (var.scope() != VariableScope.argument) {
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

	public record Result(IRVarInfos varInfos, List<IRInstruction> instructions, Function<IRVar, IRVar> localCopyToGlobalOriginal) {
	}
}
