package com.regnis.tinyc.cfg;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;
import java.util.function.*;

import org.jetbrains.annotations.*;
import org.junit.*;

import static com.regnis.tinyc.cfg.RegisterAllocationStrategy.*;
import static org.junit.Assert.assertEquals;

/**
 * @author Thomas Singer
 */
public class RegisterAllocationStrategyTest {

	@Test
	public void testFreeRegister() {
		final var strategy = new RegisterAllocationStrategy(2, 0, 2);
		final int nonVolatile0 = strategy.nonVolatile(0);
		final int nonVolatile1 = strategy.nonVolatile(1);

		final List<IRInstruction> instructions = new ArrayList<>();
		final Consumer<IRInstruction> consumer = instructions::addFirst;
		final Predicate<Integer> registerPredicate = register -> register >= nonVolatile0;
		// ------------------------------------------------------------------------------
		// register is already free
		// -> nothing to do
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(var("a", 0), List.of(CALL_ARG_0))
		)));
		strategy.freeRegister(CALL_RETURN_REG, var("b", 1), registerPredicate, consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(var("a", 0), List.of(CALL_ARG_0))
		                                    ), strategy,
		                                    List.of(), instructions);
		// ------------------------------------------------------------------------------
		// register is already free
		// -> nothing to do
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(var("a", 0), List.of(CALL_ARG_0))
		)));
		strategy.freeRegister(CALL_RETURN_REG, var("a", 0), registerPredicate, consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(var("a", 0), List.of(CALL_ARG_0))
		                                    ), strategy,
		                                    List.of(), instructions);
		// ------------------------------------------------------------------------------
		// allowed variable is already stored in this register
		// -> nothing to do
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(var("a", 0), List.of(CALL_RETURN_REG))
		)));
		strategy.freeRegister(CALL_RETURN_REG, var("a", 0), registerPredicate, consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(var("a", 0), List.of(CALL_RETURN_REG))
		                                    ), strategy,
		                                    List.of(), instructions);
		// ------------------------------------------------------------------------------
		// allowed variable is already stored in this register (and in another)
		// -> nothing to do
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(var("a", 0), List.of(CALL_RETURN_REG, nonVolatile0))
		)));
		strategy.freeRegister(CALL_RETURN_REG, var("a", 0), registerPredicate, consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(var("a", 0), List.of(CALL_RETURN_REG, nonVolatile0))
		                                    ), strategy,
		                                    List.of(), instructions);
		// ------------------------------------------------------------------------------
		// register is used by a different variable
		// -> move it away
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(var("a", 0), List.of(CALL_RETURN_REG))
		)));
		strategy.freeRegister(CALL_RETURN_REG, var("b", 1), registerPredicate, consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(var("a", 0), List.of(nonVolatile0))
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromReg("a", CALL_RETURN_REG, nonVolatile0)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		// register is used by a different variable, multiple registers
		// -> reuse a location
		instructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(var("a", 0), List.of(CALL_RETURN_REG, nonVolatile1))
		)));
		strategy.freeRegister(CALL_RETURN_REG, var("b", 1), registerPredicate, consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(var("a", 0), List.of(nonVolatile1))
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromReg("a", CALL_RETURN_REG, nonVolatile1)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		// register is used by a different variable, no free register
		// -> load from memory
		instructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(var("a", 0), List.of(CALL_RETURN_REG)),
				new LiveVarRegisterState(var("b", 1), List.of(nonVolatile0)),
				new LiveVarRegisterState(var("c", 2), List.of(nonVolatile1))
		)));
		strategy.freeRegister(CALL_RETURN_REG, var("d", 3), registerPredicate, consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(var("b", 1), List.of(nonVolatile0)),
				                                    new LiveVarRegisterState(var("c", 2), List.of(nonVolatile1)),
				                                    new LiveVarRegisterState(var("a", 0), List.of())
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromVar(CALL_RETURN_REG, var("a", 0))
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		// register is used by a different variable, no free register, multiple registers
		// -> load from memory, reuse register
		instructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(var("a", 0), List.of(CALL_RETURN_REG, CALL_ARG_0)),
				new LiveVarRegisterState(var("b", 1), List.of(nonVolatile0)),
				new LiveVarRegisterState(var("c", 2), List.of(nonVolatile1))
		)));
		strategy.freeRegister(CALL_RETURN_REG, var("d", 3), registerPredicate, consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(var("b", 1), List.of(nonVolatile0)),
				                                    new LiveVarRegisterState(var("c", 2), List.of(nonVolatile1)),
				                                    new LiveVarRegisterState(var("a", 0), List.of())
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromVar(CALL_RETURN_REG, var("a", 0)),
				                                    movRegFromReg("a", CALL_ARG_0, CALL_RETURN_REG)
		                                    ), instructions);
	}

	@Test
	public void testCallArg() {
		final var strategy = new RegisterAllocationStrategy(2, 0, 2);
		final int nonVolatile0 = strategy.nonVolatile(0);

		final List<IRInstruction> instructions = new ArrayList<>();
		final Consumer<IRInstruction> consumer = instructions::addFirst;
		// ------------------------------------------------------------------------------
		// call-target is already in correct register
		// -> just remove var from live vars
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(var("a", 0), List.of(CALL_RETURN_REG))
		)));
		IRVar target = strategy.callTarget(var("a", 0), consumer);
		assertEquals(reg("a", CALL_RETURN_REG), target);
		assertEqualsVarStateAndInstructions(List.of(), strategy,
		                                    List.of(), instructions);
		// ------------------------------------------------------------------------------
		// call-target is expected in other register
		// -> move it
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(var("a", 0), List.of(CALL_ARG_0))
		)));
		target = strategy.callTarget(var("a", 0), consumer);
		assertEquals(reg("a", CALL_RETURN_REG), target);
		assertEqualsVarStateAndInstructions(List.of(), strategy,
		                                    List.of(
				                                    movRegFromReg("a", CALL_ARG_0, CALL_RETURN_REG)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		// return register is occupied by other variable
		// -> move it
		instructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(var("a", 0), List.of(CALL_ARG_0)),
				new LiveVarRegisterState(var("b", 1), List.of(CALL_RETURN_REG))
		)));
		target = strategy.callTarget(var("a", 0), consumer);
		assertEquals(reg("a", CALL_RETURN_REG), target);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(var("b", 1), List.of(nonVolatile0))
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromReg("a", CALL_ARG_0, CALL_RETURN_REG),
				                                    movRegFromReg("b", CALL_RETURN_REG, nonVolatile0)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		// return register is free, but var needs to be written to memory
		instructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(var("a", 0), List.of())
		)));
		target = strategy.callTarget(var("a", 0), consumer);
		assertEquals(reg("a", CALL_RETURN_REG), target);
		assertEqualsVarStateAndInstructions(List.of(), strategy,
		                                    List.of(
				                                    movVarFromReg(var("a", 0), CALL_RETURN_REG)
		                                    ), instructions);
	}

	@Test
	public void testTarget() {
		final var strategy = new RegisterAllocationStrategy(2, 0, 2);
		final int nonVolatile0 = strategy.nonVolatile(0);
		final int nonVolatile1 = strategy.nonVolatile(1);

		final List<IRInstruction> instructions = new ArrayList<>();
		final Consumer<IRInstruction> consumer = instructions::addFirst;
		// ------------------------------------------------------------------------------
		// single var already in register
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(var("a", 0), List.of(CALL_ARG_0))
		)));
		IRVar target = strategy.target(var("a", 0), consumer);
		assertEquals(reg("a", CALL_ARG_0), target);
		assertEqualsVarStateAndInstructions(List.of(), strategy,
		                                    List.of(), instructions);
		// ------------------------------------------------------------------------------
		// single var in two volatile registers
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(var("a", 0), List.of(CALL_ARG_0, CALL_ARG_1))
		)));
		target = strategy.target(var("a", 0), consumer);
		assertEquals(reg("a", CALL_ARG_0), target);
		assertEqualsVarStateAndInstructions(List.of(), strategy,
		                                    List.of(
				                                    movRegFromReg("a", CALL_ARG_1, CALL_ARG_0)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		instructions.clear();
		// single var in two registers, one volatile, one non-volatile
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(var("a", 0), List.of(nonVolatile0, CALL_ARG_1))
		)));
		target = strategy.target(var("a", 0), consumer);
		assertEquals(reg("a", CALL_ARG_1), target);
		assertEqualsVarStateAndInstructions(List.of(), strategy,
		                                    List.of(
				                                    movRegFromReg("a", nonVolatile0, CALL_ARG_1)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		instructions.clear();
		// multiple vars in non-volatile registers
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(var("a", 0), List.of(nonVolatile0)),
				new LiveVarRegisterState(var("b", 1), List.of(nonVolatile1))
		)));
		target = strategy.target(var("b", 1), consumer);
		assertEquals(reg("b", nonVolatile1), target);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(var("a", 0), List.of(nonVolatile0))
		                                    ), strategy,
		                                    List.of(), instructions);
		// todo no free register
	}

	@Test
	public void testCall() {
		final var strategy = new RegisterAllocationStrategy(2, 0, 2);
		final int nonVolatile0 = strategy.nonVolatile(0);
		final int nonVolatile1 = strategy.nonVolatile(1);

		final List<IRInstruction> instructions = new ArrayList<>();
		final Consumer<IRInstruction> consumer = instructions::addFirst;

		// ==============================================================================
		//    a = foo(x, y)
		//    b = bar(y, x)
		//    bazz(a, b)
		// ->
		strategy.freeVolatileRegisters(consumer);
		assertEqualsVarStateAndInstructions(List.of(), strategy,
		                                    List.of(), instructions);
		// ------------------------------------------------------------------------------
		strategy.prepareCallArgs(List.of(
				var("a", 2),
				var("b", 3)
		), consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(var("a", 2), List.of(CALL_ARG_0)),
				                                    new LiveVarRegisterState(var("b", 3), List.of(CALL_ARG_1))
		                                    ), strategy,
		                                    List.of(), instructions);

		// ==============================================================================
		//    a = foo(x, y)
		//    b = bar(y, x)
		// ->
		//    bazz(a, b)
		IRVar target = strategy.callTarget(var("b", 3), consumer);
		assertEquals(reg("b", CALL_RETURN_REG), target);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(var("a", 2), List.of(CALL_ARG_0))
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromReg("b", CALL_ARG_1, CALL_RETURN_REG)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		strategy.freeVolatileRegisters(consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(var("a", 2), List.of(nonVolatile0))
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromReg("a", CALL_ARG_0, nonVolatile0),
				                                    movRegFromReg("b", CALL_ARG_1, CALL_RETURN_REG)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		strategy.prepareCallArgs(List.of(
				var("y", 1),
				var("x", 0)
		), consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(var("a", 2), List.of(nonVolatile0)),
				                                    new LiveVarRegisterState(var("y", 1), List.of(CALL_ARG_0)),
				                                    new LiveVarRegisterState(var("x", 0), List.of(CALL_ARG_1))
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromReg("a", CALL_ARG_0, nonVolatile0),
				                                    movRegFromReg("b", CALL_ARG_1, CALL_RETURN_REG)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		instructions.clear();
		// ==============================================================================
		//    a = foo(x, y)
		// ->
		//    b = bar(y, x)
		//    bazz(a, b)
		target = strategy.callTarget(var("a", 2), consumer);
		assertEquals(reg("a", CALL_RETURN_REG), target);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(var("y", 1), List.of(CALL_ARG_0)),
				                                    new LiveVarRegisterState(var("x", 0), List.of(CALL_ARG_1))
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromReg("a", nonVolatile0, CALL_RETURN_REG)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		strategy.freeVolatileRegisters(consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(var("y", 1), List.of(nonVolatile0)),
				                                    new LiveVarRegisterState(var("x", 0), List.of(nonVolatile1))
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromReg("x", CALL_ARG_1, nonVolatile1),
				                                    movRegFromReg("y", CALL_ARG_0, nonVolatile0),
				                                    movRegFromReg("a", nonVolatile0, CALL_RETURN_REG)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		strategy.prepareCallArgs(List.of(
				var("x", 0),
				var("y", 1)
		), consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(var("x", 0), List.of(CALL_ARG_0, nonVolatile1)),
				                                    new LiveVarRegisterState(var("y", 1), List.of(CALL_ARG_1, nonVolatile0))
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromReg("x", CALL_ARG_1, nonVolatile1),
				                                    movRegFromReg("y", CALL_ARG_0, nonVolatile0),
				                                    movRegFromReg("a", nonVolatile0, CALL_RETURN_REG)
		                                    ), instructions);
	}

	private static void assertEqualsVarStateAndInstructions(List<LiveVarRegisterState> expectedVarStates, RegisterAllocationStrategy strategy, List<IRInstruction> expectedInstructions, List<IRInstruction> instructions) {
		assertEquals(new AllLiveVarRegisterState(expectedVarStates), strategy.getState());
		assertEquals(expectedInstructions, instructions);
	}

	@NotNull
	private static IRCopy movRegFromReg(String name, int to, int from) {
		return movVarFromReg(reg(name, to), from);
	}

	@NotNull
	private static IRCopy movVarFromReg(IRVar to, int from) {
		return new IRCopy(to,
		                  reg(to.name(), from),
		                  Location.DUMMY);
	}

	@NotNull
	private static IRCopy movRegFromVar(int to, IRVar from) {
		return new IRCopy(reg(from.name(), to),
		                  from,
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