package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.ir.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
abstract class LSPreprocessorAbstractLayer implements LSPreprocessorLayer {

	private final LSPreprocessorLayer nextLayer;

	protected LSPreprocessorAbstractLayer(@NotNull LSPreprocessorLayer nextLayer) {
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
