package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class LSTempRegisterVars {

	private final List<IRVarDef> varDefs;
	private final IRVarInfos varInfos;

	public LSTempRegisterVars(@NotNull IRVarInfos varInfos) {
		varDefs = new ArrayList<>(varInfos.vars());
		this.varInfos = varInfos;
	}

	@NotNull
	public IRVarInfos createVarInfos() {
		return new IRVarInfos(varDefs, varInfos.cantBeRegister(), varInfos.global());
	}

	public LocalVar createVar(@NotNull IRVar var, @NotNull String name) {
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
		return new LocalVar(localVar);
	}

	public static final class LocalVar {
		public final IRVar var;

		public boolean validLocally;
		public boolean modified;

		private LocalVar(@NotNull IRVar var) {
			Utils.assertTrue(var.scope() == VariableScope.function);
			this.var = var;
		}
	}
}
