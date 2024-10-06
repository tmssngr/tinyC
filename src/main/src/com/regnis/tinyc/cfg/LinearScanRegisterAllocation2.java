package com.regnis.tinyc.cfg;

import com.regnis.tinyc.ast.*;
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
		LiveState state = LiveState.EMPTY;
		for (String name : blocks.reversed()) {
			state = processReverse(name, state);
		}
	}

	private LiveState processReverse(String name, LiveState state) {
		final BasicBlock block = cfg.get(name);
		for (IRInstruction instruction : block.instructions().reversed()) {
			state = processReverse(instruction, state);
		}
		return state;
	}

	@NotNull
	private LiveState processReverse(@NotNull IRInstruction instruction, @NotNull LiveState state) {
		if (instruction instanceof IRJump
		    || instruction instanceof IRComment) {
			return state;
		}

		final Set<LiveVar> uses = new HashSet<>();
		final Set<LiveVar> defines = new HashSet<>();
		DetectVarLiveness.detectLiveness(instruction, uses, defines);
		if (instruction instanceof IRCall call) {
			final IRVar target = call.target();
			if (target != null) {
				state = state.remove(target.index(), target.scope());
			}
			int register = strategy.firstCallArgRegister();
			int registerArgCount = strategy.maxCallArgRegisters();
			for (IRVar arg : call.args()) {
				if (registerArgCount > 0) {
					state = state.add(arg.name(), arg.index(), arg.scope(), register);
					register++;
					registerArgCount--;
				}
			}
		}
		else {

		}
		return state;
	}

	private record LiveState(List<VarState> varStates) {
		private LiveState {
			varStates = List.copyOf(varStates);
		}

		public static final LiveState EMPTY = new LiveState(List.of());

		private int indexOf(int index, VariableScope scope) {
			for (int i = 0; i < varStates.size(); i++) {
				final VarState state = varStates.get(i);
				if (state.index == index && state.scope == scope) {
					return i;
				}
			}
			return -1;
		}

		public LiveState remove(int index, VariableScope scope) {
			final int i = indexOf(index, scope);
			if (i < 0) {
				return this;
			}

			final List<VarState> states = new ArrayList<>(varStates);
			states.remove(i);
			return new LiveState(states);
		}

		public LiveState add(String name, int index, VariableScope scope, int register) {
			final int i = indexOf(index, scope);
			if (i < 0) {
				final List<VarState> states = new ArrayList<>(varStates);
				states.add(new VarState(name, index, scope, register));
				return new LiveState(states);
			}
			return this;
		}
	}

	private record VarState(@NotNull String name, int index, @NotNull VariableScope scope, int register) {
	}
}
