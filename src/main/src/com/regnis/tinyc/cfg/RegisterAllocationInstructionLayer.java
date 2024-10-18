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
		boolean addLiveComment = false;
		for (IRInstruction instruction : block.instructions().reversed()) {
			// these need to be the last block instructions
			if (!(instruction instanceof IRJump)
			    && !(instruction instanceof IRBranch)) {
				addLiveComment = true;
			}
			if (addLiveComment && false) {
				consumer.accept(new IRComment("live: " + strategy.getState().vars()));
			}

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
			if (!strategy.isLiveAfter(target)) {
				return;
			}

			target = strategy.target(target, consumer);
			consumer.accept(new IRAddrOf(target, source, addrOf.location()));
		}
		case IRAddrOfArray addrOf -> {
			IRVar addr = addrOf.addr();
			if (!strategy.isLiveAfter(addr)) {
				return;
			}

			addr = strategy.target(addr, consumer);
			consumer.accept(new IRAddrOfArray(addr, addrOf.array(), addrOf.varIsArray(), addrOf.location()));
		}
		case IRBinary binary -> {
			IRVar target = binary.target();
			if (!strategy.isLiveAfter(target)) {
				return;
			}

			final IRBinary.Op op = binary.op();
			// x86-specific
			if (op == IRBinary.Op.Div || op == IRBinary.Op.Mod) {
				// (rdx rax) / %reg -> rax
				// (rdx rax) % %reg -> rdx
				final int RAX = 0;
				final int RDX = 2;
				final Predicate<Integer> predicate = r -> r != RAX && r != RDX;
				strategy.freeRegister(RDX, predicate, consumer);
				target = strategy.target(target, RAX, predicate, consumer);
				final IRVar left = strategy.sourceForModificationInReg(binary.left(), RAX);
				final IRVar right = strategy.source(binary.right(), predicate, preConsumer, consumer);
				consumer.accept(new IRBinary(target, op, left, right, binary.location()));
			}
			else {
				target = strategy.target(target, consumer);
				if (op.relational) {
					final IRVar left = strategy.source(binary.left(), preConsumer, consumer);
					final IRVar right = strategy.source(binary.right(), preConsumer, consumer);
					consumer.accept(new IRBinary(target, op, left, right, binary.location()));
				}
				else {
					// add, sub, ... reuse first operand for target
					final IRVar left = strategy.sourceForModificationInReg(binary.left(), target.index());
					Utils.assertTrue(target.index() == left.index());
					final IRVar right = strategy.source(binary.right(), preConsumer, consumer);
					consumer.accept(new IRBinary(target, op, left, right, binary.location()));
				}
			}
		}
		case IRBranch branch -> {
			final IRVar conditionVar = strategy.source(branch.conditionVar(), preConsumer, consumer);
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
			if (!strategy.isLiveAfter(target)) {
				return;
			}

			target = strategy.target(target, consumer);
			IRVar source = cast.source();
			source = strategy.source(source, preConsumer, consumer);
			consumer.accept(new IRCast(target, source, cast.location()));
		}
		case IRComment ignored -> consumer.accept(instruction);
		case IRCopy copy -> {
			IRVar target = copy.target();
			if (!strategy.isLiveAfter(target)) {
				return;
			}

			target = strategy.target(target, consumer);
			IRVar source = copy.source();
			source = strategy.source(source, preConsumer, consumer);
			consumer.accept(new IRCopy(target, source, copy.location()));
		}
		case IRJump ignored -> consumer.accept(instruction);
		case IRLiteral literal -> {
			IRVar target = literal.target();
			if (!strategy.isLiveAfter(target)) {
				return;
			}

			target = strategy.target(target, consumer);
			consumer.accept(new IRLiteral(target, literal.value(), literal.location()));
		}
		case IRMemLoad load -> {
			IRVar target = load.target();
			if (!strategy.isLiveAfter(target)) {
				return;
			}

			target = strategy.target(target, consumer);
			IRVar addr = load.addr();
			addr = strategy.source(addr, preConsumer, consumer);
			consumer.accept(new IRMemLoad(target, addr, load.location()));
		}
		case IRMemStore store -> {
			final IRVar addr = strategy.source(store.addr(), preConsumer, consumer);
			final IRVar value = strategy.source(store.value(), preConsumer, consumer);
			consumer.accept(new IRMemStore(addr, value, store.location()));
		}
		case IRRetValue ret -> {
			final IRVar var = strategy.source(ret.var(), preConsumer, consumer);
			consumer.accept(new IRRetValue(var, ret.location()));
		}
		case IRString string -> {
			IRVar target = string.target();
			if (!strategy.isLiveAfter(target)) {
				return;
			}

			target = strategy.target(target, consumer);
			consumer.accept(new IRLiteral(target, string.stringIndex(), string.location()));
		}
		case IRUnary unary -> {
			IRVar target = unary.target();
			if (!strategy.isLiveAfter(target)) {
				return;
			}

			target = strategy.target(target, consumer);
			IRVar source = unary.source();
			source = strategy.source(source, preConsumer, consumer);
			consumer.accept(new IRUnary(unary.op(), target, source));
		}
		default -> {
//			preConsumer.accept(new IRComment("; not yet implemented"));
//			consumer.accept(instruction);
			throw new UnsupportedOperationException(instruction.toString());
		}
		}
		;
	}
}
