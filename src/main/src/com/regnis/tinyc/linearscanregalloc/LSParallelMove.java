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
		final List<VarTransfer> memToRegisterTransfers = new ArrayList<>();

		prepareAndSpill(varTransfers, memToRegisterTransfers, registerStates, pending, consumer);

		// perform all non-conflicting moves
		while (pending.size() > 0 && performNonConflicting(pending, registerStates, consumer)) {
		}

		// perform all circular moves
		while (pending.size() > 0) {
			Utils.assertTrue(pending.size() > 1);

			final int tmp = determineTemp(registerStates, maxRegisters);

			// split the circle by removing one transfer from it
			final VarTransfer tmpTransfer = pending.removeFirst();
			consumeAndUpdateRegisterState(new VarTransfer(tmpTransfer.var, tmpTransfer.from, tmp),
			                              registerStates, consumer);

			while (pending.size() > 0 && performNonConflicting(pending, registerStates, consumer)) {
			}

			consumeAndUpdateRegisterState(new VarTransfer(tmpTransfer.var, tmp, tmpTransfer.to),
			                              registerStates, consumer);
		}

		// last respawn in registers
		for (VarTransfer transfer : memToRegisterTransfers) {
			Utils.assertTrue(transfer.from < 0);
			consumer.accept(transfer);
		}
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

		registerStates.remove(transfer.from);

		if (transfer.to >= 0) {
			registerStates.put(transfer.to, transfer.var);
		}
	}

	private static int determineTemp(Map<Integer, IRVar> registerStates, int maxRegisters) {
		for (int i = 0; i < maxRegisters; i++) {
			if (!registerStates.containsKey(i)) {
				return i;
			}
		}
		return -1;
	}

	private static void prepareAndSpill(@NotNull List<VarTransfer> varTransfers, List<VarTransfer> memToRegisterTransfers, Map<Integer, IRVar> registerStates, List<VarTransfer> pending, @NotNull Consumer<VarTransfer> consumer) {
		for (VarTransfer transfer : varTransfers) {
			if (transfer.to < 0) {
				if (transfer.from >= 0) {
					// first spill
					consumer.accept(transfer);
				}
				continue;
			}

			if (transfer.from < 0) {
				memToRegisterTransfers.add(transfer);
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
