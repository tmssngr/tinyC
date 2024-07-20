package com.regnis.tinyc.ir;

import com.regnis.tinyc.ast.*;

/**
 * @author Thomas Singer
 */
public record IRCast(int targetReg, Type targetType, int sourceReg, Type sourceType) implements IRInstruction {
	@Override
	public String toString() {
		return "cast r" + targetReg + " (" + targetType + ")"+ ", r" + sourceReg + " (" + sourceType + ")";
	}
}
