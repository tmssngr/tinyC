package com.regnis.tinyc.ir;

import java.util.*;

/**
 * @author Thomas Singer
 */
public interface IRInstruction {

	static void debugPrint(List<IRInstruction> instructions) {
		for (IRInstruction instruction : instructions) {
			if (!(instruction instanceof IRLabel)) {
				System.out.print("\t");
			}
			System.out.println(instruction);
		}
	}
}
