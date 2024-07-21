package com.regnis.tinyc.ir;

import com.regnis.tinyc.ast.Type;

import java.util.List;

/**
 * @author Thomas Singer
 */
public record IRCall(String label, List<Arg> args, int resultReg) implements IRInstruction {
	@Override
	public String toString() {
		final StringBuilder buffer = new StringBuilder();
		buffer.append("call ");
		if (resultReg >= 0) {
			buffer.append("r");
			buffer.append(resultReg);
			buffer.append(", ");
		}
		buffer.append(label);
		buffer.append(" (");
		boolean appendComma = false;
		for (Arg arg : args) {
			if (appendComma) {
				buffer.append(", ");
			}
			appendComma = true;
			buffer.append(arg.localVarIndex);
		}
		buffer.append(")");
		return buffer.toString();
	}

	public record Arg(int localVarIndex, Type type) {
	}
}
