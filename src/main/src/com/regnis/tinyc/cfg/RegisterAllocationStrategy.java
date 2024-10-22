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
	static final int CALL_ARG_1 = 1;
	static final int CALL_ARG_2 = 2;

	private final List<LiveVarRegisterState> liveVars = new ArrayList<>();
	private final int maxArgsInRegisters;
	private final int firstNonVolatileRegister;
	private final int maxRegisters;

	public RegisterAllocationStrategy(int maxArgsInRegisters, int additionalVolatileRegisters, int nonVolatileRegisters) {
		Utils.assertTrue(maxArgsInRegisters >= 0);
		Utils.assertTrue(additionalVolatileRegisters >= 0);
		Utils.assertTrue(nonVolatileRegisters > 0);
		this.maxArgsInRegisters = maxArgsInRegisters;
		firstNonVolatileRegister = CALL_ARG_1 + maxArgsInRegisters + additionalVolatileRegisters;
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
		int argReg = CALL_ARG_1;
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
			}
			if (volatileRegisters.isEmpty()) {
				continue;
			}

			//noinspection UnnecessaryLocalVariable
			final List<Integer> nonVolatileRegisters = registers;
			final int nvReg = nonVolatileRegisters.size() > 0
					? nonVolatileRegisters.getFirst()
					: getFreeNonVolatileRegister();
			if (nvReg >= 0) {
				movRegsFromReg(var.var, volatileRegisters, nvReg, consumer);
				liveVars.set(i, var.derive(List.of(nvReg)));
			}
			else {
				movRegsFromVar(var.var, volatileRegisters, consumer);
				liveVars.set(i, var.derive(List.of()));
			}
		}
	}

	public void freeRegister(int targetRegister, @NotNull Predicate<Integer> registerPredicate, @NotNull Consumer<IRInstruction> consumer) {
		final LiveVarRegisterState state = get(targetRegister);
		if (state == null) {
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
			preferredRegister = getFreeRegister(register -> {
				// nothing allowed, so the targetRegister must be free
				if (register == targetRegister) {
					return false;
				}
				return registerPredicate.test(register);
			});
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
			movRegsFromVar(state.var(), state.registers, consumer);
		}
	}

	public void freeAllRegisters(@NotNull Consumer<IRInstruction> consumer) {
		final List<LiveVarRegisterState> newStates = new ArrayList<>(liveVars.size());
		for (LiveVarRegisterState state : liveVars) {
			if (state.registers.isEmpty()) {
				newStates.add(state);
				continue;
			}

			newStates.add(state.derive(List.of()));
			movRegsFromVar(state.var(), state.registers, consumer);
		}

		liveVars.clear();
		liveVars.addAll(newStates);
	}

	public boolean isLiveAfter(IRVar var) {
		return get(var) != null;
	}

	@NotNull
	public IRVar target(IRVar target, Consumer<IRInstruction> consumer) {
		final LiveVarRegisterState state = get(target);
		Utils.assertTrue(state != null);
		liveVars.remove(state);
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
		return target(target, CALL_RETURN_REG, register -> !isVolatile(register), consumer);
	}

	@NotNull
	public IRVar target(@NotNull IRVar var, int reg, @NotNull Predicate<Integer> registerPredicate, @NotNull Consumer<IRInstruction> consumer) {
		final LiveVarRegisterState regState = get(reg);
		if (regState != null && !regState.var().equals(var)) {
			freeRegister(reg, registerPredicate, consumer);
		}

		final LiveVarRegisterState state = remove(var);
		if (state.registers.isEmpty()) {
			movVarFromReg(var, reg, consumer);
		}
		else {
			for (int register : state.registers) {
				if (register != reg) {
					movRegFromReg(state.var(), register, reg, consumer);
				}
			}
		}
		return reg(reg, var);
	}

	@NotNull
	public IRVar source(IRVar source, Consumer<IRInstruction> preConsumer, Consumer<IRInstruction> postConsumer) {
		return source(source, r -> true, preConsumer, postConsumer);
	}

	@NotNull
	public IRVar source(IRVar source, Predicate<Integer> canFreeRegister, Consumer<IRInstruction> preConsumer, Consumer<IRInstruction> postConsumer) {
		final LiveVarRegisterState state = get(source);
		// live (not last use)?
		if (state != null) {
			if (state.registers.size() > 0) {
				return reg(state.registers.getFirst(), source);
			}

			// but not yet in registers?
			liveVars.remove(state);
		}

		int register = getFreeRegister();
		if (register < 0) {
			register = freeAnyVarRegister(canFreeRegister, postConsumer);
		}
		final List<Integer> registers = List.of(register);
		// is last use?
		if (state == null) {
			liveVars.add(new LiveVarRegisterState(source, registers));
		}
		else {
			movVarFromReg(source, register, preConsumer);
			setRegisters(state, registers);
		}
		return reg(register, source);
	}

	public int freeAnyVarRegister(Predicate<Integer> canFreeRegister, Consumer<IRInstruction> consumer) {
		LiveVarRegisterState varToSpill = null;
		for (LiveVarRegisterState state : liveVars) {
			if (state.registers.isEmpty()) {
				continue;
			}

			if (state.registers.size() > 1) {
				final List<Integer> registers = new ArrayList<>(state.registers);
				int register = -1;
				for (Integer r : registers) {
					if (canFreeRegister.test(r)) {
						registers.remove(r);
						register = r;
						break;
					}
				}
				Utils.assertTrue(register >= 0);
				setRegisters(state, registers);
				movRegFromReg(state.var, register, registers.getFirst(), consumer);
				return register;
			}

			// todo pick best (e.g. farthest next use)
			if (varToSpill == null) {
				final int register = state.registers.getFirst();
				if (canFreeRegister.test(register)) {
					varToSpill = state;
				}
			}
		}

		Utils.assertTrue(varToSpill != null);
		Utils.assertTrue(varToSpill.registers.size() == 1);

		final int register = varToSpill.registers.getFirst();
		setRegisters(varToSpill, List.of());
		movRegFromVar(register, varToSpill.var, consumer);
		return register;
	}

	@NotNull
	public IRVar sourceForModificationInReg(@NotNull IRVar var, int freeRegister) {
		Utils.assertTrue(get(freeRegister) == null);

		final LiveVarRegisterState state = get(var);
		if (state == null) {
			// last use?
			liveVars.add(new LiveVarRegisterState(var, List.of(freeRegister)));
		}
		else {
			final List<Integer> registers = new ArrayList<>(state.registers);
			registers.add(freeRegister);
			setRegisters(state, registers);
		}
		return reg(freeRegister, var);
	}

	public void handleFirstBlockBegin(Consumer<IRInstruction> consumer) {
		final List<LiveVarRegisterState> args = new ArrayList<>();
		int argCount = 0;
		for (LiveVarRegisterState state : new ArrayList<>(liveVars)) {
			if (state.registers.isEmpty()) {
				continue;
			}

			final boolean isArgInRegisterVar = state.var.scope() == VariableScope.argument
			                                   && state.var.index() < maxArgsInRegisters;
			if (!isArgInRegisterVar) {
				movRegsFromVar(state.var, state.registers, consumer);
				setRegisters(state, List.of());
				continue;
			}

			argCount = Math.max(state.var.index() + 1, argCount);
			final int idealRegister = getIdealRegister(state.var);
			if (state.registers.contains(idealRegister)) {
				for (int register : state.registers) {
					if (register != idealRegister) {
						movRegFromReg(state.var, register, idealRegister, consumer);
					}
				}
				continue;
			}

			if (state.registers.size() > 1) {
				int remainingRegister = state.registers.getFirst();
				for (int register : state.registers) {
					if (register == 0 || register >= firstNonVolatileRegister) {
						remainingRegister = register;
						break;
					}
				}
				for (int register : state.registers) {
					if (register != remainingRegister) {
						movRegFromReg(state.var, remainingRegister, register, consumer);
					}
				}
				liveVars.remove(state);
				state = setRegisters(state, List.of(remainingRegister));
				liveVars.add(state);
			}

			args.add(state);
		}

		final int tmpRegister = getTempRegister(args);
		final LiveVarRegisterState tmpState = args.removeFirst();
		final List<Integer> freed = new ArrayList<>();
		movRegsFromReg(tmpState, tmpRegister, freed, consumer);
		outer:
		while (args.size() > 0) {
			final int i = freed.removeFirst();
			for (LiveVarRegisterState arg : args) {
				final int idealRegister = getIdealRegister(arg.var);
				if (idealRegister == i) {
					movRegsFromReg(arg, idealRegister, freed, consumer);
					setRegisters(arg, List.of(idealRegister));
					args.remove(arg);
					continue outer;
				}
			}
			throw new IllegalStateException();
		}

		final int idealRegister = getIdealRegister(tmpState.var);
		movRegFromReg(tmpState.var, tmpRegister, idealRegister, consumer);
		setRegisters(tmpState, List.of(idealRegister));
	}

	public void transferTo(@NotNull List<LiveVarRegisterState> newStates, Consumer<IRInstruction> consumer) {
		final Map<IRVar, Pair<List<Integer>, List<Integer>>> varToLists = new LinkedHashMap<>();
		for (LiveVarRegisterState var : liveVars) {
			final Pair<List<Integer>, List<Integer>> prev
					= varToLists.put(var.var, new Pair<>(List.of(), var.registers));
			Utils.assertTrue(prev == null);
		}
		for (LiveVarRegisterState var : newStates) {
			Utils.assertTrue(var.registers.size() < 2);
			final Pair<List<Integer>, List<Integer>> prev = varToLists.get(var.var);
			varToLists.put(var.var, new Pair<>(var.registers, prev != null ? prev.second() : List.of()));
		}

		final Map<Integer, IRVar> fromRegToVar = new HashMap<>();
		final Map<Integer, IRVar> toRegToVar = new LinkedHashMap<>();
		for (final var it = varToLists.entrySet().iterator(); it.hasNext(); ) {
			final Map.Entry<IRVar, Pair<List<Integer>, List<Integer>>> entry = it.next();
			final Pair<List<Integer>, List<Integer>> pair = entry.getValue();
			final IRVar var = entry.getKey();
			final List<Integer> fromRegs = pair.first();
			final int fromReg = fromRegs.isEmpty() ? -1 : fromRegs.getFirst();
			final List<Integer> toRegs = pair.second();
			if (fromReg < 0) {
				movRegsFromVar(var, toRegs, consumer);
				setState(var, List.of());
				it.remove();
				continue;
			}

			if (toRegs.isEmpty()) {
				movVarFromReg(var, fromReg, consumer);
				setState(var, fromRegs);
				it.remove();
				continue;
			}

			if (toRegs.contains(fromReg)) {
				movRegsFromReg(var, toRegs, fromReg, consumer);
				setState(var, fromRegs);
				it.remove();
				continue;
			}

			Utils.assertTrue(fromRegToVar.put(fromReg, var) == null);
			for (int reg : toRegs) {
				Utils.assertTrue(toRegToVar.put(reg, var) == null);
			}
		}

		if (toRegToVar.isEmpty()) {
			return;
		}

		while (true) {
			boolean repeat = false;
			for (final Iterator<Map.Entry<Integer, IRVar>> it = toRegToVar.entrySet().iterator(); it.hasNext(); ) {
				final Map.Entry<Integer, IRVar> entry = it.next();
				final IRVar var = entry.getValue();
				final var pair = Objects.requireNonNull(varToLists.get(var));
				final int fromReg = pair.first().getFirst();
				if (!toRegToVar.containsKey(fromReg)) {
					final List<Integer> toRegs = pair.second();
					movRegsFromReg(var, toRegs, fromReg, consumer);
					setState(var, pair.first());
					it.remove();
					if (toRegToVar.isEmpty()) {
						return;
					}

					repeat = true;
				}
			}

			if (!repeat) {
				break;
			}
		}

		int tmpReg = -1;
		for (int i = 0; i < maxRegisters; i++) {
			if (toRegToVar.get(i) == null) {
				tmpReg = i;
				break;
			}
		}

		while (!toRegToVar.isEmpty()) {
			final Iterator<Map.Entry<Integer, IRVar>> it = toRegToVar.entrySet().iterator();
			final Map.Entry<Integer, IRVar> entry = it.next();
			final int register = entry.getKey();
			IRVar var = entry.getValue();
			var pair = Objects.requireNonNull(varToLists.get(var));
			int fromReg = pair.first().getFirst();
			List<Integer> toRegs = pair.second();
			if (tmpReg < 0) {
				movRegsFromVar(var, toRegs, consumer);
			}
			else {
				movRegsFromReg(var, toRegs, tmpReg, consumer);
			}

			while (true) {
				var = Objects.requireNonNull(toRegToVar.get(fromReg));
				pair = Objects.requireNonNull(varToLists.get(var));
				toRegs = pair.second();
				movRegsFromReg(var, toRegs, fromReg, consumer);
				fromReg = pair.first().getFirst();
			}
		}
	}

	private void setState(IRVar var, List<Integer> registers) {
		final LiveVarRegisterState prevState = get(var);
		if (prevState != null) {
			liveVars.remove(prevState);
		}
		liveVars.add(new LiveVarRegisterState(var, registers));
	}

	private void movRegsFromReg(LiveVarRegisterState state, int sourceRegister, List<Integer> freed, Consumer<IRInstruction> consumer) {
		for (int register : state.registers) {
			movRegFromReg(state.var, register, sourceRegister, consumer);
			if (register != CALL_RETURN_REG && register < firstNonVolatileRegister) {
				freed.add(register);
			}
		}
	}

	private void movRegsFromReg(IRVar var, List<Integer> toRegs, int fromReg, Consumer<IRInstruction> consumer) {
		for (int register : toRegs) {
			if (register != fromReg) {
				movRegFromReg(var, register, fromReg, consumer);
			}
		}
	}

	private int getIdealRegister(IRVar var) {
		return var.index() + 1;
	}

	private int getTempRegister(List<LiveVarRegisterState> args) {
		final Set<Integer> usedRegisters = getUsedRegisters(args);
		for (int i = 0; i < maxRegisters; i++) {
			if (!usedRegisters.contains(i)) {
				return i;
			}
		}

		for (LiveVarRegisterState state : args) {
			if (state.registers.size() > 1) {
				final List<Integer> newRegisters = new ArrayList<>(state.registers);

				break;
			}
		}
		throw new IllegalStateException();
	}

	private LiveVarRegisterState setRegisters(@NotNull LiveVarRegisterState state, @NotNull List<Integer> registers) {
		liveVars.remove(state);
		final LiveVarRegisterState derived = state.derive(registers);
		liveVars.add(derived);
		return derived;
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
		final Set<Integer> usedRegisters = getUsedRegisters(liveVars);

		for (int register = CALL_ARG_1; register < maxRegisters; register++) {
			if (!usedRegisters.contains(register)
			    && predicate.test(register)) {
				return register;
			}
		}
		return -1;
	}

	@NotNull
	private Set<Integer> getUsedRegisters(List<LiveVarRegisterState> vars) {
		final Set<Integer> usedRegisters = new HashSet<>();
		for (LiveVarRegisterState var : vars) {
			usedRegisters.addAll(var.registers);
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

	private void movRegsFromVar(IRVar var, List<Integer> registers, Consumer<IRInstruction> consumer) {
		int mainRegister = -1;
		for (int register : registers) {
			if (mainRegister < 0) {
				mainRegister = register;
			}
			else {
				movRegFromReg(var, register, mainRegister, consumer);
			}
		}
		if (mainRegister >= 0) {
			movRegFromVar(mainRegister, var, consumer);
		}
	}

	private void movVarFromRegs(IRVar var, List<Integer> registers, Consumer<IRInstruction> consumer) {
		Utils.assertTrue(registers.size() > 0);
		movVarFromReg(var, registers.getFirst(), consumer);
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
		return IRVar.createRegisterVar(register, var);
	}

	public record AllLiveVarRegisterState(@NotNull List<LiveVarRegisterState> vars) {
	}

	public record LiveVarRegisterState(@NotNull IRVar var, List<Integer> registers) {
		public LiveVarRegisterState {
			Utils.assertTrue(new HashSet<>(registers).size() == registers.size());
		}

		@Override
		public String toString() {
			return var.name() + ": " + registers;
		}

		@NotNull
		public LiveVarRegisterState derive(List<Integer> registers) {
			return new LiveVarRegisterState(var, List.copyOf(registers));
		}
	}
}
