package com.regnis.tinyc.ir;

import com.regnis.tinyc.ast.*;

import java.util.*;
import java.util.function.Function;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class IRReferencedVarAccessConverter extends IRConverterAbstractLayer {

	static final String ADDR_PREFIX = "a.";
	static final String TMP_PREFIX = "t.";

	private final IRLocalVarFactory localVarFactory;

	public IRReferencedVarAccessConverter(@NotNull IRLocalVarFactory localVarFactory, @NotNull IRConverterLayer nextLayer) {
		super(nextLayer);
		this.localVarFactory = localVarFactory;
	}

	@Override
	public void process(@NotNull IRInstruction instruction) {
		switch (instruction) {
		case IRAddrOf i ->
				target(i.target(), target -> new IRAddrOf(target, i.source(), i.location()));
		case IRAddrOfArray i ->
				target(i.addr(), target -> new IRAddrOf(target, i.array(), i.location()));
		case IRBinary i -> {
			final IRVar left = source(i.left());
			final IRValue right = source(i.right());
			target(i.target(), target -> new IRBinary(target, i.op(), left, right, i.location()));
		}
		case IRBranch i -> {
			final IRVar left = source(i.left());
			final IRValue right = source(i.right());
			forward(new IRBranch(i.op(), left, right, i.target(), i.nextLabel(), i.location()));
		}
		case IRCall i -> {
			final List<IRValue> args = new ArrayList<>();
			for (IRValue arg : i.args()) {
				args.add(source(arg));
			}

			final IRVar t = i.target();
			if (t != null) {
				target(t, target -> new IRCall(target, i.type(), i.name(), args, i.location()));
			}
			else {
				forward(new IRCall(null, i.type(), i.name(), args, i.location()));
			}
		}
		case IRCast i -> {
			final IRVar source = source(i.source());
			target(i.target(), target -> new IRCast(target, source, i.location()));
		}
		case IRCompare i -> {
			final IRVar left = source(i.left());
			final IRValue right = source(i.right());
			target(i.target(), target -> new IRCompare(target, i.op(), left, right, i.location()));
		}
		case IRMemLoad i -> {
			final IRVar addr = source(i.addr());
			target(i.target(), target -> new IRMemLoad(target, addr, i.location()));
		}
		case IRMemStore i -> {
			final IRVar addr = source(i.addr());
			final IRVar value = source(i.value());
			forward(new IRMemStore(addr, value, i.location()));
		}
		case IRMove i -> {
			final IRValue source = source(i.source());
			target(i.target(), target -> new IRMove(target, source, i.location()));
		}
		case IRRetValue i -> {
			final IRVar source = source(i.var());
			forward(new IRRetValue(source, i.location()));
		}
		case IRString i -> {
			target(i.target(), target -> new IRString(target, i.stringIndex(), i.location()));
		}
		case IRUnary i -> {
			final IRVar source = source(i.source());
			target(i.target(), target -> new IRUnary(i.op(), target, source));
		}
		default -> forward(instruction);
		}
	}

	@NotNull
	private IRValue source(@NotNull IRValue value) {
		final IRVar var = value.var();
		if (var == null) {
			return value;
		}
		return new IRValue(source(var));
	}

	@NotNull
	private IRVar source(@NotNull IRVar var) {
		if (var.scope() == VariableScope.global || localVarFactory.canBeRegister(var)) {
			return var;
		}

		final IRVar addrVar = localVarFactory.createVar(Type.pointer(var.type()), localVarFactory.suggestName(ADDR_PREFIX));
		final IRVar tmpVar = localVarFactory.createVar(var, localVarFactory.suggestName(TMP_PREFIX));
		forward(new IRAddrOf(addrVar, var));
		forward(new IRMemLoad(tmpVar, addrVar));
		return tmpVar;
	}

	private void target(IRVar var, Function<IRVar, IRInstruction> instructionFactory) {
		if (var.scope() == VariableScope.global || localVarFactory.canBeRegister(var)) {
			forward(instructionFactory.apply(var));
			return;
		}

		final IRVar tmpVar = localVarFactory.createVar(var, localVarFactory.suggestName(TMP_PREFIX));
		forward(instructionFactory.apply(tmpVar));
		final IRVar addrVar = localVarFactory.createVar(Type.pointer(var.type()), localVarFactory.suggestName(ADDR_PREFIX));
		forward(new IRAddrOf(addrVar, var));
		forward(new IRMemStore(addrVar, tmpVar));
	}
}
