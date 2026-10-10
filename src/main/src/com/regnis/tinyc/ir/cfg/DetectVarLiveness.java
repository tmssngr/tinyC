package com.regnis.tinyc.ir.cfg;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class DetectVarLiveness {

	@NotNull
	public static VarLiveness process(@NotNull ControlFlowGraph cfg) {
		final DetectVarLiveness detectVarLiveness = new DetectVarLiveness(cfg);
		while (detectVarLiveness.detect()) {
		}

		return new VarLiveness(detectVarLiveness.nameToBlock);
	}

	private final Map<String, VarLiveness.Block> nameToBlock = new HashMap<>();
	private final List<BasicBlock> blocks;

	private DetectVarLiveness(ControlFlowGraph cfg) {
		blocks = cfg.blocks();
		for (BasicBlock block : blocks) {
			nameToBlock.put(block.name, new VarLiveness.Block(block));
		}
	}

	private boolean detect() {
		boolean changed = false;
		for (int index = blocks.size(); index-- > 0; ) {
			final BasicBlock block = blocks.get(index);
			final Set<IRVar> live = getLiveInFromAllNext(block);
			if (processBlock(block, live)) {
				changed = true;
			}
		}
		return changed;
	}

	private boolean processBlock(@NotNull BasicBlock block, @NotNull Set<IRVar> liveOut) {
		final VarLiveness.Block blockLiveness = nameToBlock.get(block.name);

		final Set<IRVar> live = new HashSet<>(liveOut);
		final Set<IRVar> liveAfter = new HashSet<>(live);
		boolean changed = liveAfter.addAll(blockLiveness.getLiveAfter());

		final List<IRInstruction> instructions = block.instructions();
		for (int i = instructions.size(); i-- > 0; ) {
			final IRInstruction instruction = instructions.get(i);
			final Set<IRVar> uses = new HashSet<>();
			final Set<IRVar> defines = new HashSet<>();
			detectLiveness(instruction, uses, defines);
			if (blockLiveness.setLive(i, uses, defines, live)) {
				changed = true;
			}
		}

		blockLiveness.setLive(live, liveAfter);
		return changed;
	}

	private Set<IRVar> getLiveInFromAllNext(BasicBlock block) {
		final Set<IRVar> liveIn = new HashSet<>();
		for (String next : block.successors()) {
			final VarLiveness.Block blockLiveness = nameToBlock.get(next);
			liveIn.addAll(blockLiveness.getLiveBefore());
		}
		return liveIn;
	}

	private static void detectLiveness(IRInstruction instruction, Set<IRVar> uses, Set<IRVar> defines) {
		IRUtils.getVars(instruction,
		                var -> add(var, uses),
		                var -> add(var, defines));
	}

	private static void add(IRVar var, Set<IRVar> uses) {
		if (var.scope() != VariableScope.global) {
			uses.add(var);
		}
	}
}
