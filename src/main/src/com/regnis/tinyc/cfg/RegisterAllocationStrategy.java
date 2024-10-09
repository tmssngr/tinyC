package com.regnis.tinyc.cfg;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;
import java.util.function.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class RegisterAllocationStrategy {

	public static final AllLiveVarRegisterState EMPTY_STATE = new AllLiveVarRegisterState(List.of());

	static final int CALL_RETURN_REG = 0;
	static final int CALL_ARG_0 = 1;
	static final int CALL_ARG_1 = 2;
	static final int FIRST_NON_VOLATILE_REGISTER = 4;
	static final int NON_VOLATILE_REGISTER0 = FIRST_NON_VOLATILE_REGISTER;
	static final int NON_VOLATILE_REGISTER1 = NON_VOLATILE_REGISTER0 + 1;
	static final int LAST_NON_VOLATILE_REGISTER = NON_VOLATILE_REGISTER1;

	@NotNull
	public AllLiveVarRegisterState prevState(@NotNull AllLiveVarRegisterState prevState, @Nullable IRVar target, @NotNull List<IRVar> args, @NotNull Consumer<IRInstruction> consumer) {
		final List<LiveVarRegisterState> liveVars = new ArrayList<>(prevState.vars);

		if (target != null) {
			final LiveVarRegisterState state = get(target, liveVars);
			if (state != null) {
				liveVars.remove(state);
				Utils.assertTrue(state.registers.size() == 1); // just this case is covered for now
				final int register = state.registers.getFirst();
				if (register != CALL_RETURN_REG) {
					move(target.name(), CALL_RETURN_REG, register, target.type(), consumer);
				}
			}
		}

		for (int i = 0; i < liveVars.size(); i++) {
			final LiveVarRegisterState var = liveVars.get(i);
			final List<Integer> registers = new ArrayList<>(var.registers);
			final List<Integer> volatileRegisters = new ArrayList<>();
			for (final Iterator<Integer> iterator = registers.iterator(); iterator.hasNext(); ) {
				final Integer register = iterator.next();
				if (isVolatile(register)) {
					volatileRegisters.add(register);
					iterator.remove();
				}
				else {
					throw new IllegalStateException();
				}
			}
			for (Integer register : volatileRegisters) {
				final int nvReg = getFreeNonVolatileRegister(liveVars);
				move(var.name, nvReg, register, var.type, consumer);
				registers.add(nvReg);
			}
			liveVars.set(i, var.derive(registers));
		}

		int argReg = 1;
		for (int i = 0; i < args.size(); i++, argReg++) {
			final IRVar arg = args.get(i);
			if (i < 4) {
				final LiveVarRegisterState state = get(arg, liveVars);
				if (state != null) {
					liveVars.remove(state);
					final List<Integer> registers = new ArrayList<>(state.registers);
					registers.add(argReg);
					liveVars.add(new LiveVarRegisterState(arg.name(), arg.index(), arg.scope(), arg.type(), List.copyOf(registers)));
				}
				else {
					liveVars.add(new LiveVarRegisterState(arg.name(), arg.index(), arg.scope(), arg.type(), List.of(argReg)));
				}
			}
			else {
				consumer.accept(IRMemStore.push(arg));
			}
		}
		return new AllLiveVarRegisterState(liveVars);
	}

	private int getFreeNonVolatileRegister(List<LiveVarRegisterState> vars) {
		final Set<Integer> usedNonVolatileRegisters = new HashSet<>();
		for (LiveVarRegisterState var : vars) {
			for (Integer register : var.registers) {
				if (!isVolatile(register)) {
					usedNonVolatileRegisters.add(register);
				}
			}
		}

		for (int register = FIRST_NON_VOLATILE_REGISTER; register <= LAST_NON_VOLATILE_REGISTER; register++) {
			if (!usedNonVolatileRegisters.contains(register)) {
				return register;
			}
		}
		return -1;
	}

	private boolean isVolatile(int register) {
		return register < FIRST_NON_VOLATILE_REGISTER;
	}

	@Nullable
	private LiveVarRegisterState get(IRVar var, List<LiveVarRegisterState> states) {
		for (LiveVarRegisterState state : states) {
			if (state.index == var.index()
			    && state.scope == var.scope()) {
				Utils.assertTrue(state.type == var.type());
				return state;
			}
		}
		return null;
	}

	private static void move(String name, int from, int to, Type type, @NotNull Consumer<IRInstruction> consumer) {
		consumer.accept(new IRCopy(new IRVar(name, from, VariableScope.register, type, true),
		                           new IRVar(name, to, VariableScope.register, type, true),
		                           Location.DUMMY));
	}

	public record AllLiveVarRegisterState(@NotNull List<LiveVarRegisterState> vars) {
	}

	public record LiveVarRegisterState(@NotNull String name, int index, @NotNull VariableScope scope, @NotNull Type type, List<Integer> registers) {
		@NotNull
		public LiveVarRegisterState derive(List<Integer> registers) {
			return new LiveVarRegisterState(name, index, scope, type, List.copyOf(registers));
		}
	}
}
