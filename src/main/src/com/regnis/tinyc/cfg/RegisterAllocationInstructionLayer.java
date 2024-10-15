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

		final IRInstruction replacedInstruction = process(instruction, preConsumer);
		consumer.accept(replacedInstruction);
		beforeInstructions.forEach(consumer);
	}

	private IRInstruction process(@NotNull IRInstruction instruction, Consumer<IRInstruction> preConsumer) {
		return switch (instruction) {
			case IRAddrOf addrOf -> {
				final IRVar source = addrOf.source();
				Utils.assertTrue(source.scope() != VariableScope.register);
				IRVar target = addrOf.target();
				target = strategy.target(target, consumer);
				yield new IRAddrOf(target, source, addrOf.location());
			}
			case IRAddrOfArray addrOf -> {
				IRVar addr = addrOf.addr();
				addr = strategy.target(addr, consumer);
				IRVar index = addrOf.index();
				index = strategy.source(index, List.of(), preConsumer);
				yield new IRAddrOfArray(addr, addrOf.array(), index, addrOf.varIsArray(), addrOf.location());
			}
			case IRArrayAccess access -> {
				IRVar addr = access.addr();
				addr = strategy.target(addr, consumer);
				IRVar index = access.index();
				index = strategy.source(index, List.of(), preConsumer);
				yield new IRArrayAccess(addr, access.array(), index, access.location());
			}
			case IRBinary binary -> {
				final IRVar target = strategy.target(binary.target(), consumer);
				final IRVar left = strategy.source(binary.left(), List.of(), preConsumer);
				final IRVar right = strategy.source(binary.right(), List.of(), preConsumer);
				yield new IRBinary(target, binary.op(), left, right, binary.location());
			}
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
				final List<IRVar> args = strategy.prepareCallArgs(call.args(), preConsumer);
				yield new IRCall(target, call.name(), args, call.location());
			}
			case IRCast cast -> {
				IRVar target = cast.target();
				target = strategy.target(target, consumer);
				IRVar source = cast.source();
				source = strategy.source(source, List.of(), preConsumer);
				yield new IRCast(target, source, cast.location());
			}
			case IRComment ignored -> instruction;
			case IRJump ignored -> instruction;
			case IRLiteral literal -> {
				final IRVar target = strategy.target(literal.target(), consumer);
				yield new IRLiteral(target, literal.value(), literal.location());
			}
			case IRMemStore store -> {
				final IRVar addr = strategy.source(store.addr(), List.of(), preConsumer);
				final IRVar value = strategy.source(store.value(), List.of(), preConsumer);
				yield new IRMemStore(addr, value, store.location());
			}
			case IRUnary unary -> {
				IRVar target = unary.target();
				target = strategy.target(target, consumer);
				IRVar source = unary.source();
				source = strategy.source(source, List.of(), preConsumer);
				yield new IRUnary(unary.op(), target, source);
			}
			default -> {
				preConsumer.accept(new IRComment("; not yet implemented"));
				yield instruction;
//			throw new UnsupportedOperationException(instruction.toString());
			}
		};
	}
}
