package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public sealed interface Value permits Value.AddrOf, Value.Binary, Value.Cast, Value.Constant, Value.String0, Value.Unary, Value.Unknown {
	record AddrOf(@NotNull ValueContainer var) implements Value {
		public AddrOf {
			Utils.assertTrue(!(var instanceof ValueContainer.Reg));
		}
	}

	record Binary(@NotNull Value left, @NotNull IRBinary.Op op, @NotNull Value right) implements Value {
		@NotNull
		@Override
		public String toString() {
			return left + " " + op + " " + right;
		}
	}

	record Cast(@NotNull Type type, @NotNull Value value) implements Value {
		@NotNull
		@Override
		public String toString() {
			return "(" + type + ")" + value;
		}
	}

	record Constant(int value, @NotNull Type type) implements Value {
		@NotNull
		@Override
		public String toString() {
			return String.valueOf(value);
		}
	}

	record String0(int index) implements Value {
		@NotNull
		@Override
		public String toString() {
			return "'" + index + "'";
		}
	}

	record Unary(@NotNull IRUnary.Op op, @NotNull Value value) implements Value {
		@NotNull
		@Override
		public String toString() {
			return op + " " + value;
		}
	}

	record Unknown(int id) implements Value {
		@NotNull
		@Override
		public String toString() {
			return "#" + id;
		}
	}
}
