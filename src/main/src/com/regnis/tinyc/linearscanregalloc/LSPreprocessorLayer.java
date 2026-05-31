package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public interface LSPreprocessorLayer {

	void process(@NotNull IRInstruction instruction);

	void flush();

	static void process(LSPreprocessorLayer layer, List<IRInstruction> instructions) {
		for (IRInstruction instruction : instructions) {
			layer.process(instruction);
		}

		layer.flush();
	}
}
