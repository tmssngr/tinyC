package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.cfg.*;
import com.regnis.tinyc.ir.*;

import java.util.*;
import java.util.function.Function;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class LSPreprocessor {

	@NotNull
	public static Result process(@NotNull IRFunction function, @NotNull LSCallingConventionProvider callingConventionProvider, @Nullable X86Registers x86Registers) {
		final LSCallingConvention callingConvention = callingConventionProvider.getCallingConvention(function.returnType(), function.varInfos().getArgumentTypes());

		final LSTempRegisterVars tempRegisterVars = new LSTempRegisterVars(function.varInfos());

		final var resultLayer = new LSPreprocessorResultLayer();
		LSPreprocessorLayer nextLayer = new LSPreprocessorCallingConventionLayer(function.varInfos(), tempRegisterVars, callingConventionProvider, resultLayer);
		if (x86Registers != null) {
			nextLayer = new LSPreprocessorX86OperationsLayer(x86Registers, nextLayer);
		}
		final var globalVarPreprocessor = new LSPreprocessorCachedVarLayer(function.varInfos(), tempRegisterVars, nextLayer);

		final List<IRInstruction> instructions = function.instructions();
		storeRegisterArgsInVars(function.varInfos(), callingConvention.argRegisters(), instructions, globalVarPreprocessor);
		LSPreprocessorLayer.process(globalVarPreprocessor, instructions);

		final IRVarInfos varInfos = tempRegisterVars.createVarInfos();
		final Function<IRVar, IRVar> localCopyToGlobalOriginal = globalVarPreprocessor.getLocalCopyToOriginal(null);
		return new Result(varInfos, resultLayer.instructions, localCopyToGlobalOriginal);
	}

	private static void storeRegisterArgsInVars(IRVarInfos varInfos, List<Integer> argRegisters, List<IRInstruction> instructions, LSPreprocessorLayer layer) {
		final ControlFlowGraph cfg = CfgGenerator.create("name", instructions);
		DetectVarLiveness.process(cfg, varInfos.cantBeRegister(), false);
		final Set<IRVar> liveBefore = cfg.blocks().getFirst().getLiveBefore();

		for (IRVarDef def : varInfos.vars()) {
			final IRVar var = def.var();
			if (var.scope() != VariableScope.argument) {
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

	public record Result(IRVarInfos varInfos, List<IRInstruction> instructions, Function<IRVar, IRVar> localCopyToGlobalOriginal) {
	}
}
