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
	private final Type pointerIntType;

	public IRLocalVarFactory(@NotNull IRVarInfos varInfos, @NotNull Type pointerIntType) {
		this.varInfos = varInfos;
		this.pointerIntType = pointerIntType;
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
		return addVar(name, size, var.type());
	}

	@NotNull
	public IRVar createStackArgVar(@NotNull IRVar var, @NotNull String name) {
		final IRVar stackVar = createVar(var, name);
		cantBeRegister.add(stackVar);
		return stackVar;
	}

	@NotNull
	public IRVar createPointerVar(@NotNull String prefix) {
		final String name = createUniqueName(prefix);
		final Type type = Type.pointer(Type.VOID);
		final int size = Type.getSize(type, pointerIntType);
		return addVar(name, size, type);
	}

	@NotNull
	private IRVar addVar(@NotNull String name, int size, @NotNull Type type) {
		final int index = varDefs.size();
		final IRVar localVar = new IRVar(name, index, VariableScope.function, type);
		varDefs.add(new IRVarDef(localVar, size));
		return localVar;
	}

	private String createUniqueName(String prefix) {
		final Set<String> names = new HashSet<>();
		// there can already be variables with the same name (and even different type), e.g. from different scopes inside a method
		varDefs.forEach(vardef -> names.add(vardef.var().name()));

		int i = 0;
		while (true) {
			String name = prefix;
			if (i > 0) {
				name = name + i;
			}
			if (!names.contains(name)) {
				return name;
			}
			i++;
		}
	}
}
