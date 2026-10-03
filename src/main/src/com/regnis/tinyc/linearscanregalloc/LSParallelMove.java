package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ir.*;

import java.util.*;
import java.util.function.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class LSParallelMove {
	public static void transfer(@NotNull List<VarTransfer> varTransfers, int maxRegisters, @NotNull Consumer<VarTransfer> consumer) {
		final Map<Integer, IRVar> registerStates = new HashMap<>();
		final List<VarTransfer> pending = new ArrayList<>();

		prepareAndSpill(varTransfers, registerStates, pending, consumer);

		while (!pending.isEmpty()) {
			if (performNonConflicting(pending, registerStates, consumer)) {
				continue;
			}

			final int transferIndex = findRegisterTransfer(pending);
			Utils.assertTrue(transferIndex >= 0);
			final VarTransfer transfer = pending.get(transferIndex);
			final int tmp = determineTemp(pending, registerStates, maxRegisters);
			if (tmp >= 0) {
				consumeAndUpdateRegisterState(new VarTransfer(transfer.var, transfer.from, tmp), registerStates, consumer);
				pending.set(transferIndex, new VarTransfer(transfer.var, tmp, transfer.to));
			}
			else {
				consumeAndUpdateRegisterState(new VarTransfer(transfer.var, transfer.from, -1), registerStates, consumer);
				pending.set(transferIndex, new VarTransfer(transfer.var, -1, transfer.to));
			}
		}
	}

	private static int findRegisterTransfer(List<VarTransfer> pending) {
		for (int i = 0; i < pending.size(); i++) {
			final VarTransfer sourceTransfer = pending.get(i);
			if (sourceTransfer.from < 0) {
				continue;
			}

			for (int j = 0; j < pending.size(); j++) {
				if (i == j) {
					continue;
				}

				final VarTransfer targetTransfer = pending.get(j);
				if (sourceTransfer.from == targetTransfer.to) {
					return i;
				}
			}
		}
		return -1;
	}

	private static boolean performNonConflicting(@NotNull List<VarTransfer> pending, @NotNull Map<Integer, IRVar> registerStates, @NotNull Consumer<VarTransfer> consumer) {
		boolean changed = false;
		for (final Iterator<VarTransfer> it = pending.iterator(); it.hasNext(); ) {
			final VarTransfer transfer = it.next();
			if (!registerStates.containsKey(transfer.to)) {
				consumeAndUpdateRegisterState(transfer, registerStates, consumer);
				it.remove();
				changed = true;
			}
		}
		return changed;
	}

	private static void consumeAndUpdateRegisterState(VarTransfer transfer, @NotNull Map<Integer, IRVar> registerStates, @NotNull Consumer<VarTransfer> consumer) {
		consumer.accept(transfer);

		if (transfer.from >= 0) {
			registerStates.remove(transfer.from);
		}

		if (transfer.to >= 0) {
			registerStates.put(transfer.to, transfer.var);
		}
	}

	private static int determineTemp(List<VarTransfer> pending, Map<Integer, IRVar> registerStates, int maxRegisters) {
		for (int register = 0; register < maxRegisters; register++) {
			if (registerStates.containsKey(register)) {
				continue;
			}

			boolean available = true;
			for (VarTransfer pendingTransfer : pending) {
				if (pendingTransfer.to == register) {
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

	private static void prepareAndSpill(@NotNull List<VarTransfer> varTransfers, Map<Integer, IRVar> registerStates, List<VarTransfer> pending, @NotNull Consumer<VarTransfer> consumer) {
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

			Utils.assertTrue(!registerStates.containsKey(transfer.from));
			registerStates.put(transfer.from, transfer.var);

			if (transfer.from != transfer.to) {
				pending.add(transfer);
			}
		}
	}

	public record VarTransfer(@NotNull IRVar var, int from, int to) {
	}
}
