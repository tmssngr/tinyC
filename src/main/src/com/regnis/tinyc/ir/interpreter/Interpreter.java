package com.regnis.tinyc.ir.interpreter;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class Interpreter {

	private final IRFunction function;
	private final CallHandler callHandler;

	public Interpreter(@NotNull IRFunction function, @NotNull CallHandler callHandler) {
		this.function = function;
		this.callHandler = callHandler;
	}

	public void run(int maxCycles) {
		final Machine machine = new Machine(function.varInfos(), function.instructions(), callHandler);

		int cycles = 0;
		while (machine.execute()) {
			cycles++;
			if (cycles >= maxCycles) {
				throw new IllegalStateException("not ended after " + cycles + " cycles");
			}
		}
	}

	public interface CallHandler {

		@Nullable
		Value call(String name, List<Value> args);
	}

	public sealed interface Value permits IntValue, BoolValue, PointerValue {
		Type type();
	}

	public record IntValue(int value, @NotNull Type type) implements Value {
		public IntValue {
			Utils.assertTrue(type.isInt());
		}

		@NotNull
		@Override
		public String toString() {
			return value + " (" + type + ")";
		}
	}

	public record BoolValue(boolean value) implements Value {
		@Override
		public Type type() {
			return Type.BOOL;
		}

		@NotNull
		@Override
		public String toString() {
			return Boolean.toString(value);
		}
	}

	public record PointerValue(Array array, int offset) implements Value {
		@Override
		public Type type() {
			return Type.POINTER_U8;
		}

		@NotNull
		@Override
		public String toString() {
			return "@" + array.name + "+" + offset;
		}

		public Value get(int index) {
			return array.get(index + offset);
		}
	}

	public static class Var {

		private final String name;
		private final Type type;

		private Object value;

		public Var(@NotNull IRVar var) {
			this.name = var.name();
			this.type = var.type();
		}

		@Override
		public String toString() {
			final StringBuilder buffer = new StringBuilder();
			if (value == null) {
				buffer.append("unknown");
			}
			else {
				buffer.append(value);
			}
			buffer.append(" ");
			buffer.append(type);
			return buffer.toString();
		}

		@NotNull
		public Value value() {
			Utils.assertTrue(value instanceof Value);
			return (Value)value;
		}

		public int getInt() {
			Utils.assertTrue(type.isInt());
			Utils.assertTrue(value instanceof IntValue);
			return ((IntValue)value).value;
		}

		public boolean getBool() {
			Utils.assertTrue(type == Type.BOOL);
			Utils.assertTrue(value instanceof BoolValue);
			return ((BoolValue)value).value;
		}

		@NotNull
		public PointerValue getPointer() {
			Utils.assertTrue(type.isPointer());
			Utils.assertTrue(value instanceof PointerValue);
			return (PointerValue)value;
		}

		public void set(int value) {
			Utils.assertTrue(type.isInt() || type.isPointer());
			setValue(new IntValue(value, type));
		}

		public void set(boolean value) {
			Utils.assertTrue(type == Type.BOOL);
			setValue(new BoolValue(value));
		}

		public void setPointer(Array array, int offset) {
			Utils.assertTrue(type.isPointer());
			setValue(new PointerValue(array, offset));
		}

		private void setValue(@NotNull Value value) {
			this.value = value;
			System.out.println("  " + name + " = " + value);
		}
	}

	private static class Array {
		private final String name;
		private final Value[] buffer;

		public Array(String name, int size) {
			this.name = name;
			buffer = new Value[size];
		}

		public Value get(int index) {
			return buffer[index];
		}

		private void set(int index, byte value) {
			buffer[index] = new IntValue(value, Type.U8);
			System.out.println("  " + name + "[" + index + "] = " + value);
		}
	}

	private static class Machine {

		private final Map<IRVar, Var> vars = new HashMap<>();
		private final Map<IRVar, Array> arrays = new HashMap<>();
		private final Map<String, Integer> labels = new HashMap<>();
		private final List<IRInstruction> instructions = new ArrayList<>();
		private final CallHandler callHandler;

		private int pc;

		public Machine(IRVarInfos varInfos, List<IRInstruction> instructions, CallHandler callHandler) {
			this.callHandler = callHandler;
			for (IRVarDef def : varInfos.vars()) {
				final IRVar var = def.var();
				Utils.assertTrue(vars.get(var) == null);
				if (def.isArray()) {
					arrays.put(var, new Array(var.name(), def.size()));
				}
				else {
					vars.put(var, new Var(var));
				}
			}

			this.instructions.addAll(instructions);

			for (int i = 0; i < instructions.size(); i++) {
				final IRInstruction instruction = instructions.get(i);
				if (instruction instanceof IRLabel(String label)) {
					labels.put(label, i);
				}
			}
		}

		public boolean execute() {
			if (pc == instructions.size()) {
				return false;
			}

			final IRInstruction instruction = instructions.get(pc);
			System.out.println(pc + "  " + instruction);
			pc++;
			execute(instruction);
			return true;
		}

		private void execute(@NotNull IRInstruction instruction) {
			switch (instruction) {
			case IRAddrOfArray addrOf -> addrOf(get(addrOf.addr()), getArray(addrOf.array()));
			case IRBinary binary -> binary(get(binary.target()), binary.op(), get(binary.left()), get(binary.right()));
			case IRBranch branch -> branch(get(branch.conditionVar()), branch.jumpOnTrue(), branch.target(), branch.nextLabel());
			case IRCall call -> {
				final IRVar target = call.target();
				final Var varTarget = target != null ? get(target) : null;
				final List<Value> argValues = new ArrayList<>();
				for (IRVar arg : call.args()) {
					argValues.add(get(arg).value());
				}
				final Value result = callHandler.call(call.name(), argValues);
				if (varTarget != null) {
					Utils.assertTrue(result != null);
					Utils.assertTrue(result.type() == varTarget.type);
				}
				else {
					Utils.assertTrue(result == null);
				}
			}
			case IRCast cast -> cast(get(cast.target()), get(cast.source()));
			case IRCompare compare -> compare(get(compare.target()), compare.op(), get(compare.left()), get(compare.right()));
			case IRLabel ignored -> {
				// nothing to do
			}
			case IRLiteral literal -> get(literal.target()).set(literal.value());
			case IRMemStore store -> store(get(store.addr()), get(store.value()));
			case IRMove move -> move(get(move.target()), get(move.source()));
			default -> throw new UnsupportedOperationException(instruction.toString());
			}
		}

		private void addrOf(Var target, Array source) {
			Utils.assertTrue(target.type.isPointer());
			target.setPointer(source, 0);
		}

		private void binary(Var target, IRBinary.Op op, Var left, Var right) {
			switch (op) {
			case Add -> {
				if (target.type.isPointer()) {
					Utils.assertTrue(target.type == left.type);
					Utils.assertTrue(right.type.isInt());
					final PointerValue p = left.getPointer();
					target.setPointer(p.array, p.offset + right.getInt());
					return;
				}
				Utils.assertTrue(target.type.isInt());
				Utils.assertTrue(target.type == left.type);
				Utils.assertTrue(target.type == right.type);
				target.set(left.getInt() + right.getInt());
			}
			case Sub -> {
				Utils.assertTrue(target.type.isInt());
				Utils.assertTrue(target.type == left.type);
				Utils.assertTrue(target.type == right.type);
				target.set(left.getInt() - right.getInt());
			}
			case Div -> {
				Utils.assertTrue(target.type.isInt());
				Utils.assertTrue(target.type == left.type);
				Utils.assertTrue(target.type == right.type);
				target.set(left.getInt() / right.getInt());
			}
			case Mod -> {
				Utils.assertTrue(target.type.isInt());
				Utils.assertTrue(target.type == left.type);
				Utils.assertTrue(target.type == right.type);
				target.set(left.getInt() % right.getInt());
			}
			default -> throw new UnsupportedOperationException(op.toString());
			}
		}

		private void branch(Var conditionVar, boolean jumpOnTrue, String target, String nextLabel) {
			Utils.assertTrue(conditionVar.type == Type.BOOL);

			if (conditionVar.getBool() == jumpOnTrue) {
				pc = labels.get(target);
			}
		}

		private void compare(Var target, IRCompare.Op op, Var left, Var right) {
			Utils.assertTrue(target.type == Type.BOOL);
			Utils.assertTrue(left.type == right.type);
			switch (op) {
			case Equals -> {
				Utils.assertTrue(left.type.isInt());
				target.set(left.getInt() == right.getInt());
			}
			default -> throw new UnsupportedOperationException(op.toString());
			}
		}

		private void cast(Var target, Var source) {
			if (target.type.isInt()) {
				Utils.assertTrue(source.type.isInt());
				if (target.type == Type.U8) {
					target.set(source.getInt() % 0xFF);
				}
				else if (target.type == Type.I64) {
					target.set(source.getInt());
				}
				else {
					throw new UnsupportedOperationException();
				}
			}
			else if (target.type.isPointer()) {
				Utils.assertTrue(source.type == Type.I64);
				target.set(source.getInt());
			}
			else {
				throw new UnsupportedOperationException();
			}
		}

		private void move(Var target, Var source) {
			if (target.type.isInt()) {
				Utils.assertTrue(target.type == source.type);
				target.set(source.getInt());
			}
			else {
				throw new UnsupportedOperationException();
			}
		}

		private void store(Var addr, Var value) {
			Utils.assertTrue(addr.type.isPointer());
			Utils.assertTrue(value.type == Type.U8);
			final PointerValue p = addr.getPointer();
			p.array.set(p.offset, (byte)value.getInt());
		}

		@NotNull
		private Var get(IRVar var) {
			final Var var1 = vars.get(var);
			Utils.assertTrue(var1 != null, "unknown var " + var);
			return var1;
		}

		@NotNull
		private Array getArray(IRVar var) {
			final Array array = arrays.get(var);
			Utils.assertTrue(array != null, "unknown var " + var);
			return array;
		}
	}
}
