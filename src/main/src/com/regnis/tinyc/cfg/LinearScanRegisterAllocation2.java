package com.regnis.tinyc.cfg;

import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class LinearScanRegisterAllocation2 {

	public static List<BasicBlock> process(ControlFlowGraph cfg, RegisterAllocationStrategy strategy) {
		final LinearScanRegisterAllocation2 allocation = new LinearScanRegisterAllocation2(cfg, strategy);
		final List<CfgToChainConverter.Chain> chains = CfgToChainConverter.convert(cfg);
		for (CfgToChainConverter.Chain chain : chains) {
			allocation.process(chain.basicBlocks());
		}
		return allocation.getFinalBlocks();
	}

	private final Map<String, NewBasicBlock> newBasicBlockMap = new HashMap<>();
	private final ControlFlowGraph cfg;
	private final RegisterAllocationStrategy strategy;

	private LinearScanRegisterAllocation2(@NotNull ControlFlowGraph cfg, @NotNull RegisterAllocationStrategy strategy) {
		this.cfg = cfg;
		this.strategy = strategy;
	}

	private void process(@NotNull List<String> blocks) {
		strategy.setState(RegisterAllocationStrategy.EMPTY_STATE);
		for (String name : blocks.reversed()) {
			processReverse(name);
		}
	}

	private void processReverse(String name) {
		final BasicBlock block = cfg.get(name);

		final var liveOutState = strategy.getState();

		final List<IRInstruction> instructions = new ArrayList<>();
		final RegisterAllocationInstructionLayer instructionLayer = new RegisterAllocationInstructionLayer(strategy, instructions::addFirst);
		instructionLayer.process(block);

		final NewBasicBlock newBlock = getNewBasicBlock(name);
		newBlock.liveOut = liveOutState;
		newBlock.instructions = instructions;
		newBlock.liveIn = strategy.getState();
	}

	private NewBasicBlock getNewBasicBlock(String name) {
		return newBasicBlockMap.computeIfAbsent(name, unused -> new NewBasicBlock());
	}

	private List<BasicBlock> getFinalBlocks() {
		final Map<String, BasicBlock> blocks = new HashMap<>();
		for (Map.Entry<String, NewBasicBlock> entry : this.newBasicBlockMap.entrySet()) {
			final String name = entry.getKey();
			final BasicBlock block = cfg.get(name);
			final NewBasicBlock newBlock = entry.getValue();
			blocks.put(name, new BasicBlock(name, newBlock.instructions, block.predecessors(), block.successors()));
		}

		final ControlFlowGraph graph = new ControlFlowGraph(cfg.name(), blocks);
		return graph.blocks();
	}

	private static final class NewBasicBlock {
		public List<IRInstruction> instructions = List.of();
		public RegisterAllocationStrategy.AllLiveVarRegisterState liveIn;
		public RegisterAllocationStrategy.AllLiveVarRegisterState liveOut;
	}
}
