package com.regnis.tinyc.ir;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class IRConverterResultLayer implements IRConverterLayer {

	public final List<IRInstruction> instructions = new ArrayList<>();

	public IRConverterResultLayer() {
	}

	@Override
	public void process(@NotNull IRInstruction instruction) {
		instructions.add(instruction);
	}

	@Override
	public void flush() {
	}
}
