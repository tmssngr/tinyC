package com.regnis.tinyc.ir;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public abstract class IRVarReplacer {

	@NotNull
	protected abstract IRVar replace(@NotNull IRVar var);

	public IRVarReplacer() {
	}

	@NotNull
	public List<IRInstruction> replace(@NotNull List<IRInstruction> instructions) {
		final List<IRInstruction> newInstructions = new ArrayList<>(instructions.size());
		for (IRInstruction instruction : instructions) {
			newInstructions.add(replaceFor(instruction));
		}
		return newInstructions;
	}

	@NotNull
	public IRInstruction replaceFor(@NotNull IRInstruction instruction) {
		return switch (instruction) {
			case IRAddrOf addrOf -> new IRAddrOf(replace(addrOf.target()), replace(addrOf.source()), addrOf.location());
			case IRAddrOfArray addrOf -> new IRAddrOfArray(replace(addrOf.addr()), replace(addrOf.array()), addrOf.location());
			case IRBinary binary -> new IRBinary(replace(binary.target()), binary.op(), replace(binary.left()), replace(binary.right()), binary.location());
			case IRBranch branch -> new IRBranch(branch.op(), replace(branch.left()), replace(branch.right()), branch.target(), branch.nextLabel(), branch.location());
			case IRCall call -> {
				final List<IRValue> args = new ArrayList<>();
				for (IRValue arg : call.args()) {
					args.add(replace(arg));
				}
				IRVar target = call.target();
				if (target != null) {
					target = replace(target);
				}
				yield new IRCall(target, call.type(), call.name(), args, call.location());
			}
			case IRCast cast -> new IRCast(replace(cast.target()), replace(cast.source()), cast.location());
			case IRComment ignored -> instruction;
			case IRCompare compare -> new IRCompare(replace(compare.target()), compare.op(), replace(compare.left()), replace(compare.right()), compare.location());
			case IRLabel ignored -> instruction;
			case IRJump ignored -> instruction;
			case IRMemLoad load -> new IRMemLoad(replace(load.target()), replace(load.addr()), load.location());
			case IRMemStore store -> new IRMemStore(replace(store.addr()), replace(store.value()), store.location());
			case IRMove move -> new IRMove(replace(move.target()), replace(move.source()), move.location());
			case IRRetValue retValue -> new IRRetValue(replace(retValue.value()), retValue.location());
			case IRString literal -> new IRString(replace(literal.target()), literal.stringIndex(), literal.location());
			case IRUnary unary -> new IRUnary(unary.op(), replace(unary.target()), replace(unary.source()));
			default -> throw new UnsupportedOperationException(String.valueOf(instruction));
		};
	}

	@NotNull
	private IRValue replace(@NotNull IRValue value) {
		final IRVar var = value.var();
		if (var != null) {
			value = new IRValue(replace(var));
		}
		return value;
	}
}
