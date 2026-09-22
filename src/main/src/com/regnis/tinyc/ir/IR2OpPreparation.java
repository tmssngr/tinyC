package com.regnis.tinyc.ir;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class IR2OpPreparation extends IRConverterAbstractLayer {

	static final String TMP_PREFIX = "t.";

	private final IRLocalVarFactory localVarFactory;

	public IR2OpPreparation(@NotNull IRLocalVarFactory localVarFactory, @NotNull IRConverterLayer nextLayer) {
		super(nextLayer);
		this.localVarFactory = localVarFactory;
	}

	@Override
	public void process(@NotNull IRInstruction instruction) {
		if (instruction instanceof IRBinary binary) {
			handle(binary);
		}
		else {
			forward(instruction);
		}
	}

	private void handle(@NotNull IRBinary binary) {
		final IRVar target = binary.target();
		final IRVar left = binary.left();
		if (left.equals(target)) {
			forward(binary);
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
			forward(new IRMove(tmp, left));
			forward(new IRBinary(tmp, op, tmp, target));
			forward(new IRMove(target, tmp));
			return;
		}

		//   <op> a, b, c
		// becomes
		//   move a, b
		//   <op> a, a, b
		forward(new IRMove(target, left));
		forward(new IRBinary(target, op, target, right));
	}
}
