package com.regnis.tinyc.cfg;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;
import org.junit.*;

import static com.regnis.tinyc.cfg.RegisterAllocationStrategy.*;

/**
 * @author Thomas Singer
 */
public class LinearScanRegisterAllocation2Test {

	@Test
	public void testExample() {
		final IRVar x = var("x", 0);
		final IRVar y = var("y", 1);
		final IRVar a = var("a", 2);
		final IRVar b = var("b", 3);
		final ControlFlowGraph cfg = CfgGenerator.create("test", List.of(
				new IRLiteral(x, 0, Location.DUMMY),
				new IRLiteral(y, 1, Location.DUMMY),
				new IRCall(a, "foo", List.of(
						x,
						y
				), Location.DUMMY),
				new IRCall(b, "bar", List.of(
						y,
						x
				), Location.DUMMY),
				new IRCall(null, "bazz", List.of(
						a,
						b
				), Location.DUMMY)
		));

		final List<BasicBlock> blocks = LinearScanRegisterAllocation2.process(cfg, new RegisterAllocationStrategy());
		Assert.assertEquals(1, blocks.size());
		Assert.assertEquals(List.of(
				                    new IRLiteral(reg("x", CALL_ARG_0), 0, Location.DUMMY),
				                    move("x", NON_VOLATILE_REGISTER1, CALL_ARG_0),

				                    new IRLiteral(reg("y", CALL_ARG_1), 1, Location.DUMMY),
				                    move("y", NON_VOLATILE_REGISTER0, CALL_ARG_1),

				                    new IRCall(reg("a", CALL_RETURN_REG), "foo", List.of(
						                    reg("x", CALL_ARG_0),
						                    reg("y", CALL_ARG_1)
				                    ), Location.DUMMY),
				                    move("x", CALL_ARG_1, NON_VOLATILE_REGISTER0),
				                    move("y", CALL_ARG_0, NON_VOLATILE_REGISTER1),
				                    move("a", NON_VOLATILE_REGISTER0, CALL_RETURN_REG),

				                    new IRCall(reg("b", CALL_RETURN_REG), "bar", List.of(
						                    reg("y", CALL_ARG_0),
						                    reg("x", CALL_ARG_1)
				                    ), Location.DUMMY),
				                    move("a", CALL_ARG_0, NON_VOLATILE_REGISTER0),
				                    move("b", CALL_ARG_1, CALL_RETURN_REG),
				                    new IRCall(null, "bazz", List.of(
						                    reg("a", CALL_ARG_0),
						                    reg("b", CALL_ARG_1)
				                    ), Location.DUMMY)
		                    ),
		                    blocks.getFirst().instructions()
		);
	}

	@NotNull
	private static IRCopy move(String name, int to, int from) {
		return new IRCopy(reg(name, to), reg(name, from), Location.DUMMY);
	}

	@NotNull
	private static IRVar var(String x, int index) {
		return new IRVar(x, index, VariableScope.function, Type.I16, true);
	}

	@NotNull
	private static IRVar reg(LinearScanRegisterAllocation2Test test, int index) {
		return LinearScanRegisterAllocation2Test.reg("r." + index, index);
	}

	@NotNull
	private static IRVar reg(String name, int index) {
		return new IRVar(name, index, VariableScope.register, Type.I16, true);
	}
}