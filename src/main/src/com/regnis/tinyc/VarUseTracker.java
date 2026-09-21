package com.regnis.tinyc;

import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class VarUseTracker {
	private final Handler handler;

	public VarUseTracker(@NotNull Handler handler) {
		this.handler = handler;
	}

	public void process(@NotNull List<IRInstruction> instructions) {
		for (IRInstruction instruction : instructions) {
			process(instruction);
		}
	}

	private void process(@NotNull IRInstruction instruction) {
		switch (instruction) {
		case IRAddrOf addrOf -> readWrite(addrOf.target(), List.of(addrOf.source()));
		case IRAddrOfArray addrOf -> readWrite(addrOf.addr(), List.of(addrOf.array()));
		case IRBinary binary -> {
			final IRValue right = binary.right();
			final IRVar rightVar = right.var();
			if (rightVar != null) {
				readWrite(binary.target(), List.of(binary.left(), rightVar));
			}
			else {
				readWrite(binary.target(), List.of(binary.left()));
			}
		}
		case IRBranch branch -> {
			final IRValue right = branch.right();
			final IRVar rightVar = right.var();
			if (rightVar != null) {
				read(List.of(branch.left(), rightVar));
			}
			else {
				read(List.of(branch.left()));
			}
		}
		case IRCall call -> {
			final List<IRVar> argVars = new ArrayList<>();
			for (IRValue arg : call.args()) {
				final IRVar var = arg.var();
				if (var != null) {
					argVars.add(var);
				}
			}
			read(argVars);
			final IRVar target = call.target();
			if (target != null) {
				write(target);
			}
		}
		case IRCast cast -> readWrite(cast.target(), List.of(cast.source()));
		case IRComment ignored -> {
		}
		case IRCompare compare -> {
			final IRValue right = compare.right();
			final IRVar rightVar = right.var();
			if (rightVar != null) {
				readWrite(compare.target(), List.of(compare.left(), rightVar));
			}
			else {
				readWrite(compare.target(), List.of(compare.left()));
			}
		}
		case IRLabel ignored -> {
		}
		case IRJump ignored -> {
		}
		case IRMemLoad load -> readWrite(load.target(), List.of(load.addr()));
		case IRMemStore store -> read(List.of(store.addr(), store.value()));
		case IRMove move -> {
			final IRValue source = move.source();
			final IRVar sourceVar = source.var();
			if (sourceVar != null) {
				readWrite(move.target(), List.of(sourceVar));
			}
			else {
				write(move.target());
			}
		}
		case IRRetValue retValue -> {
			final IRVar var = retValue.value().var();
			if (var != null) {
				read(List.of(var));
			}
		}
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
			handler.read(var);
		}
	}

	private void write(IRVar var) {
		handler.written(var);
	}

	public interface Handler {
		default void read(@NotNull IRVar var) {
		}

		default void written(@NotNull IRVar var) {
		}
	}
}
