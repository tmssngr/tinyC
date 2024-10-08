package com.regnis.tinyc.cfg;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;
import java.util.function.*;

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
		// todo
		return cfg.blocks();
	}

	private final ControlFlowGraph cfg;
	private final RegisterAllocationStrategy strategy;

	private LinearScanRegisterAllocation2(@NotNull ControlFlowGraph cfg, @NotNull RegisterAllocationStrategy strategy) {
		this.cfg = cfg;
		this.strategy = strategy;
	}

	private void process(@NotNull List<String> blocks) {
		RegisterAllocationStrategy.AllLiveVarRegisterState  state = RegisterAllocationStrategy.EMPTY_STATE;
		for (String name : blocks.reversed()) {
			state = processReverse(name, state);
		}
	}

	private RegisterAllocationStrategy.AllLiveVarRegisterState  processReverse(String name, RegisterAllocationStrategy.AllLiveVarRegisterState  state) {
		final BasicBlock block = cfg.get(name);
		for (IRInstruction instruction : block.instructions().reversed()) {
			state = processReverse(instruction, state);
		}
		return state;
	}

	@NotNull
	private RegisterAllocationStrategy.AllLiveVarRegisterState  processReverse(@NotNull IRInstruction instruction, @NotNull RegisterAllocationStrategy.AllLiveVarRegisterState  state) {
		if (instruction instanceof IRJump
		    || instruction instanceof IRComment) {
			return state;
		}

		if (instruction instanceof IRCall call) {
			final IRVar target = call.target();
			state = strategy.prevState(state, target, call.args(), new Consumer<IRInstruction>() {
				@Override
				public void accept(IRInstruction instruction) {

				}
			});
		}
		else {
			final Set<LiveVar> uses = new HashSet<>();
			final Set<LiveVar> defines = new HashSet<>();
			DetectVarLiveness.detectLiveness(instruction, uses, defines);
		}
		return state;
	}

}
