package com.regnis.tinyc.ast;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record StmtCall(@NotNull ExprFuncCall call) implements Statement {

	@Override
	public String toString() {
		return call.toString();
	}
}
