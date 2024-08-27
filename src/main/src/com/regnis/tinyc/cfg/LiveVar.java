package com.regnis.tinyc.cfg;

import com.regnis.tinyc.ast.VariableScope;
import com.regnis.tinyc.ir.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record LiveVar(VariableScope scope, int index, @NotNull String name) {
	@Override
	public String toString() {
		return name;
	}

	public static boolean equals(LiveVar var1, IRVar var2) {
		return var1.scope() == var2.scope()
		       && var1.index() == var2.index();
	}
}
