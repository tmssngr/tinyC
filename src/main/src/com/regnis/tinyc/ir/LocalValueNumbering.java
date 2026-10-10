package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class LocalValueNumbering {

	private final Map<ValueContainer, Value> locationToValue = new HashMap<>();

	private int unknownId;

	public LocalValueNumbering() {
	}

	public void process(@NotNull IRInstruction instruction) {
		switch (instruction) {
		case IRAddrOf addrOf -> {
			final IRVar source = addrOf.source();
			store(addrOf.target(), new Value.AddrOf(ValueContainer.of(source)), instruction);
		}
		case IRBinary binary -> {
			final Value left = getValue(binary.left());
			final Value right = getValue(binary.right());
			store(binary.target(), new Value.Binary(left, binary.op(), right), instruction);
		}
		case IRBranch ignored -> {}
		case IRCall call -> {
			final Set<Integer> stackIndicesToRemove = new HashSet<>();
			for (IRValue arg : call.args()) {
				final IRVar var = arg.var();
				if (var != null) {
					getValue(arg);
					if (var.scope() == VariableScope.function) {
						stackIndicesToRemove.add(var.index());
					}
				}
			}

			final IRVar target = call.target();
			if (target != null) {
				store(target, unknown(), instruction);
			}
		}
		case IRCast cast -> {
			final Value value = getValue(cast.source());
			store(cast.target(), new Value.Cast(cast.target().type(), value), instruction);
		}
		case IRComment ignored -> {
		}
		case IRCompare ignored -> {
		}
		case IRJump ignored -> locationToValue.clear();
		case IRLabel ignored -> locationToValue.clear();
		case IRMemLoad load -> {
			final IRVar target = load.target();
			Utils.assertTrue(target.scope() == VariableScope.register);
			Value value = getValue(load.addr());
			if (value instanceof Value.AddrOf(ValueContainer loc)) {
				value = getValue(loc);
			}
			else {
				value = unknown();
			}
			store(target, value, instruction);
		}
		case IRMemStore store -> {
			final Value value = getValue(store.value());
			final Value addr = getValue(store.addr());
			if (addr instanceof Value.AddrOf(ValueContainer var)) {
				store(var, value, instruction);
			}
		}
		case IRMove move -> {
			final Value value = getValue(move.source());
			store(move.target(), value, instruction);
		}
		case IRString string -> store(string.target(), new Value.String0(string.stringIndex()), instruction);
		case IRUnary unary -> {
			final Value value = getValue(unary.source());
			store(unary.target(), new Value.Unary(unary.op(), value), instruction);
		}
		default -> throw new UnsupportedOperationException(instruction.toString());
		}
	}

	@NotNull
	private Value getValue(@NotNull IRValue source) {
		final IRVar var = source.var();
		if (var == null) {
			return new Value.Constant(source.value(), source.type());
		}

		return getValue(var);
	}

	@NotNull
	private Value getValue(@NotNull IRVar var) {
		final ValueContainer location = ValueContainer.of(var);
		return getValue(location);
	}

	@NotNull
	private Value getValue(@NotNull ValueContainer location) {
		Value value = locationToValue.get(location);
		if (value == null) {
			value = unknown();
			locationToValue.put(location, value);
		}
		return value;
	}

	@NotNull
	private Value.Unknown unknown() {
		return new Value.Unknown(unknownId++);
	}

	private void store(@NotNull IRVar target, @NotNull Value value, @NotNull IRInstruction instruction) {
		final ValueContainer location = ValueContainer.of(target);
		store(location, value, instruction);
	}

	private void store(@NotNull ValueContainer location, @NotNull Value value, @NotNull IRInstruction instruction) {
		locationToValue.put(location, value);
	}
}
