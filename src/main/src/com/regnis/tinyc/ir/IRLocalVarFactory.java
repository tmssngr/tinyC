package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class IRLocalVarFactory {

	private final Set<String> existingNames = new HashSet<>();
	private final IRVarInfos varInfos;
	private final List<IRVarDef> varDefs;
	private final Set<IRVar> cantBeRegister;

	public IRLocalVarFactory(@NotNull IRVarInfos varInfos) {
		this.varInfos = varInfos;
		varDefs = new ArrayList<>(varInfos.vars());
		cantBeRegister = new HashSet<>(varInfos.cantBeRegister());

		for (IRVarDef varDef : varDefs) {
			final String name = varDef.var().name();
			existingNames.add(name);
			// there may be duplicate names, e.g. from two different if-scopes
		}
	}

	@NotNull
	public IRVarInfos createVarInfos() {
		return new IRVarInfos(varDefs, cantBeRegister, varInfos.global());
	}

	public boolean containsVarWithName(@NotNull String name) {
		return existingNames.contains(name);
	}

	@NotNull
	public IRVar createVar(@NotNull IRVar var, @NotNull String name) {
		Utils.assertTrue(!containsVarWithName(name));

		IRVarInfos varInfos = this.varInfos;
		if (var.scope() == VariableScope.global) {
			varInfos = varInfos.global();
		}
		final int size = varInfos.size(var);
		final int index = varDefs.size();
		final IRVar localVar = new IRVar(name, index, VariableScope.function, var.type());
		varDefs.add(new IRVarDef(localVar, size));
		existingNames.add(name);
		return localVar;
	}

	@NotNull
	public String suggestName(@NotNull String prefix) {
		for (int i = 1; true; i++) {
			final String name = prefix + i;
			if (!containsVarWithName(name)) {
				return name;
			}
		}
	}
}
