package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;
import java.util.function.Function;
import java.util.function.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class LSPreprocessorCachedVarLayer extends LSPreprocessorAbstractLayer {

	static final String PREFIX = "tmp.";

	private final Map<IRVar, LSTempRegisterVars.LocalVar> globalToLocal = new LinkedHashMap<>();
	private final LSTempRegisterVars tempRegisterVars;
	private final IRCanBeRegister canBeRegister;

	public LSPreprocessorCachedVarLayer(@NotNull IRCanBeRegister canBeRegister, @NotNull LSTempRegisterVars tempRegisterVars, @NotNull LSPreprocessorLayer nextLayer) {
		super(nextLayer);
		this.canBeRegister = canBeRegister;
		this.tempRegisterVars = tempRegisterVars;
	}

	@Override
	public void process(@NotNull IRInstruction instruction) {
		switch (instruction) {
		case IRAddrOf addr -> {
			final IRVar target = target(addr.target());
			forward(new IRAddrOf(target, addr.source(), addr.location()));
		}
		case IRAddrOfArray addr -> {
			final IRVar target = target(addr.addr());
			forward(new IRAddrOfArray(target, addr.array(), addr.location()));
		}
		case IRBinary binary -> {
			final IRVar left = source(binary.left());
			final IRVar right = source(binary.right());
			final IRVar target = target(binary.target());
			forward(new IRBinary(target, binary.op(), left, right, binary.location()));
		}
		case IRBranch branch -> {
			storeAllModified();
			final IRVar var = source(branch.conditionVar());
			forward(new IRBranch(var, branch.jumpOnTrue(), branch.target(), branch.nextLabel()));
		}
		case IRCast cast -> {
			final IRVar source = source(cast.source());
			final IRVar target = target(cast.target());
			forward(new IRCast(target, source, cast.location()));
		}
		case IRCall call -> {
			storeAllModified();

			final List<IRVar> args = new ArrayList<>();
			for (IRVar arg : call.args()) {
				args.add(source(arg));
			}

			IRVar target = call.target();
			if (target != null) {
				target = target(target);
			}
			forward(new IRCall(target, call.name(), args, call.location()));

			invalidateAll();
		}
		case IRComment c -> forward(c);
		case IRCompare compare -> {
			final IRVar left = source(compare.left());
			final IRVar right = source(compare.right());
			final IRVar target = target(compare.target());
			forward(new IRCompare(target, compare.op(), left, right, compare.location()));
		}
		case IRJump jump -> {
			storeAllModified();
			forward(jump);
		}
		case IRLabel label -> forward(label);
		case IRLiteral literal -> {
			final IRVar target = target(literal.target());
			forward(new IRLiteral(target, literal.value(), literal.location()));
		}
		case IRMove move -> {
			final IRVar source = source(move.source());
			final IRVar target = target(move.target());
			forward(new IRMove(target, source, move.location()));
		}
		case IRString literal -> {
			final IRVar target = target(literal.target());
			forward(new IRString(target, literal.stringIndex(), literal.location()));
		}
		case IRUnary unary -> {
			final IRVar source = source(unary.source());
			final IRVar target = target(unary.target());
			forward(new IRUnary(unary.op(), target, source));
		}
		case IRMemLoad load -> {
			storeAllModified();
			final IRVar source = source(load.addr());
			final IRVar target = target(load.target());
			forward(new IRMemLoad(target, source, load.location()));
		}
		case IRMemStore store -> {
			storeAllModified();
			final IRVar addr = source(store.addr());
			final IRVar value = source(store.value());
			forward(new IRMemStore(addr, value, store.location()));
		}
		case IRRetValue retValue -> {
			final IRVar source = source(retValue.var(), true);
			forward(new IRRetValue(source, retValue.location()));
		}
		default -> throw new UnsupportedOperationException(String.valueOf(instruction));
		}
	}

	@Override
	public void flush() {
		storeAllModified();
		super.flush();
	}

	@NotNull
	public Function<IRVar, IRVar> getLocalCopyToOriginal(@Nullable Function<IRVar, IRVar> parent) {
		final Map<IRVar, IRVar> map = new HashMap<>();
		for (Map.Entry<IRVar, LSTempRegisterVars.LocalVar> entry : globalToLocal.entrySet()) {
			final IRVar prev = map.put(entry.getValue().var, entry.getKey());
			Utils.assertTrue(prev == null);
		}
		return var -> {
			IRVar result = map.get(var);
			if (result == null && parent != null) {
				result = parent.apply(var);
			}
			return result;
		};
	}

	private void storeAllModified() {
		foreach((global, local) -> storeIfModified(local, global));
	}

	private void invalidateAll() {
		foreach((var, localVar) -> {
			Utils.assertTrue(!localVar.modified);
			localVar.validLocally = false;
		});
	}

	private void foreach(BiConsumer<IRVar, LSTempRegisterVars.LocalVar> consumer) {
		for (Map.Entry<IRVar, LSTempRegisterVars.LocalVar> entry : globalToLocal.entrySet()) {
			consumer.accept(entry.getKey(), entry.getValue());
		}
	}

	private void storeIfModified(LSTempRegisterVars.LocalVar local, IRVar global) {
		if (local.modified) {
			Utils.assertTrue(local.validLocally);
			forward(new IRMove(global, local.var, Location.DUMMY));
			local.modified = false;
		}
	}

	private LSTempRegisterVars.LocalVar getLocal(IRVar var) {
		LSTempRegisterVars.LocalVar local = globalToLocal.get(var);
		if (local == null) {
			final String name = PREFIX + var.name();
			local = tempRegisterVars.createVar(var, name);
			globalToLocal.put(var, local);
		}
		return local;
	}

	private IRVar source(IRVar var) {
		return source(var, false);
	}

	private IRVar source(IRVar var, boolean storeIfModified) {
		if (var.scope() != VariableScope.global && canBeRegister.canBeRegister(var)) {
			return var;
		}

		final LSTempRegisterVars.LocalVar local = getLocal(var);
		if (!local.validLocally) {
			Utils.assertTrue(!local.modified);
			forward(new IRMove(local.var, var, Location.DUMMY));
			local.validLocally = true;
		}
		else if (storeIfModified) {
			storeIfModified(local, var);
		}
		return local.var;
	}

	private IRVar target(IRVar var) {
		if (var.scope() != VariableScope.global && canBeRegister.canBeRegister(var)) {
			return var;
		}

		final LSTempRegisterVars.LocalVar local = getLocal(var);
		local.validLocally = true;
		local.modified = true;
		return local.var;
	}
}
