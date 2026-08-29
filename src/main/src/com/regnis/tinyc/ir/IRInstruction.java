package com.regnis.tinyc.ir;

import java.util.*;

/**
 * @author Thomas Singer
 */
public interface IRInstruction {

	static void print(List<IRInstruction> instructions) {
		for (IRInstruction instruction : instructions) {
			if (!(instruction instanceof IRLabel)) {
				System.out.print("        ");
			}
			System.out.println(instruction);
		}
	}
}
