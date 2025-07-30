package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class LSPreprocessorCallingConventionLayer extends LSPreprocessorAbstractLayer {

	private final IRVarInfos localVarInfos;
	private final LSCallingConventionProvider callingConventionProvider;

	public LSPreprocessorCallingConventionLayer(@NotNull IRVarInfos localVarInfos, @NotNull LSCallingConventionProvider callingConventionProvider, @NotNull LSPreprocessorLayer nextLayer) {
		super(nextLayer);
		this.localVarInfos = localVarInfos;
		this.callingConventionProvider = callingConventionProvider;
	}

	@Override
	public void process(@NotNull IRInstruction instruction) {
		switch (instruction) {
		case IRCall call -> {
			final IRVar target = call.target();
			final LSCallingConvention callingConvention = callingConventionProvider.getCallingConvention(call.type(), call.getArgumentTypes());
			final Iterator<Integer> argRegisters = callingConvention.argRegisters().iterator();
			final List<IRVar> args = new ArrayList<>();
			for (IRVar arg : call.args()) {
				if (argRegisters.hasNext()) {
					final int argRegister = argRegisters.next();
					final IRVar regArg = arg.asRegister(argRegister);
					if (!localVarInfos.canBeRegister(arg)) {
						throw new UnsupportedOperationException(String.valueOf(arg));
					}

					forward(new IRMove(regArg, arg, Location.DUMMY));
					arg = regArg;
				}
				args.add(arg);
			}
			final IRVar registerTarget = target != null
					? target.asRegister(0)
					: null;
			forward(new IRCall(registerTarget, call.type(), call.name(), args, call.location()));
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
