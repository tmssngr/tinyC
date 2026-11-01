package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;

import java.util.*;
import java.util.function.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class IRLocalOptimizer {

	static boolean debug = false;

	@NotNull
	public static List<IRInstruction> cleanUp(@NotNull List<IRInstruction> instructions, @NotNull PlatformSpecificInstructionBehavior psib) {
		final IRLocalOptimizer cleanup = new IRLocalOptimizer(psib);
		return cleanup.iterate(instructions);
	}

	private final Map<ValueContainer, Value> locationToValue = new HashMap<>();
	private final PlatformSpecificInstructionBehavior psib;

	private boolean logValues;
	private int unknownId;

	private IRLocalOptimizer(@NotNull PlatformSpecificInstructionBehavior psib) {
		this.psib = psib;
	}

	private List<IRInstruction> iterate(List<IRInstruction> instructions) {
		final List<IRInstruction> newInstructions = new ArrayList<>(instructions.size());
		int pc = 0;
		for (IRInstruction instruction : instructions) {
			if (debug) {
				System.out.println(pc + ": " + instruction.toString(true));
			}
			logValues = false;

			final IRInstruction newInstruction = process(instruction);

			if (logValues && debug) {
				System.out.println("\t\t" + getValuesAsString());
			}
			if (newInstruction != null) {
				newInstructions.add(newInstruction);
			}
			pc++;
		}
		return newInstructions;
	}

	private String getValuesAsString() {
		final List<ValueContainer> locations = new ArrayList<>(locationToValue.keySet());
		locations.sort(new Comparator<>() {
			@Override
			public int compare(ValueContainer loc1, ValueContainer loc2) {
				final int loc = typeSortValue(loc1) - typeSortValue(loc2);
				if (loc != 0) {
					return loc;
				}
				return subSortValue(loc1) - subSortValue(loc2);
			}

			private int typeSortValue(ValueContainer container) {
				return switch (container) {
					case ValueContainer.Global ignored -> 2;
					case ValueContainer.Reg ignored -> 0;
					case ValueContainer.Stack ignored -> 1;
				};
			}

			private int subSortValue(ValueContainer container) {
				return switch (container) {
					case ValueContainer.Global g -> g.index;
					case ValueContainer.Reg r -> r.index;
					case ValueContainer.Stack s -> s.index;
				};
			}
		});
		final StringBuilder buffer = new StringBuilder();
		for (ValueContainer location : locations) {
			if (buffer.length() > 0) {
				buffer.append(", ");
			}
			buffer.append(location);
			buffer.append("=");
			buffer.append(locationToValue.get(location));
		}
		return buffer.toString();
	}

	@Nullable
	private IRInstruction process(IRInstruction instruction) {
		return switch (instruction) {
			case IRAddrOf addrOf -> {
				final IRVar source = addrOf.source();
				yield store(addrOf.target(), new Value.AddrOf(getLocation(source)), instruction);
			}
			case IRBinary binary -> {
				final Value left = getValue(binary.left());
				final Value right = getValue(binary.right());

				forgetGlobberedRegisters(instruction);

				yield store(binary.target(), new Value.Binary(left, binary.op(), right), instruction);
			}
			case IRBranch ignored -> instruction;
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

				forgetGlobberedRegisters(instruction);

				removeObsoleteValues(container ->
						                     container instanceof ValueContainer.Stack(int index)
						                     && stackIndicesToRemove.contains(index));

				final IRVar target = call.target();
				if (target != null) {
					yield store(target, unknown(), instruction);
				}

				yield instruction;
			}
			case IRCast cast -> {
				final Value value = getValue(cast.source());
				yield store(cast.target(), new Value.Cast(cast.target().type(), value), instruction);
			}
			case IRComment ignored -> instruction;
			case IRCompare compare -> // for simplicity we use unknown as value
					store(compare.target(), unknown(), instruction);
			case IRJump ignored -> {
				locationToValue.clear();
				yield instruction;
			}
			case IRLabel ignored -> {
				locationToValue.clear();
				yield instruction;
			}
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
				yield store(target, value, instruction);
			}
			case IRMemStore store -> {
				final Value value = getValue(store.value());
				final Value addr = getValue(store.addr());
				if (addr instanceof Value.AddrOf(ValueContainer var)) {
					yield store(var, value, instruction);
				}
				if (debug) {
					System.out.println("unknown location " + addr);
				}
				yield instruction;
			}
			case IRMove move -> {
				final Value value = getValue(move.source());
				yield store(move.target(), value, instruction);
			}
			case IRString string -> store(string.target(), new Value.String0(string.stringIndex()), instruction);
			case IRUnary unary -> {
				final Value value = getValue(unary.source());
				yield store(unary.target(), new Value.Unary(unary.op(), value), instruction);
			}
			default -> throw new UnsupportedOperationException(instruction.toString());
		};
	}

	private void forgetGlobberedRegisters(@NotNull IRInstruction instruction) {
		final IntPredicate clobberedRegisters = psib.getClobberedRegisters(instruction);
		if (clobberedRegisters == null) {
			return;
		}
		// Clobbering any byte invalidates the cached value of the whole group.
		removeObsoleteValues(container ->
				                     container instanceof ValueContainer.Reg reg
				                     && reg.containsAny(clobberedRegisters));
	}

	private void removeObsoleteValues(Predicate<ValueContainer> isObsolete) {
		for (final Iterator<Map.Entry<ValueContainer, Value>> it = locationToValue.entrySet().iterator(); it.hasNext(); ) {
			final Map.Entry<ValueContainer, Value> entry = it.next();
			final ValueContainer container = entry.getKey();
			if (isObsolete.test(container)) {
				logValues = true;
				it.remove();
			}
		}
	}

	private IRInstruction checkOtherRegistersForValue(IRVar target, Value value, IRInstruction instruction) {
		for (Map.Entry<ValueContainer, Value> entry : locationToValue.entrySet()) {
			final ValueContainer container = entry.getKey();
			// A matching value in a narrower group does not describe all bytes
			// that the replacement move would read.
			if (!(container instanceof ValueContainer.Reg(int index, int amount))
			    || amount != psib.getRegisterAmount(target.type())) {
				continue;
			}

			final Value regValue = entry.getValue();
			if (regValue.equals(value)) {
				instruction = new IRMove(target,
				                         new IRVar(target.name(), index, VariableScope.register, target.type()));
				break;
			}
		}
		return instruction;
	}

	@Nullable
	private IRInstruction store(@NotNull IRVar target, @NotNull Value value, @NotNull IRInstruction instruction) {
		if (psib.isUsefulToBeReplacedWithMove(instruction)) {
			instruction = checkOtherRegistersForValue(target, value, instruction);
		}
		final ValueContainer location = getLocation(target);
		return store(location, value, instruction);
	}

	@Nullable
	private IRInstruction store(@NotNull ValueContainer location, @NotNull Value value, @NotNull IRInstruction instruction) {
		if (location instanceof ValueContainer.Reg target) {
			// For example, an i32 write to r5-r8 destroys a pointer in r6-r7.
			// Forget every partially overlapping cached group, but keep the exact
			// target entry until put() so redundant writes can still be detected.
			removeObsoleteValues(container -> container instanceof ValueContainer.Reg reg
			                                  && !reg.equals(target)
			                                  && reg.index < target.index + target.amount
			                                  && target.index < reg.index + reg.amount);
		}
		final Value prev = locationToValue.put(location, value);
		if (Objects.equals(prev, value)) {
			if (debug) {
				System.out.println("\t\t-> redundant");
			}
			return null;
		}
		logValues = true;
		return instruction;
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
		final ValueContainer location = getLocation(var);
		return getValue(location);
	}

	@NotNull
	private Value getValue(@NotNull ValueContainer location) {
		Value value = locationToValue.get(location);
		if (value == null) {
			value = unknown();
			locationToValue.put(location, value);
			logValues = true;
		}
		return value;
	}

	@NotNull
	private ValueContainer getLocation(@NotNull IRVar var) {
		return switch (var.scope()) {
			case register -> new ValueContainer.Reg(var.index(), psib.getRegisterAmount(var.type()));
			case function, parameter -> new ValueContainer.Stack(var.index());
			case global -> new ValueContainer.Global(var.index());
		};
	}

	@NotNull
	private Value.Unknown unknown() {
		return new Value.Unknown(unknownId++);
	}

	public sealed interface ValueContainer permits ValueContainer.Global, ValueContainer.Reg, ValueContainer.Stack {
		record Global(int index) implements ValueContainer {
			@NotNull
			@Override
			public String toString() {
				return "global+" + index;
			}
		}

		// Width is part of the cache key: knowing r4 does not mean we know r4-r5.
		record Reg(int index, int amount) implements ValueContainer {
			boolean containsAny(IntPredicate registers) {
				for (int register = index; register < index + amount; register++) {
					if (registers.test(register)) {
						return true;
					}
				}
				return false;
			}

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

	public interface PlatformSpecificInstructionBehavior {
		// x86 values use one allocator register regardless of their byte width.
		// Targets with byte registers override this to describe the whole group.
		default int getRegisterAmount(@NotNull Type type) {
			return 1;
		}

		@Nullable
		IntPredicate getClobberedRegisters(@NotNull IRInstruction instruction);

		default boolean isUsefulToBeReplacedWithMove(@NotNull IRInstruction instruction) {
			return !(instruction instanceof IRMove);
		}
	}
}
