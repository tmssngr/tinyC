package com.regnis.tinyc.cfg;

import com.regnis.tinyc.*;
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
	public void testBinary() {
		final IRVar sum = var("sum", 0);
		final IRVar b = var("b", 1);
		final IRVar c = var("c", 2);
		final List<IRInstruction> instructions = new ArrayList<>();
		final RegisterAllocationStrategy strategy = new RegisterAllocationStrategy(2, 0, 1);
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(sum, List.of(CALL_ARG_0))
		)));
		final RegisterAllocationInstructionLayer layer = new RegisterAllocationInstructionLayer(strategy, instructions::add);
		layer.process(new IRBinary(sum, IRBinary.Op.Add, b, c, Location.DUMMY));
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(b, List.of(CALL_ARG_0)),
				                                    new LiveVarRegisterState(c, List.of(CALL_ARG_1))
		                                    ), strategy,
		                                    List.of(
				                                    new IRBinary(reg("sum", CALL_ARG_0),
				                                                 IRBinary.Op.Add,
				                                                 reg("b", CALL_ARG_0),
				                                                 reg("c", CALL_ARG_1),
				                                                 Location.DUMMY)
		                                    ), instructions);
	}
}