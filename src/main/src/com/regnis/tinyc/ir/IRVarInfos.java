package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class IRVarInfos implements IRCanBeRegister {

	private final List<IRVarDef> vars;
	private final Set<IRVar> cantBeRegister;
	private final IRVarInfos parent;

	public IRVarInfos(@NotNull List<IRVarDef> vars, @NotNull Set<? extends IRVar> cantBeRegister, @Nullable IRVarInfos parent) {
		this.vars = List.copyOf(vars);
		this.cantBeRegister = Set.copyOf(cantBeRegister);
		this.parent = parent;

		int expectedIndex = 0;
		if (parent == null) {
			for (IRVarDef varDef : vars) {
				final IRVar var = varDef.var();
				Utils.assertTrue(expectedIndex == var.index());
				expectedIndex++;

				Utils.assertTrue(var.scope() == VariableScope.global);
			}
		}
		else {
			boolean expectLocalVar = false;
			for (IRVarDef varDef : vars) {
				final IRVar var = varDef.var();
				Utils.assertTrue(expectedIndex == var.index());
				expectedIndex++;

				final VariableScope scope = var.scope();
				if (expectLocalVar) {
					Utils.assertTrue(scope == VariableScope.function);
				}
				else if (scope == VariableScope.function) {
					expectLocalVar = true;
				}
				else {
					Utils.assertTrue(scope == VariableScope.argument);
				}
			}
		}
	}

	@Override
	public boolean canBeRegister(@NotNull IRVar var) {
		if (cantBeRegister.contains(var)) {
			return false;
		}

		return parent == null || parent.canBeRegister(var);
	}

	@Override
	public boolean equals(Object obj) {
		if (obj == this) {
			return true;
		}
		if (obj == null || obj.getClass() != this.getClass()) {
			return false;
		}
		final IRVarInfos other = (IRVarInfos)obj;
		return Objects.equals(this.vars, other.vars) &&
		       Objects.equals(this.cantBeRegister, other.cantBeRegister);
	}

	@Override
	public int hashCode() {
		return Objects.hash(vars, cantBeRegister);
	}

	@NotNull
	public List<IRVarDef> vars() {
		return vars;
	}

	@NotNull
	public Set<? extends IRVar> cantBeRegister() {
		return cantBeRegister;
	}

	@NotNull
	public IRVarInfos global() {
		return parent != null ? parent : this;
	}

	public int size(@NotNull IRVar var) {
		for (IRVarDef def : vars) {
			if (def.var().equals(var)) {
				return def.size();
			}
		}
		throw new IllegalStateException("Unknown var " + var);
	}

	public List<Type> getArgumentTypes() {
		final List<Type> types = new ArrayList<>();
		int expectedIndex = 0;
		for (IRVarDef varDef : vars) {
			final IRVar var = varDef.var();
			if (var.scope() != VariableScope.argument) {
				continue;
			}

			if (var.index() != expectedIndex) {
				throw new IllegalStateException();
			}

			types.add(var.type());

			expectedIndex++;
		}
		return types;
	}

	@NotNull
	public IRVarInfos derive(IRVarInfos newParent) {
		return new IRVarInfos(vars, cantBeRegister, newParent);
	}
}
