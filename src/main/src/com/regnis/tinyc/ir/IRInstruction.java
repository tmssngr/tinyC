package com.regnis.tinyc.ir;

import java.util.*;

/**
 * @author Thomas Singer
 */
public interface IRInstruction {

	String toString(boolean comment);

	static void debugPrint(List<IRInstruction> instructions) {
		for (IRInstruction instruction : instructions) {
			System.out.println(instruction.toString(true));
		}
	}
}
