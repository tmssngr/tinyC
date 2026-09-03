package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ir.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class LSPreprocessorX86OperationsLayer extends LSPreprocessorAbstractLayer {
	private final X86Registers registers;

	public LSPreprocessorX86OperationsLayer(@NotNull X86Registers registers, @NotNull LSPreprocessorLayer nextLayer) {
		super(nextLayer);
		this.registers = registers;
	}

	@Override
	public void process(@NotNull IRInstruction instruction) {
		if (instruction instanceof IRBinary binary) {
			final IRBinary.Op op = binary.op();
			final IRVar left = binary.left();
			Utils.assertTrue(left.equals(binary.target()));
			final IRValue right = binary.right();
			final IRVar rightVar = right.var();
			// https://www.felixcloutier.com/x86/idiv
			// (rdx rax) / %reg -> rax
			// (rdx rax) % %reg -> rdx
			if (op == IRBinary.Op.Div) {
				final IRVar rax = left.asRegister(registers.rax());
				forward(new IRMove(rax, left));
				if (rightVar != null) {
					forward(new IRBinary(rax, op, rax, rightVar));
				}
				else {
					forward(new IRBinary(rax, op, rax, right));
				}
				forward(new IRMove(left, rax));
				return;
			}

			if (op == IRBinary.Op.Mod) {
				final IRVar rax = left.asRegister(registers.rax());
				final IRVar rdx = left.asRegister(registers.rdx());
				forward(new IRMove(rax, left));
				if (rightVar != null) {
					forward(new IRBinary(rdx, op, rax, rightVar));
				}
				else {
					forward(new IRBinary(rdx, op, rax, right));
				}
				forward(new IRMove(left, rdx));
				return;
			}

			// https://www.felixcloutier.com/x86/sal:sar:shl:shr
			// the right argument needs to be in cl
			if (op == IRBinary.Op.ShiftLeft
			    || op == IRBinary.Op.ShiftRight) {
				if (rightVar != null) {
					final IRVar rcx = rightVar.asRegister(registers.rcx());
					forward(new IRMove(rcx, rightVar));
					forward(new IRBinary(binary.target(), op, left, rcx));
				}
				else {
					forward(new IRBinary(binary.target(), op, left, right));
				}
				return;
			}

			forward(binary);
		}
		else {
			forward(instruction);
		}
	}
}
