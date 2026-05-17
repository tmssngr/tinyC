package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class IRLocalVarFactory {

	private final IRVarInfos varInfos;
	private final List<IRVarDef> varDefs;
	private final Set<IRVar> cantBeRegister;

	public IRLocalVarFactory(@NotNull IRVarInfos varInfos) {
		this.varInfos = varInfos;
		varDefs = new ArrayList<>(varInfos.vars());
		cantBeRegister = new HashSet<>(varInfos.cantBeRegister());
	}

	@NotNull
	public IRVarInfos createVarInfos() {
		return new IRVarInfos(varDefs, cantBeRegister, varInfos.global());
	}

	@NotNull
	public IRVar createVar(@NotNull IRVar var, @NotNull String name) {
		for (IRVarDef def : varDefs) {
			Utils.assertTrue(!def.var().name().equals(name));
		}

		IRVarInfos varInfos = this.varInfos;
		if (var.scope() == VariableScope.global) {
			varInfos = varInfos.global();
		}
		final int size = varInfos.size(var);
		final int index = varDefs.size();
		final IRVar localVar = new IRVar(name, index, VariableScope.function, var.type());
		varDefs.add(new IRVarDef(localVar, size));
		return localVar;
	}

	@NotNull
	public IRVar createStackArgVar(@NotNull IRVar var, @NotNull String name) {
		final IRVar stackVar = createVar(var, name);
		cantBeRegister.add(stackVar);
		return stackVar;
	}
}
