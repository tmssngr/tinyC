package com.regnis.tinyc.cfg;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;
import org.junit.*;

/**
 * @author Thomas Singer
 */
public class LinearScanRegisterAllocation2Test {

	@Test
	public void testExample() {
		final IRVar x = var("x", 0, Type.I16);
		final IRVar y = var("y", 1, Type.I16);
		final IRVar a = var("a", 2, Type.I32);
		final IRVar b = var("b", 3, Type.I64);
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

		final IRVar reg0 = reg(0, Type.I64);
		final IRVar reg1 = reg(1, Type.I32);
		final IRVar reg2 = reg(2, Type.I64);
		final IRVar regNV1 = reg(3, Type.I64);
		final IRVar regNV2 = reg(4, Type.I64);
		final List<BasicBlock> blocks = LinearScanRegisterAllocation2.process(cfg, new RegisterAllocationStrategy());
		Assert.assertEquals(1, blocks.size());
		Assert.assertEquals(List.of(
				                    new IRLiteral(x, 0, Location.DUMMY),
				                    new IRLiteral(y, 1, Location.DUMMY),
				                    new IRCall(a, "foo", List.of(
						                    x,
						                    y
				                    ), Location.DUMMY),
				                    new IRCall(reg0, "bar", List.of(
						                    y,
						                    x
				                    ), Location.DUMMY),
									new IRCopy(reg1, regNV1, Location.DUMMY),
									new IRCopy(reg2, reg0, Location.DUMMY),
				                    new IRCall(null, "bazz", List.of(
						                    reg1,
						                    reg2
				                    ), Location.DUMMY)
		                    ),
		                    blocks.getFirst().instructions());
	}

	@NotNull
	private IRVar var(String x, int index, Type type) {
		return new IRVar(x, index, VariableScope.function, type, true);
	}

	@NotNull
	private IRVar reg(int index, Type type) {
		return new IRVar("r." + index, index, VariableScope.register, type, true);
	}
}