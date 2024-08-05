package com.regnis.tinyc.ir;

import com.regnis.tinyc.ast.*;

/**
 * @author Thomas Singer
 */
public record IRCompare(Op op, int resultReg, int leftReg, int rightReg, Type type) implements IRInstruction {
	@Override
	public String toString() {
		return "cmp r" + resultReg + ", (r" + leftReg + " " + op + " r" + rightReg + ") (" + type + ")";
	}

	public enum Op {
		Lt("<"), LtEq("<="), Equals("=="), NotEquals("!="), GtEq(">="), Gt(">");

		private final String s;

		Op(String s) {
			this.s = s;
		}

		@Override
		public String toString() {
			return s;
		}
	}
}
