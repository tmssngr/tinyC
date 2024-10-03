package com.regnis.tinyc.ir;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public abstract class IRVarReplacer {

	@NotNull
	protected abstract IRVar replace(@NotNull IRVar var);

	public IRInstruction replaceFor(IRInstruction instruction) {
		return switch (instruction) {
			case IRComment ignored -> instruction;
			case IRLabel ignored -> instruction;
			case IRJump ignored -> instruction;
			case IRLiteral literal -> new IRLiteral(replace(literal.target()), literal.value(), literal.location());
			case IRString literal -> new IRString(replace(literal.target()), literal.stringIndex(), literal.location());
			case IRCopy copy -> new IRCopy(replace(copy.target()), replace(copy.source()), copy.location());
			case IRBinary binary -> new IRBinary(replace(binary.target()), binary.op(), replace(binary.left()), replace(binary.right()), binary.location());
			case IRUnary unary -> new IRUnary(unary.op(), replace(unary.target()), replace(unary.source()));
			case IRCast cast -> new IRCast(replace(cast.target()), replace(cast.source()), cast.location());
			case IRAddrOf addrOf -> new IRAddrOf(replace(addrOf.target()), replace(addrOf.source()), addrOf.location());
			case IRAddrOfArray addrOf -> new IRAddrOfArray(replace(addrOf.addr()), replace(addrOf.array()), addrOf.location());
			case IRMemLoad load -> new IRMemLoad(replace(load.target()), replace(load.addr()), load.location());
			case IRMemStore store -> new IRMemStore(replace(store.addr()), replace(store.value()), store.location());
			case IRBranch branch -> new IRBranch(replace(branch.conditionVar()), branch.jumpOnTrue(), branch.target(), branch.nextLabel());
			case IRRetValue retValue -> new IRRetValue(replace(retValue.var()), retValue.location());
			case IRCall call -> {
				final List<IRVar> args = new ArrayList<>();
				for (IRVar arg : call.args()) {
					args.add(replace(arg));
				}
				IRVar target = call.target();
				if (target != null) {
					target = replace(target);
				}
				yield new IRCall(target, call.name(), args, call.location());
			}
			default -> throw new UnsupportedOperationException(String.valueOf(instruction));
		};
	}
}
