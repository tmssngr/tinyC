package com.regnis.tinyc.ir;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public abstract class IRConverterAbstractLayer implements IRConverterLayer {

	private final IRConverterLayer nextLayer;

	protected IRConverterAbstractLayer(@NotNull IRConverterLayer nextLayer) {
		this.nextLayer = nextLayer;
	}

	@Override
	public void flush() {
		nextLayer.flush();
	}

	protected final void forward(IRInstruction instruction) {
		nextLayer.process(instruction);
	}
}
