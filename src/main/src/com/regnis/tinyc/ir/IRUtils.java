package com.regnis.tinyc.ir;

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
			uses.accept(binary.right());
		}
		case IRBranch branch -> uses.accept(branch.conditionVar());
		case IRCall call -> {
			final IRVar target = call.target();
			if (target != null) {
				defines.accept(target);
			}
			for (IRVar arg : call.args()) {
				uses.accept(arg);
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
			uses.accept(compare.right());
		}
		case IRJump ignored -> {
		}
		case IRLabel ignored -> {
		}
		case IRLiteral literal -> defines.accept(literal.target());
		case IRMemLoad load -> {
			defines.accept(load.target());
			uses.accept(load.addr());
		}
		case IRMemStore store -> {
			uses.accept(store.addr());
			uses.accept(store.value());
		}
		case IRMove copy -> {
			defines.accept(copy.target());
			uses.accept(copy.source());
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
}
