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
	private final IRLocalVarFactory tempVarFactory;
	private final LSCallingConventionProvider callingConventionProvider;

	private int callIndex;

	public LSPreprocessorCallingConventionLayer(@NotNull IRVarInfos localVarInfos, @NotNull IRLocalVarFactory tempVarFactory, @NotNull LSCallingConventionProvider callingConventionProvider, @NotNull LSPreprocessorLayer nextLayer) {
		super(nextLayer);
		this.localVarInfos = localVarInfos;
		this.tempVarFactory = tempVarFactory;
		this.callingConventionProvider = callingConventionProvider;
	}

	@Override
	public void process(@NotNull IRInstruction instruction) {
		switch (instruction) {
		case IRCall call -> {
			final List<IRVar> initialArgs = call.args();
			final IRVar target = call.target();

			final List<IRVar> args = new ArrayList<>();
			final List<IRMove> registerMoves = new ArrayList<>();
			final List<IRMove> stackMoves = new ArrayList<>();

			final LSCallingConvention callingConvention = callingConventionProvider.getCallingConvention(call.type(), call.getArgumentTypes());
			final Iterator<Integer> argRegisters = callingConvention.argRegisters().iterator();
			for (int i = 0; i < initialArgs.size(); i++) {
				final IRVar arg = initialArgs.get(i);
				if (argRegisters.hasNext()) {
					final int argRegister = argRegisters.next();
					final IRVar regArg = arg.asRegister(argRegister);
					if (!localVarInfos.canBeRegister(arg)) {
						throw new UnsupportedOperationException(String.valueOf(arg));
					}

					registerMoves.add(new IRMove(regArg, arg));
					args.add(regArg);
				}
				else {
					final IRVar stackVar = tempVarFactory.createStackArgVar(arg, "arg." + callIndex + "." + i);
					stackMoves.add(new IRMove(stackVar, arg));
					args.add(stackVar);
				}
			}

			stackMoves.forEach(this::forward);
			registerMoves.forEach(this::forward);

			final IRVar registerTarget = target != null
					? target.asRegister(0)
					: null;
			forward(new IRCall(registerTarget, call.type(), call.name(), args, call.location()));
			if (target != null) {
				forward(new IRMove(target, registerTarget));
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
