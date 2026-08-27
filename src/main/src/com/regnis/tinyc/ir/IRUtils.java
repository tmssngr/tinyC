package com.regnis.tinyc.ir;

import com.regnis.tinyc.ast.*;

import java.util.*;
import java.util.function.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class IRUtils {

	public static void getVars(@NotNull IRInstruction instruction, @NotNull Consumer<IRVar> uses, @NotNull Consumer<IRVar> defines) {
		switch (instruction) {
		case IRAddrOf addrOf -> {
			defines.accept(addrOf.target());
			uses.accept(addrOf.source());
		}
		case IRAddrOfArray addrOfArray -> defines.accept(addrOfArray.addr());
		case IRBinary binary -> {
			defines.accept(binary.target());
			uses.accept(binary.left());
			final IRValue right = binary.right();
			final IRVar rightVar = right.var();
			if (rightVar != null) {
				uses.accept(rightVar);
			}
		}
		case IRBranch branch -> uses.accept(branch.conditionVar());
		case IRCall call -> {
			final IRVar target = call.target();
			if (target != null) {
				defines.accept(target);
			}
			for (IRValue arg : call.args()) {
				final IRVar var = arg.var();
				if (var != null) {
					uses.accept(var);
				}
			}
		}
		case IRCast cast -> {
			defines.accept(cast.target());
			uses.accept(cast.source());
		}
		case IRComment ignored -> {
		}
		case IRCompare compare -> {
			defines.accept(compare.target());
			uses.accept(compare.left());
			final IRVar rightVar = compare.right().var();
			if (rightVar != null) {
				uses.accept(rightVar);
			}
		}
		case IRJump ignored -> {
		}
		case IRLabel ignored -> {
		}
		case IRMemLoad load -> {
			defines.accept(load.target());
			uses.accept(load.addr());
		}
		case IRMemStore store -> {
			uses.accept(store.addr());
			uses.accept(store.value());
		}
		case IRMove move -> {
			defines.accept(move.target());
			final IRVar source = move.source().var();
			if (source != null) {
				uses.accept(source);
			}
		}
		case IRRetValue retValue -> uses.accept(retValue.var());
		case IRString string -> defines.accept(string.target());
		case IRUnary unary -> {
			defines.accept(unary.target());
			uses.accept(unary.source());
		}
		default -> throw new UnsupportedOperationException(instruction.toString());
		}
	}

	public static int getMaxReg(List<IRInstruction> instructions, @Nullable Type pointerIntType) {
		class MaxRegConsumer implements Consumer<IRVar> {
			private int maxReg;

			@Override
			public void accept(IRVar var) {
				if (var.scope() != VariableScope.register) {
					return;
				}

				final int size = pointerIntType != null ? Type.getSize(var.type(), pointerIntType) : 1;
				maxReg = Math.max(maxReg, var.index() + size);
			}
		}
		final MaxRegConsumer consumer = new MaxRegConsumer();
		for (IRInstruction instruction : instructions) {
			getVars(instruction, consumer, consumer);
		}
		return consumer.maxReg;
	}
}
