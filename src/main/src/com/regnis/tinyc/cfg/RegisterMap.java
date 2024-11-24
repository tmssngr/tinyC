package com.regnis.tinyc.cfg;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;
import java.util.function.Function;
import java.util.function.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class RegisterMap {

	public static boolean contains(IRVar var, Set<IRVar> lives) {
		return lives.contains(var);
	}

	private final Register[] registers;

	public RegisterMap(int maxRegisters) {
		// 3 because all operations (except of call which is working differently) have
		// at most 2 inputs and 1 output
		Utils.assertTrue(maxRegisters >= 3);
		registers = new Register[maxRegisters];
		for (int i = 0; i < registers.length; i++) {
			registers[i] = new Register(i);
		}
	}

	@NotNull
	public List<Object> createDebugState() {
		final List<Object> debugInfos = new ArrayList<>();
		for (final Register register : registers) {
			if (register.var != null) {
				debugInfos.add(register.var);
			}
			else {
				debugInfos.add(null);
			}
		}
		return debugInfos;
	}

	@Nullable
	public IRVar getRegisterVar(@NotNull IRVar var) {
		final Register register = getRegister(var);
		return register != null
				? var.asRegister(register.index)
				: null;
	}

	@NotNull
	public IRVar useRegisterForWriting(@NotNull IRVar var) {
		Utils.assertTrue(getRegister(var) == null);
		return useRegisterFor(var, true);
	}

	@NotNull
	public IRVar useRegisterForReading(@NotNull IRVar var) {
		Utils.assertTrue(getRegister(var) == null);
		return useRegisterFor(var, false);
	}

	@Nullable
	public IRVar maybeFreeRegister(@NotNull IRVar var) {
		Utils.assertTrue(var.scope() != VariableScope.register);

		final Register register = getRegister(var);
		if (register == null) {
			return null;
		}

		register.free();
		return var.asRegister(register.index);
	}

	public void freeAll(@NotNull Function<IRVar, FreeOp> predicate, @NotNull BiConsumer<IRVar, IRVar> consumer) {
		for (final Register register : registers) {
			final IRVar var = register.var;
			if (var == null) {
				continue;
			}

			final FreeOp op = predicate.apply(var);
			if (op == FreeOp.Skip) {
				continue;
			}

			if (op == FreeOp.StoreWrittenAndFree && register.usedForWrite) {
				register.storeRegisterInVar(consumer);
			}
			register.free();
		}
	}

	public void maybeSpillRegisters(Set<IRVar> liveBefore, Set<IRVar> lastUsed, Set<IRVar> uses, Set<IRVar> defines,
	                                BiConsumer<IRVar, IRVar> consumer) {
		final IRVar[] registersUsedFor = new IRVar[registers.length];
		for (IRVar var : uses) {
			Utils.assertTrue(liveBefore.contains(var));

			Register register = getRegister(var);
			if (register == null) {
				register = spill(registersUsedFor, uses, consumer);
			}
			registersUsedFor[register.index] = var;
		}

		final int furtherNeeded = defines.size() - lastUsed.size();
		if (furtherNeeded > 0) {
			Utils.assertTrue(furtherNeeded == 1);
			spill(registersUsedFor, uses, consumer);
		}
	}

	@NotNull
	private Register spill(IRVar[] occupiedRegisters, Set<IRVar> dontSpill, BiConsumer<IRVar, IRVar> consumer) {
		Utils.assertTrue(occupiedRegisters.length == registers.length);
		Register register = iterateRegistersUntil(occupiedRegisters,
		                                          r -> r.var == null);
		if (register != null) {
			return register;
		}

		register = iterateRegistersUntil(occupiedRegisters,
		                                 r -> {
			                                 final IRVar var = Objects.requireNonNull(r.var);
			                                 return !contains(var, dontSpill)
			                                        && !r.usedForWrite;
		                                 });
		if (register != null) {
			register.free();
			return register;
		}

		register = iterateRegistersUntil(occupiedRegisters,
		                                 r -> {
			                                 final IRVar var = Objects.requireNonNull(r.var);
			                                 return !contains(var, dontSpill);
		                                 });
		if (register == null) {
			throw new IllegalStateException("Failed to spill");
		}

		register.storeRegisterInVar(consumer);
		register.free();
		return register;
	}

	@Nullable
	private Register iterateRegistersUntil(IRVar[] occupiedRegisters, Predicate<Register> predicate) {
		for (int i = 0; i < registers.length; i++) {
			if (occupiedRegisters[i] != null) {
				continue;
			}

			final Register register = registers[i];
			if (predicate.test(register)) {
				return register;
			}
		}
		return null;
	}

	@Nullable
	private Register getRegister(@NotNull IRVar var) {
		for (Register register : registers) {
			if (var.equals(register.var)) {
				return register;
			}
		}
		return null;
	}

	@NotNull
	private IRVar useRegisterFor(@NotNull IRVar var, boolean write) {
		final int register = getFreeRegister();
		registers[register].setUsed(var, write);
		return var.asRegister(register);
	}

	private int getFreeRegister() {
		for (int i = 0; i < registers.length; i++) {
			if (registers[i].isFree()) {
				return i;
			}
		}
		throw new IllegalStateException("out of registers");
	}

	public enum FreeOp {
		Skip, Free, StoreWrittenAndFree
	}

	private static class Register {

		public final int index;
		@Nullable private IRVar var;
		private boolean usedForWrite;

		public Register(int index) {
			this.index = index;
		}

		@Override
		public String toString() {
			final StringBuilder buffer = new StringBuilder();
			buffer.append(index);
			buffer.append(": ");
			if (var != null) {
				buffer.append(var);
			}
			else {
				buffer.append("free");
			}
			return buffer.toString();
		}

		public void setUsed(@NotNull IRVar var, boolean write) {
			Utils.assertTrue(isFree());
			this.var = var;
			usedForWrite = write;
		}

		public boolean isFree() {
			return var == null;
		}

		public void free() {
			Utils.assertTrue(!isFree());
			this.var = null;
		}

		public void storeRegisterInVar(@NotNull BiConsumer<IRVar, IRVar> consumer) {
			final IRVar var = Objects.requireNonNull(this.var);
			final IRVar registerVar = var.asRegister(index);
			consumer.accept(var, registerVar);
		}
	}
}
