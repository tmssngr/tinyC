package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class LSPreprocessorCallingConventionLayer extends LSPreprocessorAbstractLayer {

	private final IRVarInfos localVarInfos;
	private final int firstArgRegister;
	private final int argRegisterCount;

	public LSPreprocessorCallingConventionLayer(@NotNull IRVarInfos localVarInfos, @NotNull LSCallingConvention callingConvention, @NotNull LSPreprocessorLayer nextLayer) {
		super(nextLayer);
		this.localVarInfos = localVarInfos;
		firstArgRegister = callingConvention.firstArgRegister();
		argRegisterCount = callingConvention.argRegisterCount();
	}

	@Override
	public void process(@NotNull IRInstruction instruction) {
		switch (instruction) {
		case IRCall call -> {
			final List<IRVar> args = new ArrayList<>();
			int i = 0;
			for (IRVar arg : call.args()) {
				if (i < argRegisterCount) {
					final IRVar regArg = arg.asRegister(i + firstArgRegister);
					if (localVarInfos.canBeRegister(arg)) {
						forward(new IRMove(regArg, arg, Location.DUMMY));
					}
					else {
						throw new UnsupportedOperationException(String.valueOf(arg));
					}
					arg = regArg;
				}
				args.add(arg);
				i++;
			}
			final IRVar target = call.target();
			final IRVar registerTarget = target != null
					? target.asRegister(0)
					: null;
			forward(new IRCall(registerTarget, call.name(), args, call.location()));
			if (target != null) {
				forward(new IRMove(target, registerTarget, Location.DUMMY));
			}
		}
		case IRRetValue retValue -> {
			final IRVar regArg = retValue.var().asRegister(0);
			forward(new IRMove(regArg, retValue.var(), retValue.location()));
		}
		default -> forward(instruction);
		}
	}
}
