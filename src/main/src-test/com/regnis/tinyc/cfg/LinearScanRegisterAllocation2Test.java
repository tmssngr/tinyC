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
	public void testReadmeExample() {
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

		final RegisterAllocationStrategy strategy = new RegisterAllocationStrategy(2, 0, 2);
		final int nonVolatile0 = strategy.nonVolatile(0);
		final int nonVolatile1 = strategy.nonVolatile(1);
		final List<BasicBlock> blocks = LinearScanRegisterAllocation2.process(cfg, strategy);
		Assert.assertEquals(1, blocks.size());
		Assert.assertEquals(List.of(
				                    new IRLiteral(reg("x", CALL_ARG_1), 0, Location.DUMMY),
				                    move("x", nonVolatile1, CALL_ARG_1),

				                    new IRLiteral(reg("y", CALL_ARG_2), 1, Location.DUMMY),
				                    move("y", nonVolatile0, CALL_ARG_2),

				                    new IRCall(reg("a", CALL_RETURN_REG), "foo", List.of(
						                    reg("x", CALL_ARG_1),
						                    reg("y", CALL_ARG_2)
				                    ), Location.DUMMY),
				                    move("x", CALL_ARG_2, nonVolatile1),
				                    move("y", CALL_ARG_1, nonVolatile0),
				                    move("a", nonVolatile0, CALL_RETURN_REG),

				                    new IRCall(reg("b", CALL_RETURN_REG), "bar", List.of(
						                    reg("y", CALL_ARG_1),
						                    reg("x", CALL_ARG_2)
				                    ), Location.DUMMY),
				                    move("a", CALL_ARG_1, nonVolatile0),
				                    move("b", CALL_ARG_2, CALL_RETURN_REG),
				                    new IRCall(null, "bazz", List.of(
						                    reg("a", CALL_ARG_1),
						                    reg("b", CALL_ARG_2)
				                    ), Location.DUMMY)
		                    ),
		                    blocks.getFirst().instructions()
		);
	}

	@Test
	public void testLongCall() {
		final IRVar a = var("a", 0);
		final IRVar b = var("b", 1);
		final IRVar c = var("c", 2);
		final IRVar d = var("d", 3);
		final IRVar e = var("e", 4);
		final ControlFlowGraph cfg = CfgGenerator.create("test", List.of(
				new IRLiteral(a, 10, Location.DUMMY),
				new IRLiteral(b, 11, Location.DUMMY),
				new IRLiteral(c, 12, Location.DUMMY),
				new IRLiteral(d, 13, Location.DUMMY),
				new IRLiteral(e, 14, Location.DUMMY),
				new IRCall(null, "foo", List.of(a, b, c, d, e), Location.DUMMY)
		));

		final RegisterAllocationStrategy strategy = new RegisterAllocationStrategy(2, 0, 2);
		final int nonVolatile0 = strategy.nonVolatile(0);
		final int nonVolatile1 = strategy.nonVolatile(1);
		final List<BasicBlock> blocks = LinearScanRegisterAllocation2.process(cfg, strategy);
		Assert.assertEquals(1, blocks.size());
		Assert.assertEquals(List.of(
				                    new IRLiteral(reg("a", CALL_ARG_1), 10, Location.DUMMY),
				                    new IRLiteral(reg("b", CALL_ARG_2), 11, Location.DUMMY),
				                    new IRLiteral(reg("c", nonVolatile0), 12, Location.DUMMY),
				                    new IRLiteral(reg("d", nonVolatile1), 13, Location.DUMMY),
				                    new IRLiteral(reg("e", CALL_RETURN_REG), 14, Location.DUMMY),
				                    move(e, CALL_RETURN_REG),
				                    new IRCall(null, "foo", List.of(
						                    reg("a", CALL_ARG_1),
						                    reg("b", CALL_ARG_2),
						                    reg("c", nonVolatile0),
						                    reg("d", nonVolatile1),
						                    e
				                    ), Location.DUMMY)
		                    ),
		                    blocks.getFirst().instructions()
		);
	}

	@NotNull
	private IRCopy move(@NotNull IRVar to, int from) {
		return new IRCopy(to, reg(to.name(), from), Location.DUMMY);
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
	private static IRVar reg(String name, int index) {
		return new IRVar(name, index, VariableScope.register, Type.I16, true);
	}
}