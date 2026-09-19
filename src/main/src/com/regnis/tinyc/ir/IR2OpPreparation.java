package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class IR2OpPreparation {

	static final String TMP_PREFIX = "t.";

	@NotNull
	public static IRFunction convertTo2Op(@NotNull IRFunction function) {
		final Pair<List<IRInstruction>, IRVarInfos> result = convertTo2Op(function.instructions(), function.varInfos());
		return function.derive(result.first(), result.second());
	}

	@NotNull
	static Pair<List<IRInstruction>, IRVarInfos> convertTo2Op(@NotNull List<IRInstruction> instructions, @NotNull IRVarInfos varInfos) {
		final IR2OpPreparation preparation = new IR2OpPreparation(varInfos);
		for (IRInstruction instruction : instructions) {
			preparation.handle(instruction);
		}
		return new Pair<>(preparation.instructions, preparation.localVarFactory.createVarInfos());
	}

	private final List<IRInstruction> instructions = new ArrayList<>();
	private final IRLocalVarFactory localVarFactory;

	private IR2OpPreparation(@NotNull IRVarInfos varInfos) {
		localVarFactory = new IRLocalVarFactory(varInfos);
	}

	private void handle(@NotNull IRInstruction instruction) {
		if (instruction instanceof IRBinary binary) {
			handle(binary);
		}
		else {
			add(instruction);
		}
	}

	private void handle(@NotNull IRBinary binary) {
		final IRVar target = binary.target();
		final IRVar left = binary.left();
		if (left.equals(target)) {
			add(binary);
			return;
		}

		final IRBinary.Op op = binary.op();
		final IRValue right = binary.right();
		final IRVar rightVar = right.var();
		if (rightVar != null && rightVar.equals(target)) {
			if (op.isCommutative()) {
				//   <op> a, b, a
				// becomes
				//   move a, a, b
				handle(new IRBinary(target, op, rightVar, left));
				return;
			}

			//   <op> a, b, a
			// becomes
			//   move tmp, b
			//   <op> tmp, tmp, a
			//   move a, tmp
			final IRVar tmp = localVarFactory.createVar(target, localVarFactory.suggestName(TMP_PREFIX));
			add(new IRMove(tmp, left));
			add(new IRBinary(tmp, op, tmp, target));
			add(new IRMove(target, tmp));
			return;
		}

		//   <op> a, b, c
		// becomes
		//   move a, b
		//   <op> a, a, b
		add(new IRMove(target, left));
		add(new IRBinary(target, op, target, right));
	}

	private void add(IRInstruction instruction) {
		instructions.add(instruction);
	}
}
