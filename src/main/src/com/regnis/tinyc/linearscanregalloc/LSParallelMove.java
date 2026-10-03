package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;
import java.util.function.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class LSParallelMove {
	public static void transfer(@NotNull List<VarTransfer> varTransfers, int maxRegisters, @Nullable Type pointerIntType, @NotNull Consumer<VarTransfer> consumer) {
		final Map<Integer, IRVar> registerStates = new HashMap<>();
		final List<VarTransfer> pending = new ArrayList<>();

		prepareAndSpill(varTransfers, registerStates, pending, pointerIntType, consumer);

		while (!pending.isEmpty()) {
			if (performNonConflicting(pending, registerStates, pointerIntType, consumer)) {
				continue;
			}

			final int transferIndex = findRegisterTransfer(pending, pointerIntType);
			Utils.assertTrue(transferIndex >= 0);
			final VarTransfer transfer = pending.get(transferIndex);
			final int tmp = determineTemp(transfer, pending, registerStates, maxRegisters, pointerIntType);
			if (tmp >= 0) {
				consumeAndUpdateRegisterState(new VarTransfer(transfer.var, transfer.from, tmp),
				                              registerStates, pointerIntType, consumer);
				pending.set(transferIndex, new VarTransfer(transfer.var, tmp, transfer.to));
			}
			else {
				consumeAndUpdateRegisterState(new VarTransfer(transfer.var, transfer.from, -1),
				                              registerStates, pointerIntType, consumer);
				pending.set(transferIndex, new VarTransfer(transfer.var, -1, transfer.to));
			}
		}
	}

	private static int findRegisterTransfer(List<VarTransfer> pending, @Nullable Type pointerIntType) {
		for (int i = 0; i < pending.size(); i++) {
			final VarTransfer sourceTransfer = pending.get(i);
			if (sourceTransfer.from < 0) {
				continue;
			}

			final int sourceAmount = getRegisterAmount(sourceTransfer.var, pointerIntType);
			for (int j = 0; j < pending.size(); j++) {
				if (i == j) {
					continue;
				}

				final VarTransfer targetTransfer = pending.get(j);
				if (targetTransfer.to >= 0
				    && rangesOverlap(sourceTransfer.from, sourceAmount,
				                    targetTransfer.to, getRegisterAmount(targetTransfer.var, pointerIntType))) {
					return i;
				}
			}
		}
		return -1;
	}

	private static boolean performNonConflicting(@NotNull List<VarTransfer> pending, @NotNull Map<Integer, IRVar> registerStates, @Nullable Type pointerIntType, @NotNull Consumer<VarTransfer> consumer) {
		boolean changed = false;
		for (final Iterator<VarTransfer> it = pending.iterator(); it.hasNext(); ) {
			final VarTransfer transfer = it.next();
			if (isNonConflicting(transfer, registerStates, pointerIntType)) {
				consumeAndUpdateRegisterState(transfer, registerStates, pointerIntType, consumer);
				it.remove();
				changed = true;
			}
		}
		return changed;
	}

	private static boolean isNonConflicting(VarTransfer transfer, Map<Integer, IRVar> registerStates, @Nullable Type pointerIntType) {
		final int registerAmount = getRegisterAmount(transfer.var, pointerIntType);
		final int sourceEnd = transfer.from < 0 ? -1 : transfer.from + registerAmount;
		for (int register = transfer.to; register < transfer.to + registerAmount; register++) {
			final IRVar occupant = registerStates.get(register);
			if (occupant != null
			    && (transfer.from < 0 || register < transfer.from || register >= sourceEnd || !occupant.equals(transfer.var))) {
				return false;
			}
		}
		return true;
	}

	private static void consumeAndUpdateRegisterState(VarTransfer transfer, @NotNull Map<Integer, IRVar> registerStates, @Nullable Type pointerIntType, @NotNull Consumer<VarTransfer> consumer) {
		consumer.accept(transfer);

		if (transfer.from >= 0) {
			removeRegisterRange(registerStates, transfer.from, transfer.var, pointerIntType);
		}

		if (transfer.to >= 0) {
			addRegisterRange(registerStates, transfer.to, transfer.var, pointerIntType);
		}
	}

	private static int determineTemp(VarTransfer transfer, List<VarTransfer> pending, Map<Integer, IRVar> registerStates, int maxRegisters, @Nullable Type pointerIntType) {
		final int registerAmount = getRegisterAmount(transfer.var, pointerIntType);
		final boolean onlyEvenRegisters = isOnlyEvenRegisters(transfer.var, pointerIntType);
		final int lastStart = maxRegisters - registerAmount;
		for (int register = 0; register <= lastStart; register += onlyEvenRegisters ? 2 : 1) {
			boolean available = true;
			for (int current = register; current < register + registerAmount; current++) {
				if (registerStates.containsKey(current)) {
					available = false;
					break;
				}
			}
			if (!available) {
				continue;
			}

			for (VarTransfer pendingTransfer : pending) {
				if (pendingTransfer.to >= 0
				    && rangesOverlap(register, registerAmount,
				                    pendingTransfer.to, getRegisterAmount(pendingTransfer.var, pointerIntType))) {
					available = false;
					break;
				}
			}
			if (available) {
				return register;
			}
		}
		return -1;
	}

	private static boolean rangesOverlap(int firstStart, int firstAmount, int secondStart, int secondAmount) {
		return firstStart < secondStart + secondAmount && secondStart < firstStart + firstAmount;
	}

	private static int getRegisterAmount(IRVar var, @Nullable Type pointerIntType) {
		return pointerIntType != null
				? Type.getSize(var.type(), pointerIntType)
				: 1;
	}

	private static boolean isOnlyEvenRegisters(IRVar var, @Nullable Type pointerIntType) {
		return pointerIntType != null && var.type().isPointer();
	}

	private static void addRegisterRange(Map<Integer, IRVar> registerStates, int register, IRVar var, @Nullable Type pointerIntType) {
		final int registerAmount = getRegisterAmount(var, pointerIntType);
		for (int i = 0; i < registerAmount; i++) {
			Utils.assertTrue(!registerStates.containsKey(register + i));
			registerStates.put(register + i, var);
		}
	}

	private static void removeRegisterRange(Map<Integer, IRVar> registerStates, int register, IRVar var, @Nullable Type pointerIntType) {
		final int registerAmount = getRegisterAmount(var, pointerIntType);
		for (int i = 0; i < registerAmount; i++) {
			Utils.assertTrue(var.equals(registerStates.remove(register + i)));
		}
	}

	private static void prepareAndSpill(@NotNull List<VarTransfer> varTransfers, Map<Integer, IRVar> registerStates, List<VarTransfer> pending, @Nullable Type pointerIntType, @NotNull Consumer<VarTransfer> consumer) {
		for (VarTransfer transfer : varTransfers) {
			if (transfer.to < 0) {
				if (transfer.from >= 0) {
					// first spill
					consumer.accept(transfer);
				}
				continue;
			}

			if (transfer.from < 0) {
				pending.add(transfer);
				continue;
			}

			addRegisterRange(registerStates, transfer.from, transfer.var, pointerIntType);

			if (transfer.from != transfer.to) {
				pending.add(transfer);
			}
		}
	}

	public record VarTransfer(@NotNull IRVar var, int from, int to) {
	}
}
