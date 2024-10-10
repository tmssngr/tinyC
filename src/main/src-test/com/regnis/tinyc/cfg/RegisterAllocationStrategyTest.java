package com.regnis.tinyc.cfg;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

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
		// bazz(a, b)
		strategy.prevState(null,
		                               List.of(
				                               var("a", 2),
				                               var("b", 3)
		                               ), instructions::add);
		assertEquals(new RegisterAllocationStrategy.AllLiveVarRegisterState(List.of(
				new RegisterAllocationStrategy.LiveVarRegisterState("a", 2, VariableScope.function, Type.I16, List.of(RegisterAllocationStrategy.CALL_ARG_0)),
				new RegisterAllocationStrategy.LiveVarRegisterState("b", 3, VariableScope.function, Type.I16, List.of(RegisterAllocationStrategy.CALL_ARG_1))
		)), strategy.getState());
		assertEquals(List.of(), instructions);

		// b = bar(y, x)
		strategy.prevState(var("b", 3),
		                           List.of(
				                           var("y", 1),
				                           var("x", 0)
		                           ), instructions::add);
		assertEquals(new RegisterAllocationStrategy.AllLiveVarRegisterState(List.of(
				new RegisterAllocationStrategy.LiveVarRegisterState("a", 2, VariableScope.function, Type.I16, List.of(RegisterAllocationStrategy.FIRST_NON_VOLATILE_REGISTER)),
				new RegisterAllocationStrategy.LiveVarRegisterState("y", 1, VariableScope.function, Type.I16, List.of(RegisterAllocationStrategy.CALL_ARG_0)),
				new RegisterAllocationStrategy.LiveVarRegisterState("x", 0, VariableScope.function, Type.I16, List.of(RegisterAllocationStrategy.CALL_ARG_1))
		)), strategy.getState());
		// in reverse order
		assertEquals(List.of(
				new IRCopy(reg("b", RegisterAllocationStrategy.CALL_RETURN_REG),
				           reg("b", RegisterAllocationStrategy.CALL_ARG_1),
				           Location.DUMMY),
				new IRCopy(reg("a", RegisterAllocationStrategy.NON_VOLATILE_REGISTER0),
				           reg("a", RegisterAllocationStrategy.CALL_ARG_0),
				           Location.DUMMY)
		), instructions);
		instructions.clear();

		// a = foo(x, y)
		strategy.prevState(var("a", 2),
		                           List.of(
				                           var("x", 0),
				                           var("y", 1)
		                           ), instructions::add);
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
		// in reverse order
		assertEquals(List.of(
				new IRCopy(reg("a", RegisterAllocationStrategy.CALL_RETURN_REG),
				           reg("a", RegisterAllocationStrategy.NON_VOLATILE_REGISTER0),
				           Location.DUMMY),
				new IRCopy(reg("y", RegisterAllocationStrategy.NON_VOLATILE_REGISTER0),
				           reg("y", RegisterAllocationStrategy.CALL_ARG_0),
				           Location.DUMMY),
				new IRCopy(reg("x", RegisterAllocationStrategy.NON_VOLATILE_REGISTER1),
				           reg("x", RegisterAllocationStrategy.CALL_ARG_1),
				           Location.DUMMY)
		), instructions);
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