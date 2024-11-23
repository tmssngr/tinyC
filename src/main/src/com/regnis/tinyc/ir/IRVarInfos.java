package com.regnis.tinyc.ir;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class IRVarInfos implements IRCanBeRegister {

	private final List<IRVarDef> vars;
	private final Set<IRVar> cantBeRegister;
	private final IRVarInfos parent;

	public IRVarInfos(@NotNull List<IRVarDef> vars, @NotNull Set<IRVar> cantBeRegister, @Nullable IRVarInfos parent) {
		this.vars = vars;
		this.cantBeRegister = cantBeRegister;
		this.parent = parent;
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
}
