package com.regnis.tinyc.cfg;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;
import java.util.function.*;

import org.jetbrains.annotations.*;
import org.junit.*;

import static org.junit.Assert.assertEquals;

/**
 * @author Thomas Singer
 */
public class RegisterAllocationStrategyTest {

	@Test
	public void testCall() {
		final var strategy = new RegisterAllocationStrategy();
		final List<IRInstruction> instructions = new ArrayList<>();
		final Consumer<IRInstruction> consumer = instructions::addFirst;
		// bazz(a, b)
		strategy.afterCall(null, consumer);
		strategy.prepareCallArgs(List.of(
				var("a", 2),
				var("b", 3)
		), consumer);
		assertEquals(new RegisterAllocationStrategy.AllLiveVarRegisterState(List.of(
				new RegisterAllocationStrategy.LiveVarRegisterState("a", 2, VariableScope.function, Type.I16, List.of(RegisterAllocationStrategy.CALL_ARG_0)),
				new RegisterAllocationStrategy.LiveVarRegisterState("b", 3, VariableScope.function, Type.I16, List.of(RegisterAllocationStrategy.CALL_ARG_1))
		)), strategy.getState());
		assertEquals(List.of(), instructions);

		// b = bar(y, x)
		strategy.afterCall(var("b", 3), consumer);
		strategy.prepareCallArgs(List.of(
				var("y", 1),
				var("x", 0)
		), consumer);
		assertEquals(new RegisterAllocationStrategy.AllLiveVarRegisterState(List.of(
				new RegisterAllocationStrategy.LiveVarRegisterState("a", 2, VariableScope.function, Type.I16, List.of(RegisterAllocationStrategy.FIRST_NON_VOLATILE_REGISTER)),
				new RegisterAllocationStrategy.LiveVarRegisterState("y", 1, VariableScope.function, Type.I16, List.of(RegisterAllocationStrategy.CALL_ARG_0)),
				new RegisterAllocationStrategy.LiveVarRegisterState("x", 0, VariableScope.function, Type.I16, List.of(RegisterAllocationStrategy.CALL_ARG_1))
		)), strategy.getState());
		assertEquals(List.of(
				move("a", RegisterAllocationStrategy.CALL_ARG_0, RegisterAllocationStrategy.NON_VOLATILE_REGISTER0),
				move("b", RegisterAllocationStrategy.CALL_ARG_1, RegisterAllocationStrategy.CALL_RETURN_REG)
		), instructions);
		instructions.clear();

		// a = foo(x, y)
		strategy.afterCall(var("a", 2), consumer);
		strategy.prepareCallArgs(List.of(
				var("x", 0),
				var("y", 1)
		), consumer);
		assertEquals(new RegisterAllocationStrategy.AllLiveVarRegisterState(List.of(
				new RegisterAllocationStrategy.LiveVarRegisterState("x", 0, VariableScope.function, Type.I16,
				                                                    List.of(
						                                                    RegisterAllocationStrategy.NON_VOLATILE_REGISTER1,
						                                                    RegisterAllocationStrategy.CALL_ARG_0
				                                                    )),
				new RegisterAllocationStrategy.LiveVarRegisterState("y", 1, VariableScope.function, Type.I16,
				                                                    List.of(
						                                                    RegisterAllocationStrategy.NON_VOLATILE_REGISTER0,
						                                                    RegisterAllocationStrategy.CALL_ARG_1
				                                                    ))
		)), strategy.getState());
		assertEquals(List.of(
				move("x", RegisterAllocationStrategy.CALL_ARG_1, RegisterAllocationStrategy.NON_VOLATILE_REGISTER1),
				move("y", RegisterAllocationStrategy.CALL_ARG_0, RegisterAllocationStrategy.NON_VOLATILE_REGISTER0),
				move("a", RegisterAllocationStrategy.NON_VOLATILE_REGISTER0, RegisterAllocationStrategy.CALL_RETURN_REG)
		), instructions);
	}

	@NotNull
	private static IRCopy move(String name, int from, int to) {
		return new IRCopy(reg(name, to),
		                  reg(name, from),
		                  Location.DUMMY);
	}

	@NotNull
	private static IRVar var(String name, int index) {
		return new IRVar(name, index, VariableScope.function, Type.I16, true);
	}

	@NotNull
	private static IRVar reg(String name, int index) {
		return new IRVar(name, index, VariableScope.register, Type.I16, true);
	}
}