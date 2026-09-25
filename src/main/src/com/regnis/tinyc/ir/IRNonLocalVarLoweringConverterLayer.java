package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;

import java.util.*;
import java.util.function.*;
import java.util.function.Function;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class IRNonLocalVarLoweringConverterLayer extends IRConverterAbstractLayer {

	public static final String ADDR_PREFIX = "a.";
	public static final String TMP_PREFIX = "t.";

	private final IRLocalVarFactory tempVarFactory;

	public IRNonLocalVarLoweringConverterLayer(@NotNull IRLocalVarFactory tempVarFactory, @NotNull IRConverterLayer nextLayer) {
		super(nextLayer);
		this.tempVarFactory = tempVarFactory;
	}

	@Override
	public void process(@NotNull IRInstruction instruction) {
		switch (instruction) {
		case IRAddrOf addr -> target(addr.target(), target -> new IRAddrOf(target, addr.source(), addr.location()));
		case IRAddrOfArray addr -> target(addr.addr(), target -> new IRAddrOfArray(target, addr.array(), addr.location()));
		case IRBinary binary -> {
			final IRVar left = source(binary.left());
			final IRValue right = binary.right();
			final IRVar rightVar = right.var();
			if (rightVar != null) {
				target(binary.target(), target -> new IRBinary(target, binary.op(), left, new IRValue(source(rightVar)), binary.location()));
			}
			else {
				target(binary.target(), target -> new IRBinary(target, binary.op(), left, right, binary.location()));
			}
		}
		case IRBranch branch -> {
			final IRVar left = source(branch.left());
			IRValue right = branch.right();
			final IRVar rightVar = right.var();
			if (rightVar != null) {
				right = new IRValue(source(rightVar));
			}
			forward(new IRBranch(branch.op(), left, right, branch.target(), branch.nextLabel()));
		}
		case IRCast cast -> target(cast.target(), target -> new IRCast(target, source(cast.source()), cast.location()));
		case IRCall call -> {
			final List<IRValue> args = new ArrayList<>();
			for (IRValue arg : call.args()) {
				final IRVar var = arg.var();
				if (var != null) {
					arg = new IRValue(source(var));
				}
				args.add(arg);
			}

			final IRVar target = call.target();
			if (target != null) {
				target(target, t -> new IRCall(t, call.type(), call.name(), args, call.location()));
			}
			else {
				forward(new IRCall(null, call.type(), call.name(), args, call.location()));
			}
		}
		case IRComment c -> forward(c);
		case IRCompare compare -> {
			final IRVar left = source(compare.left());
			final IRValue right = compare.right();
			final IRVar rightVar = right.var();
			if (rightVar != null) {
				target(compare.target(), target -> new IRCompare(target, compare.op(), left, new IRValue(source(rightVar)), compare.location()));
			}
			else {
				target(compare.target(), target -> new IRCompare(target, compare.op(), left, right, compare.location()));
			}
		}
		case IRJump jump -> forward(jump);
		case IRLabel label -> forward(label);
		case IRMemLoad load -> target(load.target(), target -> new IRMemLoad(target, source(load.addr()), load.location()));
		case IRMemStore store -> forward(new IRMemStore(source(store.addr()), source(store.value()), store.location()));
		case IRMove move -> {
			final IRValue source = move.source();
			final IRVar sourceVar = source.var();
			if (sourceVar != null) {
				target(move.target(), target -> new IRMove(target, source(sourceVar), move.location()));
			}
			else {
				target(move.target(), target -> new IRMove(target, source.value(), move.location()));
			}
		}
		case IRRetValue retValue -> {
			final IRValue value = retValue.value();
			final IRVar var = value.var();
			if (var != null) {
				final IRVar source = source(var, true);
				forward(new IRRetValue(source, retValue.location()));
			}
			else {
				forward(retValue);
			}
		}
		case IRString literal -> target(literal.target(), target -> new IRString(target, literal.stringIndex(), literal.location()));
		case IRUnary unary -> target(unary.target(), target -> new IRUnary(unary.op(), target, source(unary.source())));
		default -> throw new UnsupportedOperationException(String.valueOf(instruction));
		}
	}

	private IRVar source(IRVar var) {
		return source(var, false);
	}

	private IRVar source(IRVar var, boolean storeIfModified) {
		if (var.scope() != VariableScope.global && tempVarFactory.canBeRegister(var)) {
			return var;
		}

		final IRVar addrVar = tempVarFactory.createVar(Type.pointer(var.type()), ADDR_PREFIX + var.name());
		final IRVar tmpVar = tempVarFactory.createVar(var, TMP_PREFIX + var.name());
		forward(new IRAddrOf(addrVar, var));
		forward(new IRMemLoad(tmpVar, addrVar));
		return tmpVar;
	}

	private void target(IRVar var, Function<IRVar, IRInstruction> factory) {
		if (var.scope() != VariableScope.global && tempVarFactory.canBeRegister(var)) {
			forward(factory.apply(var));
			return;
		}

		final IRVar addrVar = tempVarFactory.createVar(Type.pointer(var.type()), ADDR_PREFIX + var.name());
		final IRVar tmpVar = tempVarFactory.createVar(var, TMP_PREFIX + var.name());
		forward(factory.apply(tmpVar));
		forward(new IRAddrOf(addrVar, var));
		forward(new IRMemStore(addrVar, tmpVar));
	}

}
