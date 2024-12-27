package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class LSPreprocessorResultLayer implements LSPreprocessorLayer {

	public final List<IRInstruction> instructions = new ArrayList<>();

	public LSPreprocessorResultLayer() {
	}

	@Override
	public void process(@NotNull IRInstruction instruction) {
		instructions.add(instruction);
	}

	@Override
	public void flush() {
	}
}
