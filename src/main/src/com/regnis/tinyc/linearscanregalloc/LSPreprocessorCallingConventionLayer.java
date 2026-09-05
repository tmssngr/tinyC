package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class LSPreprocessorCallingConventionLayer extends LSPreprocessorAbstractLayer {

	private final IRCanBeRegister canBeRegister;
	private final IRLocalVarFactory tempVarFactory;
	private final LSCallingConventionProvider callingConventionProvider;

	private int callIndex;

	public LSPreprocessorCallingConventionLayer(@NotNull IRCanBeRegister canBeRegister, @NotNull IRLocalVarFactory tempVarFactory, @NotNull LSCallingConventionProvider callingConventionProvider, @NotNull LSPreprocessorLayer nextLayer) {
		super(nextLayer);
		this.canBeRegister = canBeRegister;
		this.tempVarFactory = tempVarFactory;
		this.callingConventionProvider = callingConventionProvider;
	}

	@Override
	public void process(@NotNull IRInstruction instruction) {
		switch (instruction) {
		case IRCall call -> {
			final List<IRValue> initialArgs = call.args();
			final IRVar target = call.target();

			final List<IRValue> args = new ArrayList<>();
			final List<IRMove> stackMoves = new ArrayList<>();
			final List<IRMove> registerMoves = new ArrayList<>();
			final List<IRMove> registerLiteralMoves = new ArrayList<>();

			final LSCallingConvention callingConvention = callingConventionProvider.getCallingConvention(call.type(), call.getArgumentTypes());
			final Iterator<Integer> argRegisters = callingConvention.argRegisters().iterator();
			for (int i = 0; i < initialArgs.size(); i++) {
				final IRValue arg = initialArgs.get(i);
				final IRVar var = arg.var();
				if (argRegisters.hasNext()) {
					final int argRegister = argRegisters.next();
					if (var != null) {
						final IRVar regArg = var.asRegister(argRegister);
						if (!canBeRegister.canBeRegister(var)) {
							throw new UnsupportedOperationException(String.valueOf(var));
						}

						registerMoves.add(new IRMove(regArg, var));
						args.add(new IRValue(regArg));
					}
					else {
						final IRVar regArg = tempVarFactory.createVar(arg.type(), "arg." + callIndex + "." + i)
								.asRegister(argRegister);
						registerLiteralMoves.add(new IRMove(regArg, arg, Location.DUMMY));
						args.add(new IRValue(regArg));
					}
				}
				else {
					final IRVar stackVar = tempVarFactory.createStackArgVar(arg.type(), "arg." + callIndex + "." + i);
					if (var != null) {
						stackMoves.add(new IRMove(stackVar, var));
					}
					else {
						final IRVar tmp = tempVarFactory.createVar(arg.type(), "argLit." + callIndex + "." + i)
								.asRegister(0);
						stackMoves.add(new IRMove(tmp, arg.value()));
						stackMoves.add(new IRMove(stackVar, tmp));
					}
					args.add(new IRValue(stackVar));
				}
			}

			stackMoves.forEach(this::forward);
			registerMoves.forEach(this::forward);
			registerLiteralMoves.forEach(this::forward);

			final IRVar registerTarget = target != null
					? target.asRegister(0)
					: null;
			forward(new IRCall(registerTarget, call.type(), call.name(), args, call.location()));
			if (target != null) {
				forward(new IRMove(target, registerTarget));
			}
			callIndex++;
		}
		case IRRetValue retValue -> {
			final IRVar regArg = retValue.var().asRegister(0);
			forward(new IRMove(regArg, retValue.var(), retValue.location()));
		}
		default -> forward(instruction);
		}
	}
}
