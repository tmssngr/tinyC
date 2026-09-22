package com.regnis.tinyc.ir.cfg;

import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class DetectVarLiveness {

	public static void process(ControlFlowGraph cfg) {
		while (detect(cfg)) {
		}
	}

	public static boolean processBlock(@NotNull BasicBlock block, @NotNull Set<IRVar> liveOut) {
		final Set<IRVar> live = new HashSet<>(liveOut);
		final Set<IRVar> liveAfter = new HashSet<>(live);
		boolean changed = liveAfter.addAll(block.getLiveAfter());

		final List<IRInstruction> instructions = block.instructions();
		for (int i = instructions.size(); i-- > 0; ) {
			final IRInstruction instruction = instructions.get(i);
			final Set<IRVar> uses = new HashSet<>();
			final Set<IRVar> defines = new HashSet<>();
			detectLiveness(instruction, uses, defines);
			if (block.setLive(i, uses, defines, live)) {
				changed = true;
			}
		}

		block.setLive(live, liveAfter);
		return changed;
	}

	private static boolean detect(ControlFlowGraph cfg) {
		final Set<String> processed = new HashSet<>();

		boolean changed = false;

		final List<String> pending = new ArrayList<>();
		pending.add(cfg.blocks().getLast().name);

		while (!pending.isEmpty()) {
			final String name = pending.removeFirst();
			if (!processed.add(name)) {
				continue;
			}

			final BasicBlock block = cfg.get(name);
			final Set<IRVar> live = getLiveInFromAllNext(block, cfg);
			if (processBlock(block, live)) {
				changed = true;
			}

			pending.addAll(block.predecessors());
		}
		return changed;
	}

	private static Set<IRVar> getLiveInFromAllNext(BasicBlock block, ControlFlowGraph cfg) {
		final Set<IRVar> liveIn = new HashSet<>();
		for (String next : block.successors()) {
			final BasicBlock nextBlock = cfg.get(next);
			liveIn.addAll(nextBlock.getLiveBefore());
		}
		return liveIn;
	}

	private static void detectLiveness(IRInstruction instruction, Set<IRVar> uses, Set<IRVar> defines) {
		IRUtils.getVars(instruction,
		                var -> uses(var, uses),
		                var -> defines(var, defines));
	}

	private static void uses(IRVar var, Set<IRVar> uses) {
		uses.add(var);
	}

	private static void defines(IRVar var, Set<IRVar> defines) {
		defines.add(var);
	}
}
