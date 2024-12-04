package com.regnis.tinyc;

import com.regnis.tinyc.ir.*;

import java.util.*;

/**
 * @author Thomas Singer
 */
public abstract class CleanupUnusedVariables {
	protected abstract void process(IRVar var, boolean read);

	protected void process(IRInstruction instruction) {
		switch (instruction) {
		case IRAddrOf addrOf -> readWrite(addrOf.target(), List.of(addrOf.source()));
		case IRAddrOfArray addrOf -> readWrite(addrOf.addr(), List.of(addrOf.array()));
		case IRBinary binary -> readWrite(binary.target(), List.of(binary.left(), binary.right()));
		case IRBranch branch -> read(List.of(branch.conditionVar()));
		case IRCall call -> {
			read(call.args());
			final IRVar target = call.target();
			if (target != null) {
				write(target);
			}
		}
		case IRCast cast -> readWrite(cast.target(), List.of(cast.source()));
		case IRComment ignored -> {
		}
		case IRCompare compare -> readWrite(compare.target(), List.of(compare.left(), compare.right()));
		case IRLabel ignored -> {
		}
		case IRLiteral literal -> write(literal.target());
		case IRJump ignored -> {
		}
		case IRMemLoad load -> readWrite(load.target(), List.of(load.addr()));
		case IRMemStore store -> read(List.of(store.addr(), store.value()));
		case IRMove copy -> readWrite(copy.target(), List.of(copy.source()));
		case IRRetValue retValue -> read(List.of(retValue.var()));
		case IRString literal -> write(literal.target());
		case IRUnary unary -> readWrite(unary.target(), List.of(unary.source()));
		default -> throw new UnsupportedOperationException(String.valueOf(instruction));
		}
	}

	private void readWrite(IRVar write, List<IRVar> vars) {
		read(vars);
		write(write);
	}

	private void read(List<IRVar> vars) {
		for (IRVar var : vars) {
			process(var, true);
		}
	}

	private void write(IRVar var) {
		process(var, false);
	}
}
