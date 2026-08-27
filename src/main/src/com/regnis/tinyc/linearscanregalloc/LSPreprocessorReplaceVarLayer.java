package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class LSPreprocessorReplaceVarLayer extends LSPreprocessorAbstractLayer {

	@NotNull private final Map<IRVar, IRVar> registerArgToLocalVar;

	public LSPreprocessorReplaceVarLayer(@NotNull Map<IRVar, IRVar> registerArgToLocalVar, @NotNull LSPreprocessorLayer nextLayer) {
		super(nextLayer);
		this.registerArgToLocalVar = registerArgToLocalVar;
	}

	@Override
	public void process(@NotNull IRInstruction instruction) {
		switch (instruction) {
		case IRAddrOf i -> forward(new IRAddrOf(replace(i.target()), replace(i.source())));
		case IRAddrOfArray i -> forward(new IRAddrOfArray(replace(i.addr()), i.array()));
		case IRBinary i -> forward(new IRBinary(replace(i.target()), i.op(), replace(i.left()), replace(i.right())));
		case IRBranch i -> forward(new IRBranch(replace(i.conditionVar()), i.jumpOnTrue(), i.target(), i.nextLabel()));
		case IRCall i -> {
			IRVar target = i.target();
			if (target != null) {
				target = replace(target);
			}
			final List<IRVar> args = new ArrayList<>();
			for (IRVar arg : i.args()) {
				args.add(replace(arg));
			}
			forward(new IRCall(target, i.type(), i.name(), args));
		}
		case IRCast i -> forward(new IRCast(replace(i.target()), replace(i.source())));
		case IRComment i -> forward(i);
		case IRCompare i -> forward(new IRCompare(replace(i.target()), i.op(), replace(i.left()), replace(i.right())));
		case IRJump i -> forward(i);
		case IRLabel i -> forward(i);
		case IRMemLoad i -> forward(new IRMemLoad(replace(i.target()), replace(i.addr())));
		case IRMemStore i -> forward(new IRMemStore(replace(i.addr()), replace(i.value())));
		case IRMove i -> {
			final IRValue source = i.source();
			final IRVar sourceVar = source.var();
			if (sourceVar != null) {
				forward(new IRMove(replace(i.target()), replace(sourceVar)));
			}
			else {
				forward(new IRMove(replace(i.target()), source.value()));
			}
		}
		case IRRetValue i -> forward(new IRRetValue(replace(i.var())));
		case IRString i -> forward(new IRString(replace(i.target()), i.stringIndex()));
		case IRUnary i -> forward(new IRUnary(i.op(), replace(i.target()), replace(i.source())));
		default -> throw new UnsupportedOperationException();
		}
	}

	@NotNull
	private IRVar replace(@NotNull IRVar var) {
		return registerArgToLocalVar.getOrDefault(var, var);
	}
}
