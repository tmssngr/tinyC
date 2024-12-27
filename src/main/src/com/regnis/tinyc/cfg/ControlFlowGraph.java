package com.regnis.tinyc.cfg;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * No record because of additional field `nameToBlock`.
 *
 * @author Thomas Singer
 */
public final class ControlFlowGraph {

	private final Cfg cfg;
	private final List<BasicBlock> blocks;

	public ControlFlowGraph(@NotNull Cfg cfg) {
		this.cfg = cfg;

		blocks = new ArrayList<>();
		cfg.visitInPostOrder(block -> {
			if (block.successors().isEmpty()) {
				blocks.add(block);
			}
			else {
				blocks.addFirst(block);
			}
		});
	}

	@Deprecated
	public ControlFlowGraph(@NotNull String name, Map<String, BasicBlock> blockMap) {
		cfg = new Cfg(name);
		for (Map.Entry<String, BasicBlock> entry : blockMap.entrySet()) {
			cfg.add(entry.getValue());
		}

		cfg.check();

		blocks = new ArrayList<>();
		cfg.visitInPostOrder(block -> {
			if (block.successors().isEmpty()) {
				blocks.add(block);
			}
			else {
				blocks.addFirst(block);
			}
		});
	}

	@NotNull
	public String name() {
		return cfg.getRoot();
	}

	@NotNull
	public List<BasicBlock> blocks() {
		return Collections.unmodifiableList(blocks);
	}

	@NotNull
	public BasicBlock get(@NotNull String name) {
		return cfg.get(name);
	}
}
