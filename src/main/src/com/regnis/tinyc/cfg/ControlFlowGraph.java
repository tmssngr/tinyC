package com.regnis.tinyc.cfg;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class ControlFlowGraph {

	private final Cfg cfg;
	private final List<BasicBlock> blocks;

	public ControlFlowGraph(@NotNull Cfg cfg) {
		this.cfg = cfg;

		blocks = getSorted();
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

	private List<BasicBlock> getSorted() {
		final List<BasicBlock> blocks = new ArrayList<>();
		for (String name : cfg.getInOrder()) {
			blocks.add(cfg.get(name));
		}
		return blocks;
	}
}
