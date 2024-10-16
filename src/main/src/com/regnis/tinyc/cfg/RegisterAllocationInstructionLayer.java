package com.regnis.tinyc.cfg;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;
import java.util.function.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class RegisterAllocationInstructionLayer {

	private final RegisterAllocationStrategy strategy;
	private final Consumer<IRInstruction> consumer;

	public RegisterAllocationInstructionLayer(@NotNull RegisterAllocationStrategy strategy, @NotNull Consumer<IRInstruction> consumer) {
		this.strategy = strategy;
		this.consumer = consumer;
	}

	public void process(BasicBlock block) {
		for (IRInstruction instruction : block.instructions().reversed()) {
			process(instruction);
		}
	}

	public void process(@NotNull IRInstruction instruction) {
		final List<IRInstruction> beforeInstructions = new ArrayList<>();
		final Consumer<IRInstruction> preConsumer = beforeInstructions::add;

		process(instruction, preConsumer);

		beforeInstructions.forEach(consumer);
	}

	private void process(@NotNull IRInstruction instruction, Consumer<IRInstruction> preConsumer) {
		switch (instruction) {
		case IRAddrOf addrOf -> {
			final IRVar source = addrOf.source();
			Utils.assertTrue(source.scope() != VariableScope.register);
			IRVar target = addrOf.target();
			target = strategy.target(target, consumer);
			consumer.accept(new IRAddrOf(target, source, addrOf.location()));
		}
		case IRAddrOfArray addrOf -> {
			IRVar addr = addrOf.addr();
			addr = strategy.target(addr, consumer);
			IRVar index = addrOf.index();
			index = strategy.source(index, null, preConsumer, consumer);
			consumer.accept(new IRAddrOfArray(addr, addrOf.array(), index, addrOf.varIsArray(), addrOf.location()));
		}
		case IRArrayAccess access -> {
			IRVar addr = access.addr();
			addr = strategy.target(addr, consumer);
			IRVar index = access.index();
			index = strategy.source(index, null, preConsumer, consumer);
			consumer.accept(new IRArrayAccess(addr, access.array(), index, access.location()));
		}
		case IRBinary binary -> {
			IRVar target = binary.target();
			if (!strategy.isLiveAfter(target)) {
				return;
			}

			target = strategy.target(target, consumer);
			if (binary.op().relational) {
				final IRVar left = strategy.source(binary.left(), null, preConsumer, consumer);
				final IRVar right = strategy.source(binary.right(), left, preConsumer, consumer);
				consumer.accept(new IRBinary(target, binary.op(), left, right, binary.location()));
			}
			else {
				// add, sub, ... reuse first operand for target
				final IRVar left = strategy.sourceForModificationInReg(binary.left(), target.index());
				Utils.assertTrue(target.index() == left.index());
				final IRVar right = strategy.source(binary.right(), left, preConsumer, consumer);
				consumer.accept(new IRBinary(target, binary.op(), left, right, binary.location()));
			}
		}
		case IRBranch branch -> {
			final IRVar conditionVar = strategy.source(branch.conditionVar(), null, preConsumer, consumer);
			consumer.accept(new IRBranch(conditionVar, branch.jumpOnTrue(), branch.target(), branch.nextLabel()));
		}
		case IRCall call -> {
			IRVar target = call.target();
			if (target != null) {
				target = strategy.callTarget(target, consumer);
			}

			strategy.freeVolatileRegisters(consumer);
			final List<IRVar> args = strategy.prepareCallArgs(call.args(), preConsumer);
			consumer.accept(new IRCall(target, call.name(), args, call.location()));
		}
		case IRCast cast -> {
			IRVar target = cast.target();
			target = strategy.target(target, consumer);
			IRVar source = cast.source();
			source = strategy.source(source, null, preConsumer, consumer);
			consumer.accept(new IRCast(target, source, cast.location()));
		}
		case IRComment ignored -> consumer.accept(instruction);
		case IRJump ignored -> consumer.accept(instruction);
		case IRLiteral literal -> {
			final IRVar target = strategy.target(literal.target(), consumer);
			consumer.accept(new IRLiteral(target, literal.value(), literal.location()));
		}
		case IRMemStore store -> {
			final IRVar addr = strategy.source(store.addr(), null, preConsumer, consumer);
			final IRVar value = strategy.source(store.value(), null, preConsumer, consumer);
			consumer.accept(new IRMemStore(addr, value, store.location()));
		}
		case IRUnary unary -> {
			IRVar target = unary.target();
			target = strategy.target(target, consumer);
			IRVar source = unary.source();
			source = strategy.source(source, null, preConsumer, consumer);
			consumer.accept(new IRUnary(unary.op(), target, source));
		}
		default -> {
			preConsumer.accept(new IRComment("; not yet implemented"));
			consumer.accept(instruction);
//			throw new UnsupportedOperationException(instruction.toString());
		}
		}
		;
	}
}
