package com.regnis.tinyc.ir;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public sealed interface ValueContainer permits ValueContainer.Global, ValueContainer.Reg, ValueContainer.Stack {
	@NotNull
	static ValueContainer of(@NotNull IRVar var) {
		return switch (var.scope()) {
			case register -> new Reg(var.index());
			case function, parameter -> new Stack(var.index());
			case global -> new Global(var.index());
		};
	}

	static int compare(ValueContainer loc1, ValueContainer loc2) {
		final int loc = typeSortValue(loc1) - typeSortValue(loc2);
		if (loc != 0) {
			return loc;
		}
		return subSortValue(loc1) - subSortValue(loc2);
	}

	private static int typeSortValue(ValueContainer container) {
		return switch (container) {
			case ValueContainer.Global ignored -> 2;
			case ValueContainer.Reg ignored -> 0;
			case ValueContainer.Stack ignored -> 1;
		};
	}

	private static int subSortValue(ValueContainer container) {
		return switch (container) {
			case ValueContainer.Global g -> g.index();
			case ValueContainer.Reg r -> r.index();
			case ValueContainer.Stack s -> s.index();
		};
	}


	record Global(int index) implements ValueContainer {
		@NotNull
		@Override
		public String toString() {
			return "global+" + index;
		}
	}

	record Reg(int index) implements ValueContainer {
		@NotNull
		@Override
		public String toString() {
			return "r" + index;
		}
	}

	record Stack(int index) implements ValueContainer {
		@NotNull
		@Override
		public String toString() {
			return "stack+" + index;
		}
	}
}
