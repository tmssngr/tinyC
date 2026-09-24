package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class IRConverter {

	@NotNull
	public static IRFunction convert(@NotNull IRFunction function, @NotNull Type pointerIntType) {
		final Pair<List<IRInstruction>, IRVarInfos> result = convert(function.instructions(), function.varInfos(), pointerIntType);
		return function.derive(result.first(), result.second());
	}

	@NotNull
	public static Pair<List<IRInstruction>, IRVarInfos> convert(@NotNull List<IRInstruction> instructions, @NotNull IRVarInfos varInfos, @NotNull Type pointerIntType) {
		final IRLocalVarFactory localVarFactory = new IRLocalVarFactory(varInfos, pointerIntType);
		final IRConverterResultLayer resultLayer = new IRConverterResultLayer();

		IRConverterLayer layer = new IR2OpPreparation(localVarFactory, resultLayer);
		layer = new IRNonLocalVarLoweringConverterLayer(localVarFactory, layer);

		IRConverterLayer.process(layer, instructions);

		return new Pair<>(resultLayer.instructions, localVarFactory.createVarInfos());
	}
}
