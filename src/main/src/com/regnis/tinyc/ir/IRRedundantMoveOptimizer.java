package com.regnis.tinyc.ir;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.linearscanregalloc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class IRRedundantMoveOptimizer {

	private final Map<Value, Value> varToKnownValue = new HashMap<>();
	private final int volatileRegisterCount;

	public IRRedundantMoveOptimizer(@NotNull LSArchitecture architecture) {
		volatileRegisterCount = architecture.callingConvention().volatileRegisterCount();
	}

	public void optimize(@NotNull List<IRInstruction> instructions) {
		varToKnownValue.clear();

		for (final Iterator<IRInstruction> it = instructions.iterator(); it.hasNext(); ) {
			final IRInstruction instruction = it.next();
			switch (instruction) {
			case IRAddrOf a -> unknownContentWritten(a.target());
			case IRAddrOfArray a -> unknownContentWritten(a.addr());
			case IRBinary b -> unknownContentWritten(b.target());
			case IRBranch ignored -> {
			}
			case IRCall c -> {
				final IRVar target = c.target();
				if (target != null) {
					unknownContentWritten(target);
				}

				for (final Iterator<Map.Entry<Value, Value>> entryIt = varToKnownValue.entrySet().iterator(); entryIt.hasNext(); ) {
					final Map.Entry<Value, Value> entry = entryIt.next();
					final Value var = entry.getKey();
					if (var instanceof Register(int reg) && reg < volatileRegisterCount) {
						entryIt.remove();
					}
				}
			}
			case IRCast c -> unknownContentWritten(c.target());
			case IRComment ignored -> {
			}
			case IRCompare c -> unknownContentWritten(c.target());
			case IRDebugComment ignored -> {
			}
			case IRJump ignored -> {
			}
			case IRLabel ignored -> {
			}
			case IRLiteral literal -> unknownContentWritten(literal.target());
			case IRMemLoad load -> unknownContentWritten(load.target());
			case IRMemStore ignored -> {
			}
			case IRRetValue ignored -> {
			}
			case IRString string -> unknownContentWritten(string.target());
			case IRUnary unary -> unknownContentWritten(unary.target());
			case IRMove move -> {
				final Value target = getValue(move.target());
				final Value source = getValue(move.source());
				final Value prev = varToKnownValue.put(target, source);
				if (Objects.equals(prev, source)) {
					it.remove();
				}
			}
			default -> throw new UnsupportedOperationException();
			}
		}
	}

	private void unknownContentWritten(IRVar var) {
		final Value key = getValue(var);
		varToKnownValue.remove(key);
	}

	private Value getValue(IRVar var) {
		if (var.scope() == VariableScope.register) {
			return new Register(var.index());
		}
		return new Var(var);
	}

	private interface Value {
	}

	private record Register(int reg) implements Value {
	}

	private record Var(IRVar var) implements Value {
	}
}
