package com.regnis.tinyc.ir;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public interface IRConverterLayer {

	void process(@NotNull IRInstruction instruction);

	void flush();

	static void process(IRConverterLayer layer, List<IRInstruction> instructions) {
		for (IRInstruction instruction : instructions) {
			layer.process(instruction);
		}

		layer.flush();
	}
}
