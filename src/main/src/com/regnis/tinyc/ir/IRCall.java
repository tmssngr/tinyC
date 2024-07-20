package com.regnis.tinyc.ir;

/**
 * @author Thomas Singer
 */
public record IRCall(String label, java.util.List<Arg> args) implements IRInstruction {
	public record Arg(int reg, com.regnis.tinyc.ast.Type type) {
	}
}
