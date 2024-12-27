package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ir.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class LSPreprocessorX86OperationsLayer extends LSPreprocessorAbstractLayer {
	public LSPreprocessorX86OperationsLayer(@NotNull LSPreprocessorLayer nextLayer) {
		super(nextLayer);
	}

	@Override
	public void process(@NotNull IRInstruction instruction) {
		switch (instruction) {
		case IRBinary binary -> {
			final IRBinary.Op op = binary.op();
			// https://www.felixcloutier.com/x86/idiv
			// (rdx rax) / %reg -> rax
			// (rdx rax) % %reg -> rdx
			if (op == IRBinary.Op.Div) {
				final IRVar left = binary.left();
				Utils.assertTrue(left.equals(binary.target()));
				final IRVar rax = left.asRegister(0);
				forward(new IRMove(rax, left, Location.DUMMY));
				forward(new IRBinary(rax, op, rax, binary.right(), Location.DUMMY));
				forward(new IRMove(left, rax, Location.DUMMY));
				return;
			}

			if (op == IRBinary.Op.Mod) {
				final IRVar left = binary.left();
				Utils.assertTrue(left.equals(binary.target()));
				final IRVar rax = left.asRegister(0);
				final IRVar rdx = left.asRegister(2);
				forward(new IRMove(rax, left, Location.DUMMY));
				forward(new IRBinary(rdx, op, rax, binary.right(), Location.DUMMY));
				forward(new IRMove(left, rdx, Location.DUMMY));
				return;
			}

			// https://www.felixcloutier.com/x86/sal:sar:shl:shr
			// the right argument needs to be in cl
			if (op == IRBinary.Op.ShiftLeft
			    || op == IRBinary.Op.ShiftRight) {
				final IRVar left = binary.left();
				Utils.assertTrue(left.equals(binary.target()));
				final IRVar right = binary.right();
				final IRVar rcx = right.asRegister(1);
				forward(new IRMove(rcx, right, Location.DUMMY));
				forward(new IRBinary(binary.target(), op, left, rcx, Location.DUMMY));
				return;
			}

			forward(binary);
		}
		default -> forward(instruction);
		}
	}
}
