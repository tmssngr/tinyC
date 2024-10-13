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

	private final List<LiveVarRegisterState> liveVars = new ArrayList<>();
	private final int maxArgsInRegisters;
	private final int firstNonVolatileRegister;
	private final int maxRegisters;

	public RegisterAllocationStrategy(int maxArgsInRegisters, int additionalVolatileRegisters, int nonVolatileRegisters) {
		Utils.assertTrue(maxArgsInRegisters >= 0);
		Utils.assertTrue(additionalVolatileRegisters >= 0);
		Utils.assertTrue(nonVolatileRegisters > 0);
		this.maxArgsInRegisters = maxArgsInRegisters;
		firstNonVolatileRegister = CALL_ARG_0 + maxArgsInRegisters + additionalVolatileRegisters;
		maxRegisters = firstNonVolatileRegister + nonVolatileRegisters;
	}

	int nonVolatile(int i) {
		return firstNonVolatileRegister + i;
	}

	public AllLiveVarRegisterState getState() {
		return new AllLiveVarRegisterState(liveVars);
	}

	public void setState(@NotNull AllLiveVarRegisterState state) {
		liveVars.clear();
		liveVars.addAll(state.vars);
	}

	public List<IRVar> prepareCallArgs(@NotNull List<IRVar> args, @NotNull Consumer<IRInstruction> consumer) {
		final List<IRVar> newArgs = new ArrayList<>();
		int argReg = CALL_ARG_0;
		for (int i = 0; i < args.size(); i++, argReg++) {
			final IRVar arg = args.get(i);
			final int register = i < maxArgsInRegisters
					? argReg
					: getFreeRegister();
			final IRVar newVar = addLiveVar(register, arg);
			newArgs.add(newVar);
		}
		return newArgs;
	}

	public void freeVolatileRegisters(@NotNull Consumer<IRInstruction> consumer) {
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
				final int nvReg = getFreeNonVolatileRegister();
				movRegFromReg(var.var(), register, nvReg, consumer);
				registers.add(nvReg);
			}
			liveVars.set(i, var.derive(registers));
		}
	}

	public void freeRegister(int targetRegister, @NotNull IRVar allowed, @NotNull Predicate<Integer> registerPredicate, @NotNull Consumer<IRInstruction> consumer) {
		final LiveVarRegisterState state = get(targetRegister);
		if (state == null || state.var().equals(allowed)) {
			return;
		}

		liveVars.remove(state);
		final List<Integer> newRegisters = new ArrayList<>(state.registers.size());
		int preferredRegister = -1;
		for (int register : state.registers) {
			if (register == targetRegister || !registerPredicate.test(register)) {
				continue;
			}

			newRegisters.add(register);
			if (preferredRegister < 0) {
				preferredRegister = register;
			}
		}
		if (preferredRegister < 0) {
			preferredRegister = getFreeRegister(registerPredicate);
			if (preferredRegister >= 0) {
				newRegisters.add(preferredRegister);
			}
		}
		liveVars.add(state.derive(newRegisters));

		if (preferredRegister >= 0) {
			final IRVar source = reg(preferredRegister, state.var());
			for (int register : state.registers) {
				if (register != preferredRegister) {
					movRegFromVar(register, source, consumer);
				}
			}
		}
		else {
			IRVar registerVar = null;
			int varInRegister = 0;
			for (int register : state.registers) {
				if (registerVar == null) {
					registerVar = reg(register, state.var());
					varInRegister = register;
				}
				else {
					movRegFromVar(register, registerVar, consumer);
				}
			}
			movRegFromVar(varInRegister, state.var(), consumer);
		}
	}

	@NotNull
	public IRVar target(IRVar target, Consumer<IRInstruction> consumer) {
		final LiveVarRegisterState state = remove(target);
		int preferredRegister = -1;
		for (int register : state.registers) {
			if (preferredRegister < 0) {
				preferredRegister = register;
				if (isVolatile(register)) {
					break;
				}
			}
			else if (isVolatile(register)) {
				preferredRegister = register;
				break;
			}
		}
		if (preferredRegister >= 0) {
			for (int register : state.registers) {
				if (register != preferredRegister) {
					movRegFromReg(state.var(), register, preferredRegister, consumer);
				}
			}
		}
		else {
			preferredRegister = CALL_RETURN_REG;
			movVarFromReg(target, preferredRegister, consumer);
		}
		return reg(preferredRegister, state.var());
	}

	@NotNull
	public IRVar callTarget(@NotNull IRVar target, @NotNull Consumer<IRInstruction> consumer) {
		freeRegister(CALL_RETURN_REG, target, register -> !isVolatile(register), consumer);

		final LiveVarRegisterState state = remove(target);
		if (state.registers.isEmpty()) {
			movVarFromReg(target, CALL_RETURN_REG, consumer);
		}
		else {
			for (int register : state.registers) {
				if (register != CALL_RETURN_REG) {
					movRegFromReg(state.var(), register, CALL_RETURN_REG, consumer);
				}
			}
		}
		return new IRVar(target.name(), CALL_RETURN_REG, VariableScope.register, target.type(), target.canBeRegister());
	}

	@NotNull
	private IRVar addLiveVar(int register, IRVar var) {
		Utils.assertTrue(var.scope() != VariableScope.register);

		final List<Integer> registers = new ArrayList<>();
		if (register >= 0) {
			registers.add(register);
		}
		final LiveVarRegisterState state = get(var);
		if (state != null) {
			liveVars.remove(state);
			registers.addAll(state.registers);
		}
		liveVars.add(new LiveVarRegisterState(var, List.copyOf(registers)));
		return register >= 0
				? new IRVar(var.name(), register, VariableScope.register, var.type(), var.canBeRegister())
				: var;
	}

	private int getFreeNonVolatileRegister() {
		return getFreeRegister(register -> !isVolatile(register));
	}

	private int getFreeRegister() {
		return getFreeRegister(register -> true);
	}

	private int getFreeRegister(Predicate<Integer> predicate) {
		final Set<Integer> usedRegisters = getUsedRegisters(predicate);

		for (int register = CALL_ARG_0; register < maxRegisters; register++) {
			if (!usedRegisters.contains(register)
			    && predicate.test(register)) {
				return register;
			}
		}
		return -1;
	}

	@NotNull
	private Set<Integer> getUsedRegisters(Predicate<Integer> predicate) {
		final Set<Integer> usedRegisters = new HashSet<>();
		for (LiveVarRegisterState var : liveVars) {
			for (Integer register : var.registers) {
				if (predicate.test(register)) {
					usedRegisters.add(register);
				}
			}
		}
		return usedRegisters;
	}

	private boolean isVolatile(int register) {
		return register < firstNonVolatileRegister;
	}

	@NotNull
	private LiveVarRegisterState remove(IRVar target) {
		final LiveVarRegisterState state = getNotNull(target);
		liveVars.remove(state);
		return state;
	}

	@NotNull
	private LiveVarRegisterState getNotNull(@NotNull IRVar var) {
		return Objects.requireNonNull(get(var));
	}

	@Nullable
	private LiveVarRegisterState get(@NotNull IRVar var) {
		for (LiveVarRegisterState state : liveVars) {
			if (state.var().equals(var)) {
				return state;
			}
		}
		return null;
	}

	@Nullable
	private LiveVarRegisterState get(int reg) {
		for (LiveVarRegisterState var : liveVars) {
			if (var.registers.contains(reg)) {
				return var;
			}
		}
		return null;
	}

	private static void movVarFromReg(IRVar to, int from, Consumer<IRInstruction> consumer) {
		consumer.accept(new IRCopy(to,
		                           reg(from, to),
		                           Location.DUMMY));
	}

	private static void movRegFromVar(int to, IRVar from, Consumer<IRInstruction> consumer) {
		consumer.accept(new IRCopy(reg(to, from),
		                           from,
		                           Location.DUMMY));
	}

	private static void movRegFromReg(IRVar var, int to, int from, @NotNull Consumer<IRInstruction> consumer) {
		consumer.accept(new IRCopy(reg(to, var),
		                           reg(from, var),
		                           Location.DUMMY));
	}

	private static IRVar reg(int register, @NotNull IRVar var) {
		Utils.assertTrue(register >= 0);
		return new IRVar(var.name(), register, VariableScope.register, var.type(), var.canBeRegister());
	}

	public record AllLiveVarRegisterState(@NotNull List<LiveVarRegisterState> vars) {
	}

	public record LiveVarRegisterState(@NotNull IRVar var, List<Integer> registers) {
		@NotNull
		public LiveVarRegisterState derive(List<Integer> registers) {
			return new LiveVarRegisterState(var, List.copyOf(registers));
		}
	}
}
