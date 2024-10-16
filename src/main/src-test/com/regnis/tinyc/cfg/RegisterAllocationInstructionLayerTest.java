package com.regnis.tinyc.cfg;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.junit.*;

import static com.regnis.tinyc.cfg.RegisterAllocationStrategy.*;
import static com.regnis.tinyc.cfg.RegisterAllocationStrategyTest.*;

/**
 * @author Thomas Singer
 */
public class RegisterAllocationInstructionLayerTest {

	@Test
	public void testBinaryArithmetic() {
		final IRVar sum = var("sum", 0);
		final IRVar b = var("b", 1);
		final IRVar c = var("c", 2);
		final IRBinary.Op op = IRBinary.Op.Add;
		final List<IRInstruction> instructions = new ArrayList<>();
		final RegisterAllocationStrategy strategy = new RegisterAllocationStrategy(2, 0, 1);
		final int nv0 = strategy.nonVolatile(0);
		final RegisterAllocationInstructionLayer layer = new RegisterAllocationInstructionLayer(strategy, instructions::add);
		// --------------------------------------------------------------------
		// target not live -> ignore
		layer.process(new IRBinary(sum, op, b, c, Location.DUMMY));
		assertEqualsVarStateAndInstructions(List.of(), strategy,
		                                    List.of(), instructions);
		// --------------------------------------------------------------------
		// only target is live
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(sum, List.of(CALL_ARG_1))
		)));
		layer.process(new IRBinary(sum, op, b, c, Location.DUMMY));
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(b, List.of(CALL_ARG_1)),
				                                    new LiveVarRegisterState(c, List.of(CALL_ARG_2))
		                                    ), strategy,
		                                    List.of(
				                                    new IRBinary(reg(CALL_ARG_1, sum),
				                                                 op,
				                                                 reg(CALL_ARG_1, b),
				                                                 reg(CALL_ARG_2, c),
				                                                 Location.DUMMY)
		                                    ), instructions);
		// --------------------------------------------------------------------
		// all vars are live
		// -> the first operand becomes live in the target, too
		instructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(sum, List.of(CALL_ARG_1)),
				new LiveVarRegisterState(b, List.of(CALL_ARG_2)),
				new LiveVarRegisterState(c, List.of(nv0))
		)));
		layer.process(new IRBinary(sum, op, b, c, Location.DUMMY));
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(c, List.of(nv0)),
				                                    new LiveVarRegisterState(b, List.of(CALL_ARG_2, CALL_ARG_1))
		                                    ), strategy,
		                                    List.of(
				                                    new IRBinary(reg(CALL_ARG_1, sum),
				                                                 op,
				                                                 reg(CALL_ARG_1, b),
				                                                 reg(nv0, c),
				                                                 Location.DUMMY)
		                                    ), instructions);
	}

	@Test
	public void testBinaryRelational() {
		final IRVar eq = new IRVar("result", 0, VariableScope.function, Type.BOOL, true);
		final IRVar b = var("b", 1);
		final IRVar c = var("c", 2);
		final IRVar d = var("d", 3);
		final IRVar e = var("e", 4);
		final IRVar f = var("f", 5);
		final IRBinary.Op op = IRBinary.Op.Equals;
		final List<IRInstruction> instructions = new ArrayList<>();
		final RegisterAllocationStrategy strategy = new RegisterAllocationStrategy(2, 0, 1);
		final int nv0 = strategy.nonVolatile(0);
		final int nv1 = strategy.nonVolatile(1);
		final RegisterAllocationInstructionLayer layer = new RegisterAllocationInstructionLayer(strategy, instructions::addFirst);
		// --------------------------------------------------------------------
		// target not live -> ignore
		layer.process(new IRBinary(eq, op, b, c, Location.DUMMY));
		assertEqualsVarStateAndInstructions(List.of(), strategy,
		                                    List.of(), instructions);
		// --------------------------------------------------------------------
		// only target is live
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(eq, List.of(CALL_ARG_1))
		)));
		layer.process(new IRBinary(eq, op, b, c, Location.DUMMY));
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(b, List.of(CALL_ARG_1)),
				                                    new LiveVarRegisterState(c, List.of(CALL_ARG_2))
		                                    ), strategy,
		                                    List.of(
				                                    new IRBinary(reg(CALL_ARG_1, eq),
				                                                 op,
				                                                 reg(CALL_ARG_1, b),
				                                                 reg(CALL_ARG_2, c),
				                                                 Location.DUMMY)
		                                    ), instructions);
		// --------------------------------------------------------------------
		// all vars are live
		instructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(eq, List.of(CALL_ARG_1)),
				new LiveVarRegisterState(b, List.of(CALL_ARG_2)),
				new LiveVarRegisterState(c, List.of(nv0))
		)));
		layer.process(new IRBinary(eq, op, b, c, Location.DUMMY));
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(b, List.of(CALL_ARG_2)),
				                                    new LiveVarRegisterState(c, List.of(nv0))
		                                    ), strategy,
		                                    List.of(
				                                    new IRBinary(reg(CALL_ARG_1, eq),
				                                                 op,
				                                                 reg(CALL_ARG_2, b),
				                                                 reg(nv0, c),
				                                                 Location.DUMMY)
		                                    ), instructions);
		// --------------------------------------------------------------------
		// one arg is live, but the other is not (no free regs)
		// -> reuse target
		instructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(eq, List.of(CALL_ARG_1)),
				new LiveVarRegisterState(b, List.of(CALL_ARG_2)),
				new LiveVarRegisterState(c, List.of(nv0, nv1))
		)));
		layer.process(new IRBinary(eq, op, b, d, Location.DUMMY));
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(b, List.of(CALL_ARG_2)),
				                                    new LiveVarRegisterState(c, List.of(nv0, nv1)),
				                                    new LiveVarRegisterState(d, List.of(CALL_ARG_1))
		                                    ), strategy,
		                                    List.of(
				                                    new IRBinary(reg(CALL_ARG_1, eq),
				                                                 op,
				                                                 reg(CALL_ARG_2, b),
				                                                 reg(CALL_ARG_1, d),
				                                                 Location.DUMMY)
		                                    ), instructions);
		// --------------------------------------------------------------------
		// one arg is live, but the other is not (no free regs, can't reuse target)
		// -> reuse register from multi-register var
		instructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(eq, List.of(CALL_RETURN_REG)),
				new LiveVarRegisterState(b, List.of(CALL_ARG_1)),
				new LiveVarRegisterState(c, List.of(CALL_ARG_2)),
				new LiveVarRegisterState(d, List.of(nv0, nv1))
		)));
		layer.process(new IRBinary(eq, op, b, e, Location.DUMMY));
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(b, List.of(CALL_ARG_1)),
				                                    new LiveVarRegisterState(c, List.of(CALL_ARG_2)),
				                                    new LiveVarRegisterState(d, List.of(nv1)),
				                                    new LiveVarRegisterState(e, List.of(nv0))
		                                    ), strategy,
		                                    List.of(
				                                    new IRBinary(reg(CALL_RETURN_REG, eq),
				                                                 op,
				                                                 reg(CALL_ARG_1, b),
				                                                 reg(nv0, e),
				                                                 Location.DUMMY),
				                                    movRegFromReg(d, nv0, nv1)
		                                    ), instructions);
		// --------------------------------------------------------------------
		// one arg is live, but the other is not (no free regs, can't reuse target)
		// -> reuse register from multi-register var
		instructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(eq, List.of(CALL_RETURN_REG)),
				new LiveVarRegisterState(b, List.of(CALL_ARG_1)),
				new LiveVarRegisterState(c, List.of(CALL_ARG_2)),
				new LiveVarRegisterState(d, List.of(nv0)),
				new LiveVarRegisterState(e, List.of(nv1))
		)));
		layer.process(new IRBinary(eq, op, b, f, Location.DUMMY));
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(b, List.of(CALL_ARG_1)),
				                                    new LiveVarRegisterState(d, List.of(nv0)),
				                                    new LiveVarRegisterState(e, List.of(nv1)),
				                                    new LiveVarRegisterState(c, List.of()),
				                                    new LiveVarRegisterState(f, List.of(CALL_ARG_2))
		                                    ), strategy,
		                                    List.of(
				                                    new IRBinary(reg(CALL_RETURN_REG, eq),
				                                                 op,
				                                                 reg(CALL_ARG_1, b),
				                                                 reg(CALL_ARG_2, f),
				                                                 Location.DUMMY),
				                                    movRegFromVar(CALL_ARG_2, c)
		                                    ), instructions);
	}
}