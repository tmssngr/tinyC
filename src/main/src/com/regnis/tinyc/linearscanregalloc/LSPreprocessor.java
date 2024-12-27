package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.function.Function;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class LSPreprocessor {

	@NotNull
	public static Pair<IRFunction, Function<IRVar, IRVar>> process(@NotNull IRFunction function, @NotNull LSArchitecture architecture) {
		final LSCallingConvention callingConvention = architecture.callingConvention();

		final var resultLayer = new LSPreprocessorResultLayer();
		LSPreprocessorLayer nextLayer = new LSPreprocessorCallingConventionLayer(function.varInfos(),
		                                                                         callingConvention,
		                                                                         resultLayer);
		if (architecture.isX86()) {
			nextLayer = new LSPreprocessorX86OperationsLayer(nextLayer);
		}
		final LSTempRegisterVars tempRegisterVars = new LSTempRegisterVars(function.varInfos());
		final var globalVarPreprocessor = new LSPreprocessorCachedVarLayer(function.varInfos(), tempRegisterVars, nextLayer);

		storeRegisterArgsInVars(function.varInfos(), callingConvention, globalVarPreprocessor);
		LSPreprocessorLayer.process(globalVarPreprocessor, function.instructions());

		final IRVarInfos varInfos = tempRegisterVars.createVarInfos();
		final Function<IRVar, IRVar> localCopyToGlobalOriginal = globalVarPreprocessor.getLocalCopyToOriginal(null);
		final IRFunction processedFunction = new IRFunction(function.name(), function.label(), function.returnType(), varInfos,
		                                                    resultLayer.instructions);
		return new Pair<>(processedFunction, localCopyToGlobalOriginal);
	}

	private static void storeRegisterArgsInVars(IRVarInfos varInfos, LSCallingConvention callingConvention, LSPreprocessorLayer layer) {
		final int firstArgRegister = callingConvention.firstArgRegister();
		final int argRegisterCount = callingConvention.argRegisterCount();
		for (IRVarDef def : varInfos.vars()) {
			final IRVar var = def.var();
			if (var.scope() != VariableScope.argument) {
				continue;
			}

			final int index = var.index();
			if (index >= argRegisterCount) {
				continue;
			}

			layer.process(new IRMove(var, var.asRegister(index + firstArgRegister),
			                         Location.DUMMY));
		}
	}
}
