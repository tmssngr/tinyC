package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class LSVarRegisters {

	public static final int NOT_LIVE = -2;
	public static final int NOT_REGISTER = -1;

	private final List<RangeState> rangeStates = new ArrayList<>();
	private final List<LSUse> uses = new ArrayList<>();
	private final List<Transition> transitions = new ArrayList<>();
	public final IRVar var;

	public LSVarRegisters(@NotNull IRVar var) {
		this.var = var;
	}

	@Override
	public String toString() {
		return rangeStates + " " + uses + " " + transitions;
	}

	public void add(@NotNull LSInterval interval, @NotNull List<LSUse> uses) {
		final int register = interval.register();
		Utils.assertTrue(register >= NOT_REGISTER);

		final RangeState prevRangeState = rangeStates.isEmpty() ? null : rangeStates.getLast();

		Utils.assertTrue(this.uses.isEmpty() || uses.isEmpty() || this.uses.getLast().pos() < uses.getFirst().pos());

		if (prevRangeState != null && prevRangeState.reg() != register) {
			possiblyAddTransition(interval.getFrom(), prevRangeState.reg, register, uses);
		}

		int expectFrom = prevRangeState == null ? Integer.MIN_VALUE : prevRangeState.range.to();
		for (LSRange range : interval.ranges()) {
			Utils.assertTrue(range.from() >= expectFrom);
			rangeStates.add(new RangeState(range, register));
			expectFrom = range.to();
		}

		this.uses.addAll(uses);
	}

	public int getRegisterOrState(int pos) {
		for (RangeState rangeState : rangeStates) {
			if (rangeState.range.contains(pos, false)) {
				return rangeState.reg;
			}
		}
		return NOT_LIVE;
	}

	@Nullable
	public Pair<IRVar, IRVar> getTransitionAt(int pos) {
		for (Transition transition : transitions) {
			if (transition.pos == pos) {
				final IRVar from = transition.from < 0 ? var : var.asRegister(transition.from);
				final IRVar to = transition.to < 0 ? var : var.asRegister(transition.to);
				return new Pair<>(from, to);
			}
			if (transition.pos > pos) {
				break;
			}
		}
		return null;
	}

	private void possiblyAddTransition(int fromPos, int prevReg, int register, @NotNull List<LSUse> uses) {
		if (uses.size() > 0) {
			final LSUse firstUse = uses.getFirst();
			if (firstUse.pos() == fromPos && firstUse.isWrite()) {
				return;
			}
		}

		transitions.add(new Transition(fromPos, prevReg, register));
	}

	private record Transition(int pos, int from, int to) {
	}

	private record RangeState(@NotNull LSRange range, int reg) {
		@Override
		public String toString() {
			return range + ": " + reg;
		}
	}
}
