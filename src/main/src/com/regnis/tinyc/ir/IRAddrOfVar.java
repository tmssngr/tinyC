package com.regnis.tinyc.ir;

import com.regnis.tinyc.ast.*;

/**
 * @author Thomas Singer
 */
public record IRAddrOfVar(int reg, VariableScope scope, int index, int offset) implements IRInstruction {
	@Override
	public String toString() {
		return "addrOf r" + reg + ", [" + index + "@"+ scope.name() + "]";
	}
}
