package com.regnis.tinyc.cfg;

import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * No record because of additional field `nameToBlock`.
 *
 * @author Thomas Singer
 */
public final class ControlFlowGraph {

	private final Cfg cfg;

	public ControlFlowGraph(@NotNull Cfg cfg) {
		this.cfg = cfg;
	}

	@Deprecated
	public ControlFlowGraph(@NotNull String name, Map<String, BasicBlock> blockMap) {
		cfg = new Cfg(name);
		for (Map.Entry<String, BasicBlock> entry : blockMap.entrySet()) {
			cfg.add(entry.getValue());
		}

		cfg.check();
	}

	@NotNull
	public String name() {
		return cfg.getRoot();
	}

	@NotNull
	public List<BasicBlock> blocks() {
		return Collections.unmodifiableList(getSorted());
	}

	@NotNull
	public BasicBlock get(@NotNull String name) {
		return cfg.get(name);
	}

	@NotNull
	public List<IRInstruction> getFlattenInstructions() {
		final CfgLoopInfos infos = new CfgLoopInfos(cfg);
		final List<String> blocksInOrder = infos.getInOrder();
		final List<IRInstruction> instructions = new ArrayList<>();
		for (String name : blocksInOrder) {
			final int level = infos.getLoopLevel(name);
			final BasicBlock block = cfg.get(name);
			if (name.startsWith("@")) {
				instructions.add(new IRLabel(name, level));
			}
			instructions.addAll(block.instructions());
		}

		return IROptimizer.optimize(instructions);
	}

	private List<BasicBlock> getSorted() {
		final List<BasicBlock> blocks = new ArrayList<>();
		for (String name : cfg.getInOrder()) {
			blocks.add(cfg.get(name));
		}
		return blocks;
	}
}
