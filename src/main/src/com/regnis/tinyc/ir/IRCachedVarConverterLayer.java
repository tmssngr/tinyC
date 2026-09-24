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
public final class IRCachedVarConverterLayer extends IRConverterAbstractLayer {

	static final String ADDR_PREFIX = "a.";
	static final String TMP_PREFIX = "tmp.";

	private final Map<IRVar, LocalVar> globalToLocal = new LinkedHashMap<>();
	private final IRLocalVarFactory tempVarFactory;

	public IRCachedVarConverterLayer(@NotNull IRLocalVarFactory tempVarFactory, @NotNull IRConverterLayer nextLayer) {
		super(nextLayer);
		this.tempVarFactory = tempVarFactory;
	}

	@Override
	public void process(@NotNull IRInstruction instruction) {
		switch (instruction) {
		case IRAddrOf addr -> {
			target(addr.target(), target -> new IRAddrOf(target, addr.source(), addr.location()));
		}
		case IRAddrOfArray addr -> {
			target(addr.addr(), target -> new IRAddrOfArray(target, addr.array(), addr.location()));
		}
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
			storeAllModified();
			final IRVar left = source(branch.left());
			IRValue right = branch.right();
			final IRVar rightVar = right.var();
			if (rightVar != null) {
				right = new IRValue(source(rightVar));
			}
			forward(new IRBranch(branch.op(), left, right, branch.target(), branch.nextLabel()));
		}
		case IRCast cast -> {
			final IRVar source = source(cast.source());
			target(cast.target(), target -> new IRCast(target, source, cast.location()));
		}
		case IRCall call -> {
			storeAllModified();

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

			invalidateAll();
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
		case IRJump jump -> {
			storeAllModified();
			forward(jump);
		}
		case IRLabel label -> {
			// a new basic block starts also if a block does not end with jump/branch,
			// but with a new label. So we need to store all modified local variables
			storeAllModified();
			forward(label);
		}
		case IRMemLoad load -> {
			storeAllModified();
			final IRVar source = source(load.addr());
			target(load.target(), target -> new IRMemLoad(target, source, load.location()));
		}
		case IRMemStore store -> {
			storeAllModified();
			final IRVar addr = source(store.addr());
			final IRVar value = source(store.value());
			forward(new IRMemStore(addr, value, store.location()));
		}
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
			final IRVar source = source(retValue.var(), true);
			storeAllModified();
			forward(new IRRetValue(source, retValue.location()));
		}
		case IRString literal -> {
			target(literal.target(), target -> new IRString(target, literal.stringIndex(), literal.location()));
		}
		case IRUnary unary -> {
			final IRVar source = source(unary.source());
			target(unary.target(), target -> new IRUnary(unary.op(), target, source));
		}
		default -> throw new UnsupportedOperationException(String.valueOf(instruction));
		}
	}

	@Override
	public void flush() {
		storeAllModified();
		super.flush();
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

	private void foreach(BiConsumer<IRVar, LocalVar> consumer) {
		for (Map.Entry<IRVar, LocalVar> entry : globalToLocal.entrySet()) {
			consumer.accept(entry.getKey(), entry.getValue());
		}
	}

	private void storeIfModified(LocalVar local, IRVar global) {
		if (local.modified) {
			Utils.assertTrue(local.validLocally);
			forward(new IRAddrOf(local.addr, global));
			forward(new IRMemStore(local.addr, local.var));
			local.modified = false;
		}
	}

	private LocalVar getLocal(IRVar var) {
		LocalVar local = globalToLocal.get(var);
		if (local == null) {
			final IRVar addr = tempVarFactory.createVar(Type.pointer(var.type()), ADDR_PREFIX + var.name());
			final String name = TMP_PREFIX + var.name();
			final IRVar localVar = tempVarFactory.createVar(var, name);
			local = new LocalVar(localVar, addr);
			globalToLocal.put(var, local);
		}
		return local;
	}

	private IRVar source(IRVar var) {
		return source(var, false);
	}

	private IRVar source(IRVar var, boolean storeIfModified) {
		if (var.scope() != VariableScope.global && tempVarFactory.canBeRegister(var)) {
			return var;
		}

		final LocalVar local = getLocal(var);
		if (!local.validLocally) {
			Utils.assertTrue(!local.modified);
			forward(new IRAddrOf(local.addr, var));
			forward(new IRMemLoad(local.var, local.addr));
			local.validLocally = true;
		}
		else if (storeIfModified) {
			storeIfModified(local, var);
		}
		return local.var;
	}

	private void target(IRVar var, Function<IRVar, IRInstruction> factory) {
		if (var.scope() != VariableScope.global && tempVarFactory.canBeRegister(var)) {
			forward(factory.apply(var));
			return;
		}

		final LocalVar local = getLocal(var);
		local.validLocally = true;
		local.modified = true;
		forward(factory.apply(local.var));
	}

	private static final class LocalVar {
		public final IRVar var;
		public final IRVar addr;

		public boolean validLocally;
		public boolean modified;

		private LocalVar(@NotNull IRVar var, IRVar addr) {
			Utils.assertTrue(var.scope() == VariableScope.function);
			Utils.assertTrue(addr.scope() == VariableScope.function);
			Utils.assertTrue(addr.type().isPointer());
			this.var = var;
			this.addr = addr;
		}
	}
}
