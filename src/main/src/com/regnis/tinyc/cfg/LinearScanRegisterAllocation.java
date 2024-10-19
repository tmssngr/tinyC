package com.regnis.tinyc.cfg;

import com.regnis.tinyc.ir.*;

import java.util.*;
import java.util.function.*;

/**
 * @author Thomas Singer
 */
public final class LinearScanRegisterAllocation {

	public static ControlFlowGraph process(ControlFlowGraph cfg) {
		final Map<String, BasicBlock> blocks = new HashMap<>();
		for (BasicBlock block : cfg.blocks()) {
			final BasicBlock newBlock = process(block);
			blocks.put(newBlock.name, newBlock);
		}
		return new ControlFlowGraph(cfg.name(), blocks);
	}

	public static BasicBlock process(BasicBlock block) {
		final RegisterAllocationStrategy strategy = new RegisterAllocationStrategy(4, 0, 2);
		final List<RegisterAllocationStrategy.LiveVarRegisterState> states = new ArrayList<>();
		for (IRVar var : block.getLiveAfter()) {
			states.add(new RegisterAllocationStrategy.LiveVarRegisterState(var, List.of()));
		}
		strategy.setState(new RegisterAllocationStrategy.AllLiveVarRegisterState(states));

		final List<IRInstruction> instructions = new ArrayList<>();
		final Consumer<IRInstruction> consumer = instructions::addFirst;
		final RegisterAllocationInstructionLayer instructionLayer = new RegisterAllocationInstructionLayer(strategy, consumer);
		instructionLayer.process(block);
		// is first block?
		if (block.predecessors().isEmpty()) {
			strategy.handleFirstBlockBegin(consumer);
		}
		else {
			strategy.freeAllRegisters(consumer);
		}

		return new BasicBlock(block.name, instructions, block.predecessors(), block.successors());
	}
}
