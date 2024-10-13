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
		final Consumer<IRInstruction> beforeConsumer = beforeInstructions::add;

		instruction = switch (instruction) {
			case IRAddrOf addrOf -> {
				final IRVar source = addrOf.source();
				Utils.assertTrue(source.scope() != VariableScope.register);
				IRVar target = addrOf.target();
				target = strategy.callTarget(target, consumer);
				yield new IRAddrOf(target, source, addrOf.location());
			}
			case IRBinary binary -> processBinary(binary, beforeConsumer);
			case IRBranch branch -> {
				final IRVar conditionVar = strategy.source(branch.conditionVar(), List.of(), consumer);
				yield new IRBranch(conditionVar, branch.jumpOnTrue(), branch.target(), branch.nextLabel());
			}
			case IRCall call -> {
				IRVar target = call.target();
				if (target != null) {
					target = strategy.callTarget(target, consumer);
				}

				strategy.freeVolatileRegisters(consumer);
				final List<IRVar> args = strategy.prepareCallArgs(call.args(), beforeConsumer);
				yield new IRCall(target, call.name(), args, call.location());
			}
			case IRComment ignored -> instruction;
			case IRJump ignored -> instruction;
			case IRLiteral literal -> {
				final IRVar target = strategy.target(literal.target(), consumer);
				yield new IRLiteral(target, literal.value(), literal.location());
			}
			case IRMemStore store -> {
				final IRVar addr = strategy.source(store.addr(), List.of(), beforeConsumer);
				final IRVar value = strategy.source(store.value(), List.of(), beforeConsumer);
				yield new IRMemStore(addr, value, store.location());
			}
			default -> {
				beforeConsumer.accept(new IRComment("; not yet implemented"));
				yield instruction;
//			throw new UnsupportedOperationException(instruction.toString());
			}
		};
		consumer.accept(instruction);
		beforeInstructions.forEach(consumer);
	}

	private IRBinary processBinary(IRBinary binary, Consumer<IRInstruction> beforeConsumer) {
		final IRVar target = strategy.target(binary.target(), consumer);
		final IRVar left = strategy.source(binary.left(), List.of(), beforeConsumer);
		final IRVar right = strategy.source(binary.right(), List.of(), beforeConsumer);
		return new IRBinary(target, binary.op(), left, right, binary.location());
	}
}
