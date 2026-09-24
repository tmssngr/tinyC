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
	private final Type pointerIntType;

	public IRLocalVarFactory(@NotNull IRVarInfos varInfos, @NotNull Type pointerIntType) {
		this.varInfos = varInfos;
		this.pointerIntType = pointerIntType;
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

		final int size;
		if (var.scope() == VariableScope.global) {
			size = varInfos.global().size(var);
		}
		else {
			final IRVarDef varDef = getVarDef(var);
			size = varDef.size();
		}
		return addVar(name, size, var.type());
	}

	@NotNull
	public IRVar createVar(@NotNull Type type, @NotNull String name) {
		for (IRVarDef def : varDefs) {
			Utils.assertTrue(!def.var().name().equals(name));
		}

		final int size = Type.getSize(type, pointerIntType);
		return addVar(name, size, type);
	}

	@NotNull
	public IRVar createStackArgVar(@NotNull Type type, @NotNull String name) {
		final IRVar stackVar = createVar(type, name);
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

	private IRVarDef getVarDef(IRVar var) {
		for (IRVarDef varDef : varDefs) {
			if (varDef.var().equals(var)) {
				return varDef;
			}
		}
		throw new IllegalArgumentException("Unknown var " + var.toString(true));
	}

	@NotNull
	private IRVar addVar(@NotNull String name, int size, @NotNull Type type) {
		final int index = varDefs.size();
		final IRVar localVar = new IRVar(name, index, VariableScope.function, type);
		varDefs.add(new IRVarDef(localVar, size));
		existingNames.add(name);
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

	@NotNull
	public String suggestName(@NotNull String prefix) {
		for (int i = 1; true; i++) {
			final String name = prefix + i;
			if (!containsVarWithName(name)) {
				return name;
			}
		}
	}

	public boolean canBeRegister(@NotNull IRVar var) {
		if (cantBeRegister.contains(var)) {
			return false;
		}
		return varInfos.canBeRegister(var);
	}
}
