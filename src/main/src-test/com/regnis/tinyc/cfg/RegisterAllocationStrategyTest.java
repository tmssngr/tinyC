package com.regnis.tinyc.cfg;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;
import java.util.function.*;

import org.jetbrains.annotations.*;
import org.junit.*;

import static com.regnis.tinyc.cfg.RegisterAllocationStrategy.*;
import static org.junit.Assert.*;

/**
 * @author Thomas Singer
 */
public class RegisterAllocationStrategyTest {

	static void assertEqualsVarStateAndInstructions(List<LiveVarRegisterState> expectedVarStates, RegisterAllocationStrategy strategy, List<IRInstruction> expectedInstructions, List<IRInstruction> instructions) {
		assertEquals(new AllLiveVarRegisterState(expectedVarStates), strategy.getState());
		assertEquals(expectedInstructions, instructions);
	}

	@NotNull
	static IRCopy movRegFromReg(String name, int to, int from) {
		return movVarFromReg(reg(name, to), from);
	}

	@NotNull
	static IRCopy movRegFromReg(IRVar var, int to, int from) {
		return new IRCopy(reg(to, var),
		                  reg(from, var),
		                  Location.DUMMY);
	}

	@NotNull
	static IRCopy movVarFromReg(IRVar to, int from) {
		return new IRCopy(to,
		                  reg(to.name(), from),
		                  Location.DUMMY);
	}

	@NotNull
	static IRCopy movRegFromVar(int to, IRVar from) {
		return new IRCopy(new IRVar(from.name(), to, VariableScope.register, from.type(), from.canBeRegister()),
		                  from,
		                  Location.DUMMY);
	}

	@NotNull
	static IRVar var(String name, int index) {
		return new IRVar(name, index, VariableScope.function, Type.I16, true);
	}

	@NotNull
	static IRVar reg(String name, int index) {
		return new IRVar(name, index, VariableScope.register, Type.I16, true);
	}

	@NotNull
	static IRVar reg(int index, @NotNull IRVar var) {
		return IRVar.createRegisterVar(index, var);
	}

	@Test
	public void testFreeRegister() {
		final IRVar a = var("a", 0);
		final IRVar b = var("b", 1);
		final IRVar c = var("c", 2);
		final IRVar d = var("d", 3);
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
				new LiveVarRegisterState(a, List.of(CALL_ARG_1))
		)));
		strategy.freeRegister(CALL_RETURN_REG, registerPredicate, consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(a, List.of(CALL_ARG_1))
		                                    ), strategy,
		                                    List.of(), instructions);
		// ------------------------------------------------------------------------------
		// register already used (var in single register)
		// -> needs to be freed
		instructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(CALL_ARG_1)),
				new LiveVarRegisterState(b, List.of(CALL_ARG_2)),
				new LiveVarRegisterState(c, List.of(nonVolatile0))
		)));
		strategy.freeRegister(CALL_ARG_2, registerPredicate, consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(a, List.of(CALL_ARG_1)),
				                                    new LiveVarRegisterState(c, List.of(nonVolatile0)),
				                                    new LiveVarRegisterState(b, List.of(nonVolatile1))
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromReg(b, CALL_ARG_2, nonVolatile1)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		// register already used (var in multiple registers)
		// -> needs to be freed
		instructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(CALL_ARG_1)),
				new LiveVarRegisterState(b, List.of(CALL_ARG_2, nonVolatile0))
		)));
		strategy.freeRegister(CALL_ARG_2, registerPredicate, consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(a, List.of(CALL_ARG_1)),
				                                    new LiveVarRegisterState(b, List.of(nonVolatile0))
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromReg(b, CALL_ARG_2, nonVolatile0)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		// register already used (var in single register), nothing free
		// -> needs to be freed
		instructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(CALL_ARG_1)),
				new LiveVarRegisterState(b, List.of(CALL_ARG_2)),
				new LiveVarRegisterState(c, List.of(nonVolatile0)),
				new LiveVarRegisterState(d, List.of(nonVolatile1))
		)));
		strategy.freeRegister(CALL_ARG_2, registerPredicate, consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(a, List.of(CALL_ARG_1)),
				                                    new LiveVarRegisterState(c, List.of(nonVolatile0)),
				                                    new LiveVarRegisterState(d, List.of(nonVolatile1)),
				                                    new LiveVarRegisterState(b, List.of())
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromVar(CALL_ARG_2, b)
		                                    ), instructions);
	}

	@Test
	public void testFreeAllRegister() {
		final var strategy = new RegisterAllocationStrategy(2, 0, 2);

		final List<IRInstruction> instructions = new ArrayList<>();
		final Consumer<IRInstruction> consumer = instructions::addFirst;
		// ------------------------------------------------------------------------------
		// nothing live, nothing to free
		strategy.freeAllRegisters(consumer);
		assertEquals(new AllLiveVarRegisterState(List.of()), strategy.getState());
		assertEquals(List.of(), instructions);
		// ------------------------------------------------------------------------------
		// var without register, nothing to free
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(var("a", 0), List.of())
		)));
		strategy.freeAllRegisters(consumer);
		assertEquals(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(var("a", 0), List.of())
		)), strategy.getState());
		assertEquals(List.of(), instructions);
		// ------------------------------------------------------------------------------
		// vars in single register
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(var("a", 0), List.of(CALL_ARG_1)),
				new LiveVarRegisterState(var("b", 1), List.of(CALL_ARG_2))
		)));
		strategy.freeAllRegisters(consumer);
		assertEquals(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(var("a", 0), List.of()),
				new LiveVarRegisterState(var("b", 1), List.of())
		)), strategy.getState());
		assertEquals(List.of(
				movRegFromVar(CALL_ARG_2, var("b", 1)),
				movRegFromVar(CALL_ARG_1, var("a", 0))
		), instructions);
		// ------------------------------------------------------------------------------
		// vars in multiple registers
		instructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(var("a", 0), List.of(CALL_ARG_1, CALL_ARG_2))
		)));
		strategy.freeAllRegisters(consumer);
		assertEquals(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(var("a", 0), List.of())
		)), strategy.getState());
		assertEquals(List.of(
				movRegFromVar(CALL_ARG_1, var("a", 0)),
				movRegFromReg("a", CALL_ARG_2, CALL_ARG_1)
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
				new LiveVarRegisterState(var("a", 0), List.of(CALL_ARG_1))
		)));
		target = strategy.callTarget(var("a", 0), consumer);
		assertEquals(reg("a", CALL_RETURN_REG), target);
		assertEqualsVarStateAndInstructions(List.of(), strategy,
		                                    List.of(
				                                    movRegFromReg("a", CALL_ARG_1, CALL_RETURN_REG)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		// return register is occupied by other variable
		// -> move it
		instructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(var("a", 0), List.of(CALL_ARG_1)),
				new LiveVarRegisterState(var("b", 1), List.of(CALL_RETURN_REG))
		)));
		target = strategy.callTarget(var("a", 0), consumer);
		assertEquals(reg("a", CALL_RETURN_REG), target);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(var("b", 1), List.of(nonVolatile0))
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromReg("a", CALL_ARG_1, CALL_RETURN_REG),
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
		// not live
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(var("a", 0), List.of(CALL_ARG_1))
		)));
		assertFalse(strategy.isLiveAfter(var("b", 1)));
		try {
			strategy.target(var("b", 1), consumer);
			fail();
		}
		catch (IllegalStateException ignored) {
		}
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(var("a", 0), List.of(CALL_ARG_1))
		                                    ), strategy,
		                                    List.of(), instructions);
		// ------------------------------------------------------------------------------
		// single var already in register
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(var("a", 0), List.of(CALL_ARG_1))
		)));
		IRVar target = strategy.target(var("a", 0), consumer);
		assertEquals(reg("a", CALL_ARG_1), target);
		assertEqualsVarStateAndInstructions(List.of(), strategy,
		                                    List.of(), instructions);
		// ------------------------------------------------------------------------------
		// single var in two volatile registers
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(var("a", 0), List.of(CALL_ARG_1, CALL_ARG_2))
		)));
		target = strategy.target(var("a", 0), consumer);
		assertEquals(reg("a", CALL_ARG_1), target);
		assertEqualsVarStateAndInstructions(List.of(), strategy,
		                                    List.of(
				                                    movRegFromReg("a", CALL_ARG_2, CALL_ARG_1)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		instructions.clear();
		// single var in two registers, one volatile, one non-volatile
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(var("a", 0), List.of(nonVolatile0, CALL_ARG_2))
		)));
		target = strategy.target(var("a", 0), consumer);
		assertEquals(reg("a", CALL_ARG_2), target);
		assertEqualsVarStateAndInstructions(List.of(), strategy,
		                                    List.of(
				                                    movRegFromReg("a", nonVolatile0, CALL_ARG_2)
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
	public void testSource() {
		final IRVar a = var("a", 0);
		final IRVar b = var("b", 1);
		final IRVar c = var("c", 2);
		final IRVar d = var("d", 3);
		final IRVar e = var("e", 4);
		final var strategy = new RegisterAllocationStrategy(2, 0, 2);
		final int nv0 = strategy.nonVolatile(0);
		final int nv1 = strategy.nonVolatile(1);

		final List<IRInstruction> preInstructions = new ArrayList<>();
		final List<IRInstruction> postInstructions = new ArrayList<>();
		final Consumer<IRInstruction> preConsumer = preInstructions::addFirst;
		final Consumer<IRInstruction> postConsumer = postInstructions::addFirst;
		// ------------------------------------------------------------------------------
		// nothing live
		// -> return first reg
		strategy.setState(new AllLiveVarRegisterState(List.of()));
		IRVar source = strategy.source(a, preConsumer, postConsumer);
		assertEquals(reg(CALL_ARG_1, a), source);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(a, List.of(CALL_ARG_1))
		                                    ), strategy,
		                                    List.of(), preInstructions,
		                                    List.of(), postInstructions);
		// ------------------------------------------------------------------------------
		// one live in register, ask for this
		// -> return next free reg
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(b, List.of(CALL_ARG_2))
		)));
		source = strategy.source(b, preConsumer, postConsumer);
		assertEquals(reg(CALL_ARG_2, b), source);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(b, List.of(CALL_ARG_2))
		                                    ), strategy,
		                                    List.of(), preInstructions,
		                                    List.of(), postInstructions);
		// ------------------------------------------------------------------------------
		// one live (but not in register), ask for this
		// -> return next free reg, move to memory
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of())
		)));
		source = strategy.source(a, preConsumer, postConsumer);
		assertEquals(reg(CALL_ARG_1, a), source);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(a, List.of(CALL_ARG_1))
		                                    ), strategy,
		                                    List.of(
				                                    // todo maybe only if changed before
				                                    movVarFromReg(a, CALL_ARG_1)
		                                    ), preInstructions,
		                                    List.of(), postInstructions);
		// ------------------------------------------------------------------------------
		// one live in register, ask for another
		// -> return next free reg
		preInstructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(CALL_ARG_1))
		)));
		source = strategy.source(b, preConsumer, postConsumer);
		assertEquals(reg(CALL_ARG_2, b), source);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(a, List.of(CALL_ARG_1)),
				                                    new LiveVarRegisterState(b, List.of(CALL_ARG_2))
		                                    ), strategy,
		                                    List.of(), preInstructions,
		                                    List.of(), postInstructions);
		// ------------------------------------------------------------------------------
		// two live, ask for one
		// -> return the register
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(CALL_ARG_1)),
				new LiveVarRegisterState(b, List.of(CALL_ARG_2))
		)));
		source = strategy.source(b, preConsumer, postConsumer);
		assertEquals(reg(CALL_ARG_2, b), source);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(a, List.of(CALL_ARG_1)),
				                                    new LiveVarRegisterState(b, List.of(CALL_ARG_2))
		                                    ), strategy,
		                                    List.of(), preInstructions,
		                                    List.of(), postInstructions);
		// ------------------------------------------------------------------------------
		// multiple live, ask for one which is stored in multiple registers
		// -> return any of the multiple registers
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(nv0, CALL_ARG_1))
		)));
		source = strategy.source(a, preConsumer, postConsumer);
		assertEquals(reg(nv0, a), source);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(a, List.of(nv0, CALL_ARG_1))
		                                    ), strategy,
		                                    List.of(), preInstructions,
		                                    List.of(), postInstructions);
		// ------------------------------------------------------------------------------
		// multiple live (nothing free), some in multiple registers, ask for another
		// -> free one of the multiple registers
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(nv0, CALL_ARG_1)),
				new LiveVarRegisterState(b, List.of(CALL_ARG_2)),
				new LiveVarRegisterState(c, List.of(nv1))
		)));
		source = strategy.source(d, preConsumer, postConsumer);
		assertEquals(reg(nv0, d), source);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(b, List.of(CALL_ARG_2)),
				                                    new LiveVarRegisterState(c, List.of(nv1)),
				                                    new LiveVarRegisterState(a, List.of(CALL_ARG_1)),
				                                    new LiveVarRegisterState(d, List.of(nv0))
		                                    ), strategy,
		                                    List.of(), preInstructions,
		                                    List.of(
				                                    movRegFromReg(a, nv0, CALL_ARG_1)
		                                    ), postInstructions);
	}

	@Test
	public void testSource2() {
		final IRVar a = var("a", 0);
		final IRVar b = var("b", 1);
		final IRVar c = var("c", 2);
		final IRVar d = var("d", 3);
		final IRVar e = var("e", 4);
		final var strategy = new RegisterAllocationStrategy(2, 0, 2);
		final int nv0 = strategy.nonVolatile(0);
		final int nv1 = strategy.nonVolatile(1);

		final List<IRInstruction> preInstructions = new ArrayList<>();
		final List<IRInstruction> postInstructions = new ArrayList<>();
		final Consumer<IRInstruction> preConsumer = preInstructions::addFirst;
		final Consumer<IRInstruction> postConsumer = postInstructions::addFirst;
		final Predicate<Integer> canUseAnyRegisterPredicate = r -> true;
		// ------------------------------------------------------------------------------
		// nothing live
		// -> return first reg
		strategy.setState(new AllLiveVarRegisterState(List.of()));
		IRVar source = strategy.source(a, canUseAnyRegisterPredicate, preConsumer, postConsumer);
		assertEquals(reg(CALL_ARG_1, a), source);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(a, List.of(CALL_ARG_1))
		                                    ), strategy,
		                                    List.of(), preInstructions,
		                                    List.of(), postInstructions);
		// ------------------------------------------------------------------------------
		// one live in register, ask for this
		// -> return next free reg
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(b, List.of(CALL_ARG_2))
		)));
		source = strategy.source(b, canUseAnyRegisterPredicate, preConsumer, postConsumer);
		assertEquals(reg(CALL_ARG_2, b), source);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(b, List.of(CALL_ARG_2))
		                                    ), strategy,
		                                    List.of(), preInstructions,
		                                    List.of(), postInstructions);
		// ------------------------------------------------------------------------------
		// one live (but not in register), ask for this
		// -> return next free reg, move to memory
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of())
		)));
		source = strategy.source(a, canUseAnyRegisterPredicate, preConsumer, postConsumer);
		assertEquals(reg(CALL_ARG_1, a), source);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(a, List.of(CALL_ARG_1))
		                                    ), strategy,
		                                    List.of(
				                                    // todo maybe only if changed before
				                                    movVarFromReg(a, CALL_ARG_1)
		                                    ), preInstructions,
		                                    List.of(), postInstructions);
		// ------------------------------------------------------------------------------
		// one live in register, ask for another
		// -> return next free reg
		preInstructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(CALL_ARG_1))
		)));
		source = strategy.source(b, canUseAnyRegisterPredicate, preConsumer, postConsumer);
		assertEquals(reg(CALL_ARG_2, b), source);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(a, List.of(CALL_ARG_1)),
				                                    new LiveVarRegisterState(b, List.of(CALL_ARG_2))
		                                    ), strategy,
		                                    List.of(), preInstructions,
		                                    List.of(), postInstructions);
		// ------------------------------------------------------------------------------
		// two live, ask for one
		// -> return the register
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(CALL_ARG_1)),
				new LiveVarRegisterState(b, List.of(CALL_ARG_2))
		)));
		source = strategy.source(b, canUseAnyRegisterPredicate, preConsumer, postConsumer);
		assertEquals(reg(CALL_ARG_2, b), source);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(a, List.of(CALL_ARG_1)),
				                                    new LiveVarRegisterState(b, List.of(CALL_ARG_2))
		                                    ), strategy,
		                                    List.of(), preInstructions,
		                                    List.of(), postInstructions);
		// ------------------------------------------------------------------------------
		// multiple live, ask for one which is stored in multiple registers
		// -> return any of the multiple registers
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(nv0, CALL_ARG_1))
		)));
		source = strategy.source(a, canUseAnyRegisterPredicate, preConsumer, postConsumer);
		assertEquals(reg(nv0, a), source);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(a, List.of(nv0, CALL_ARG_1))
		                                    ), strategy,
		                                    List.of(), preInstructions,
		                                    List.of(), postInstructions);
		// ------------------------------------------------------------------------------
		// multiple live (nothing free), some in multiple registers, ask for another
		// -> free one of the multiple registers
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(nv0, CALL_ARG_1)),
				new LiveVarRegisterState(b, List.of(CALL_ARG_2)),
				new LiveVarRegisterState(c, List.of(nv1))
		)));
		source = strategy.source(d, canUseAnyRegisterPredicate, preConsumer, postConsumer);
		assertEquals(reg(nv0, d), source);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(b, List.of(CALL_ARG_2)),
				                                    new LiveVarRegisterState(c, List.of(nv1)),
				                                    new LiveVarRegisterState(a, List.of(CALL_ARG_1)),
				                                    new LiveVarRegisterState(d, List.of(nv0))
		                                    ), strategy,
		                                    List.of(), preInstructions,
		                                    List.of(
				                                    movRegFromReg(a, nv0, CALL_ARG_1)
		                                    ), postInstructions);
		// ------------------------------------------------------------------------------
		// multiple live (nothing free), some in multiple registers, ask for another
		// -> free one of the multiple registers, except of the specified one
		postInstructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(nv0, CALL_ARG_1)),
				new LiveVarRegisterState(b, List.of(CALL_ARG_2)),
				new LiveVarRegisterState(c, List.of(nv1))
		)));
		source = strategy.source(d, r -> r != nv0, preConsumer, postConsumer);
		assertEquals(reg(CALL_ARG_1, d), source);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(b, List.of(CALL_ARG_2)),
				                                    new LiveVarRegisterState(c, List.of(nv1)),
				                                    new LiveVarRegisterState(a, List.of(nv0)),
				                                    new LiveVarRegisterState(d, List.of(CALL_ARG_1))
		                                    ), strategy,
		                                    List.of(), preInstructions,
		                                    List.of(
				                                    movRegFromReg(a, CALL_ARG_1, nv0)
		                                    ), postInstructions);
	}

	@Test
	public void testSourceForModificationInReg() {
		final IRVar a = var("a", 0);
		final var strategy = new RegisterAllocationStrategy(2, 0, 2);

		// ------------------------------------------------------------------------------
		// nothing live (= last use)
		// -> it becomes live in the specified register
		strategy.setState(new AllLiveVarRegisterState(List.of()));
		IRVar var = strategy.sourceForModificationInReg(a, CALL_RETURN_REG);
		assertEquals(reg(CALL_RETURN_REG, a), var);
		assertEquals(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(CALL_RETURN_REG))
		)), strategy.getState());
		// ------------------------------------------------------------------------------
		// live in one register, expect it in another register
		// -> expect it live in both registers
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(CALL_ARG_2))
		)));
		var = strategy.sourceForModificationInReg(a, CALL_ARG_1);
		assertEquals(reg(CALL_ARG_1, a), var);
		assertEquals(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(CALL_ARG_2, CALL_ARG_1))
		)), strategy.getState());
		// ------------------------------------------------------------------------------
		// live in two registers -> create copy, previous live remains
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(CALL_ARG_2, CALL_ARG_1))
		)));
		var = strategy.sourceForModificationInReg(a, CALL_RETURN_REG);
		assertEquals(reg(CALL_RETURN_REG, a), var);
		assertEquals(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(CALL_ARG_2, CALL_ARG_1, CALL_RETURN_REG))
		)), strategy.getState());
		// ------------------------------------------------------------------------------
		// live in one register, expect it in this register
		// -> then the register was not free
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(CALL_ARG_2))
		)));
		try {
			strategy.sourceForModificationInReg(a, CALL_ARG_2);
			fail();
		}
		catch (IllegalStateException ignored) {
		}
		assertEquals(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(CALL_ARG_2))
		)), strategy.getState());
	}

	@Test
	public void testFreeVolatile() {
		final IRVar a = var("a", 0);
		final IRVar b = var("b", 1);
		final IRVar c = var("c", 2);
		final var strategy = new RegisterAllocationStrategy(2, 0, 2);
		final int nv0 = strategy.nonVolatile(0);
		final int nv1 = strategy.nonVolatile(1);

		final List<IRInstruction> instructions = new ArrayList<>();
		final Consumer<IRInstruction> consumer = instructions::addFirst;
		// ------------------------------------------------------------------------------
		// nothing live
		// -> nothing to do
		strategy.freeVolatileRegisters(consumer);
		assertEqualsVarStateAndInstructions(List.of(), strategy,
		                                    List.of(), instructions);
		// ------------------------------------------------------------------------------
		// something live, but not in registers
		// -> nothing to do
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of())
		)));
		strategy.freeVolatileRegisters(consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(a, List.of())
		                                    ), strategy,
		                                    List.of(), instructions);
		// ------------------------------------------------------------------------------
		// something live in non-volatile registers
		// -> nothing to do
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(nv0))
		)));
		strategy.freeVolatileRegisters(consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(a, List.of(nv0))
		                                    ), strategy,
		                                    List.of(), instructions);
		// ------------------------------------------------------------------------------
		// something live in volatile and non-volatile registers
		// -> move
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(CALL_ARG_1, nv0))
		)));
		strategy.freeVolatileRegisters(consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(a, List.of(nv0))
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromReg(a, CALL_ARG_1, nv0)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		// something live in volatile register (free non-volatile registers available)
		// -> move
		instructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(CALL_ARG_1))
		)));
		strategy.freeVolatileRegisters(consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(a, List.of(nv0))
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromReg(a, CALL_ARG_1, nv0)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		// something live in volatile register (no free non-volatile registers available)
		// -> move from var
		instructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(CALL_ARG_2)),
				new LiveVarRegisterState(b, List.of(nv0)),
				new LiveVarRegisterState(c, List.of(nv1))
		)));
		strategy.freeVolatileRegisters(consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(a, List.of()),
				                                    new LiveVarRegisterState(b, List.of(nv0)),
				                                    new LiveVarRegisterState(c, List.of(nv1))
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromVar(CALL_ARG_2, a)
		                                    ), instructions);
	}

	@Test
	public void testFreeAnyVarRegister() {
		final IRVar a = var("a", 0);
		final IRVar b = var("b", 1);
		final IRVar c = var("c", 2);
		final var strategy = new RegisterAllocationStrategy(2, 0, 2);
		final int nv0 = strategy.nonVolatile(0);
		final int nv1 = strategy.nonVolatile(1);

		final List<IRInstruction> instructions = new ArrayList<>();
		final Consumer<IRInstruction> consumer = instructions::addFirst;
		final Predicate<Integer> canUseAllRegistersPredicate = r -> true;
		// ------------------------------------------------------------------------------
		// pick one with multiple registers
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(CALL_ARG_1)),
				new LiveVarRegisterState(b, List.of(CALL_ARG_2)),
				new LiveVarRegisterState(c, List.of(nv0, nv1))
		)));
		int register = strategy.freeAnyVarRegister(canUseAllRegistersPredicate, consumer);
		assertEquals(nv0, register);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(a, List.of(CALL_ARG_1)),
				                                    new LiveVarRegisterState(b, List.of(CALL_ARG_2)),
				                                    new LiveVarRegisterState(c, List.of(nv1))
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromReg(c, nv0, nv1)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		// pick one with single register
		instructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(CALL_ARG_1)),
				new LiveVarRegisterState(b, List.of(CALL_ARG_2)),
				new LiveVarRegisterState(c, List.of(nv1))
		)));
		register = strategy.freeAnyVarRegister(canUseAllRegistersPredicate, consumer);
		assertEquals(CALL_ARG_1, register);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(b, List.of(CALL_ARG_2)),
				                                    new LiveVarRegisterState(c, List.of(nv1)),
				                                    new LiveVarRegisterState(a, List.of())
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromVar(CALL_ARG_1, a)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		// pick one with multiple registers (except of the specified one)
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(CALL_ARG_1)),
				new LiveVarRegisterState(b, List.of(CALL_ARG_2)),
				new LiveVarRegisterState(c, List.of(nv0, nv1))
		)));
		instructions.clear();
		register = strategy.freeAnyVarRegister(r -> r != nv0, consumer);
		assertEquals(nv1, register);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(a, List.of(CALL_ARG_1)),
				                                    new LiveVarRegisterState(b, List.of(CALL_ARG_2)),
				                                    // this must remain live ------------v
				                                    new LiveVarRegisterState(c, List.of(nv0))
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromReg(c, nv1, nv0)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		// pick one with single register (except of the specified one)
		instructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(CALL_ARG_1)),
				new LiveVarRegisterState(b, List.of(CALL_ARG_2)),
				new LiveVarRegisterState(c, List.of(nv1))
		)));
		register = strategy.freeAnyVarRegister(r -> r != CALL_ARG_1, consumer);
		assertEquals(CALL_ARG_2, register);
		assertEqualsVarStateAndInstructions(List.of(
				                                    // this must remain live ------------v
				                                    new LiveVarRegisterState(a, List.of(CALL_ARG_1)),
				                                    new LiveVarRegisterState(c, List.of(nv1)),
				                                    new LiveVarRegisterState(b, List.of())
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromVar(CALL_ARG_2, b)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		// pick a register except of the specified ones
		instructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(CALL_ARG_1)),
				new LiveVarRegisterState(c, List.of(nv1))
		)));
		register = strategy.freeAnyVarRegister(r -> r > CALL_ARG_2, consumer);
		assertEquals(nv1, register);
		assertEqualsVarStateAndInstructions(List.of(
				                                    // this must remain live ------------v
				                                    new LiveVarRegisterState(a, List.of(CALL_ARG_1)),
				                                    new LiveVarRegisterState(c, List.of())
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromVar(nv1, c)
		                                    ), instructions);
	}

	@Deprecated
	@Test
	public void testHandleFirstBlockBegin() {
		final IRVar a = var("a", 0);
		final IRVar b0 = arg("b", 0);
		final IRVar c1 = arg("c", 1);
		final IRVar d2 = arg("d", 2);
		final var strategy = new RegisterAllocationStrategy(2, 0, 2);
		final int nonVolatile0 = strategy.nonVolatile(0);
		final int nonVolatile1 = strategy.nonVolatile(1);

		final List<IRInstruction> instructions = new ArrayList<>();
		final Consumer<IRInstruction> consumer = instructions::addFirst;
		// ------------------------------------------------------------------------------
		// reverse order
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(a, List.of(CALL_RETURN_REG)),
				new LiveVarRegisterState(b0, List.of(CALL_ARG_2)),
				new LiveVarRegisterState(c1, List.of(CALL_ARG_1)),
				new LiveVarRegisterState(d2, List.of(nonVolatile0))
		)));
		strategy.handleFirstBlockBegin(consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(a, List.of()),
				                                    new LiveVarRegisterState(d2, List.of()),
				                                    new LiveVarRegisterState(c1, List.of(CALL_ARG_2)),
				                                    new LiveVarRegisterState(b0, List.of(CALL_ARG_1))
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromReg(b0, CALL_RETURN_REG, CALL_ARG_1),
				                                    movRegFromReg(c1, CALL_ARG_1, CALL_ARG_2),
				                                    movRegFromReg(b0, CALL_ARG_2, CALL_RETURN_REG),
				                                    movRegFromVar(nonVolatile0, d2),
				                                    movRegFromVar(CALL_RETURN_REG, a)
		                                    ), instructions);
	}

	@Test
	public void testTransferToState() {
		final IRVar varA = var("a", 0);
		final IRVar varB = var("b", 1);
		final IRVar arg0 = arg("arg0", 0);
		final IRVar arg1 = arg("arg1", 1);
		final IRVar arg2 = arg("arg2", 2);
		final var strategy = new RegisterAllocationStrategy(2, 0, 2);
		final int nonVolatile0 = strategy.nonVolatile(0);
		final int nonVolatile1 = strategy.nonVolatile(1);

		final List<IRInstruction> instructions = new ArrayList<>();
		final Consumer<IRInstruction> consumer = instructions::addFirst;
		// ------------------------------------------------------------------------------
		// missing to live
		strategy.setState(new AllLiveVarRegisterState(List.of()));
		strategy.transferTo(List.of(
				new LiveVarRegisterState(varA, List.of())
		), consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(varA, List.of())
		                                    ), strategy,
		                                    List.of(), instructions);
		// ------------------------------------------------------------------------------
		// live to missing
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(varA, List.of())
		)));
		strategy.transferTo(List.of(), consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(varA, List.of())
		                                    ), strategy,
		                                    List.of(), instructions);
		// ------------------------------------------------------------------------------
		// from regs to var
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(varA, List.of())
		)));
		strategy.transferTo(List.of(
				new LiveVarRegisterState(varA, List.of(CALL_RETURN_REG))
		), consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(varA, List.of(CALL_RETURN_REG))
		                                    ), strategy,
		                                    List.of(
													movVarFromReg(varA, CALL_RETURN_REG)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		// from var to regs
		instructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(varA, List.of(CALL_RETURN_REG, CALL_ARG_1))
		)));
		strategy.transferTo(List.of(
				new LiveVarRegisterState(varA, List.of())
		), consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(varA, List.of())
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromVar(CALL_RETURN_REG, varA),
				                                    movRegFromReg(varA, CALL_ARG_1, CALL_RETURN_REG)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		// equal regs
		instructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(varA, List.of(CALL_RETURN_REG))
		)));
		strategy.transferTo(List.of(
				new LiveVarRegisterState(varA, List.of(CALL_RETURN_REG))
		), consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(varA, List.of(CALL_RETURN_REG))
		                                    ), strategy,
		                                    List.of(), instructions);
		// ------------------------------------------------------------------------------
		// one equal register
		instructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(varA, List.of(CALL_RETURN_REG, CALL_ARG_2))
		)));
		strategy.transferTo(List.of(
				new LiveVarRegisterState(varA, List.of(CALL_ARG_2))
		), consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(varA, List.of(CALL_ARG_2))
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromReg(varA, CALL_RETURN_REG, CALL_ARG_2)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		// different regs, no cycle
		instructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(varA, List.of(CALL_RETURN_REG)),
				new LiveVarRegisterState(varB, List.of(CALL_ARG_1))
		)));
		strategy.transferTo(List.of(
				new LiveVarRegisterState(varA, List.of(CALL_ARG_2)),
				new LiveVarRegisterState(varB, List.of(nonVolatile0))
		), consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(varA, List.of(CALL_ARG_2)),
				                                    new LiveVarRegisterState(varB, List.of(nonVolatile0))
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromReg(varB, CALL_ARG_1, nonVolatile0),
				                                    movRegFromReg(varA, CALL_RETURN_REG, CALL_ARG_2)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		// chained regs, no cycle, but order important
		instructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(varA, List.of(CALL_RETURN_REG)),
				new LiveVarRegisterState(varB, List.of(CALL_ARG_1))
		)));
		strategy.transferTo(List.of(
				new LiveVarRegisterState(varA, List.of(CALL_ARG_1)),
				new LiveVarRegisterState(varB, List.of(CALL_ARG_2))
		), consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(varB, List.of(CALL_ARG_2)),
				                                    new LiveVarRegisterState(varA, List.of(CALL_ARG_1))
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromReg(varA, CALL_RETURN_REG, CALL_ARG_1),
				                                    movRegFromReg(varB, CALL_ARG_1, CALL_ARG_2)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		// cycled regs
		instructions.clear();
		strategy.setState(new AllLiveVarRegisterState(List.of(
				new LiveVarRegisterState(varA, List.of(CALL_ARG_1)),
				new LiveVarRegisterState(varB, List.of(CALL_ARG_2))
		)));
		strategy.transferTo(List.of(
				new LiveVarRegisterState(varA, List.of(CALL_ARG_2)),
				new LiveVarRegisterState(varB, List.of(CALL_ARG_1))
		), consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(varB, List.of(CALL_ARG_2)),
				                                    new LiveVarRegisterState(varA, List.of(CALL_ARG_1))
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromReg(varA, CALL_RETURN_REG, CALL_ARG_1),
				                                    movRegFromReg(varA, CALL_ARG_1, CALL_ARG_2),
				                                    movRegFromReg(varA, CALL_ARG_2, CALL_ARG_1),
				                                    movRegFromReg(varA, CALL_ARG_1, CALL_RETURN_REG)
		                                    ), instructions);
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
				                                    new LiveVarRegisterState(var("a", 2), List.of(CALL_ARG_1)),
				                                    new LiveVarRegisterState(var("b", 3), List.of(CALL_ARG_2))
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
				                                    new LiveVarRegisterState(var("a", 2), List.of(CALL_ARG_1))
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromReg("b", CALL_ARG_2, CALL_RETURN_REG)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		strategy.freeVolatileRegisters(consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(var("a", 2), List.of(nonVolatile0))
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromReg("a", CALL_ARG_1, nonVolatile0),
				                                    movRegFromReg("b", CALL_ARG_2, CALL_RETURN_REG)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		strategy.prepareCallArgs(List.of(
				var("y", 1),
				var("x", 0)
		), consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(var("a", 2), List.of(nonVolatile0)),
				                                    new LiveVarRegisterState(var("y", 1), List.of(CALL_ARG_1)),
				                                    new LiveVarRegisterState(var("x", 0), List.of(CALL_ARG_2))
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromReg("a", CALL_ARG_1, nonVolatile0),
				                                    movRegFromReg("b", CALL_ARG_2, CALL_RETURN_REG)
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
				                                    new LiveVarRegisterState(var("y", 1), List.of(CALL_ARG_1)),
				                                    new LiveVarRegisterState(var("x", 0), List.of(CALL_ARG_2))
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
				                                    movRegFromReg("x", CALL_ARG_2, nonVolatile1),
				                                    movRegFromReg("y", CALL_ARG_1, nonVolatile0),
				                                    movRegFromReg("a", nonVolatile0, CALL_RETURN_REG)
		                                    ), instructions);
		// ------------------------------------------------------------------------------
		strategy.prepareCallArgs(List.of(
				var("x", 0),
				var("y", 1)
		), consumer);
		assertEqualsVarStateAndInstructions(List.of(
				                                    new LiveVarRegisterState(var("x", 0), List.of(CALL_ARG_1, nonVolatile1)),
				                                    new LiveVarRegisterState(var("y", 1), List.of(CALL_ARG_2, nonVolatile0))
		                                    ), strategy,
		                                    List.of(
				                                    movRegFromReg("x", CALL_ARG_2, nonVolatile1),
				                                    movRegFromReg("y", CALL_ARG_1, nonVolatile0),
				                                    movRegFromReg("a", nonVolatile0, CALL_RETURN_REG)
		                                    ), instructions);
	}

	private static IRVar arg(String name, int index) {
		return new IRVar(name, index, VariableScope.argument, Type.I32, true);
	}

	private static void assertEqualsVarStateAndInstructions(List<LiveVarRegisterState> expectedVarStates, RegisterAllocationStrategy strategy,
	                                                        List<IRInstruction> expectedPreInstructions, List<IRInstruction> preInstructions,
	                                                        List<IRInstruction> expectedPostInstructions, List<IRInstruction> postInstructions) {
		assertEquals(new AllLiveVarRegisterState(expectedVarStates), strategy.getState());
		assertEquals(expectedPreInstructions, preInstructions);
		assertEquals(expectedPostInstructions, postInstructions);
	}
}