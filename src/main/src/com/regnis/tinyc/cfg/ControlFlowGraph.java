package com.regnis.tinyc.cfg;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ir.*;

import java.util.*;
import java.util.function.*;

import org.jetbrains.annotations.*;

/**
 * No record because of additional field `nameToBlock`.
 *
 * @author Thomas Singer
 */
public final class ControlFlowGraph {
	private final Map<String, BasicBlock> nameToBlock = new HashMap<>();
	private final IRFunction function;
	private final List<BasicBlock> blocks;

	public ControlFlowGraph(@NotNull IRFunction function, @NotNull List<BasicBlock> blocks) {
		this.function = function;
		this.blocks = blocks;

		Utils.assertTrue(blocks.getFirst().predecessors.isEmpty());
		// if the method does not return, the last block has one successor
//		Utils.assertTrue(blocks.getLast().successors.isEmpty());

		for (BasicBlock block : blocks) {
			final BasicBlock prev = nameToBlock.put(block.name, block);
			Utils.assertTrue(prev == null);
		}

		for (BasicBlock block : blocks) {
			for (String predecessor : block.predecessors) {
				if (!nameToBlock.containsKey(predecessor)) {
					new Throwable(block.name + " missing predecessor: " + predecessor).printStackTrace();
				}
			}
			for (String successor : block.successors) {
				if (!nameToBlock.containsKey(successor)) {
					new Throwable(block.name + " missing successor: " + successor).printStackTrace();
				}
			}
		}
	}

	@NotNull
	public String name() {
		return function.name();
	}

	@NotNull
	public List<BasicBlock> blocks() {
		return Collections.unmodifiableList(blocks);
	}

	@NotNull
	public BasicBlock get(@NotNull String name) {
		return Objects.requireNonNull(nameToBlock.get(name), name);
	}

	@NotNull
	public BasicBlock getLast() {
		return blocks.getLast();
	}

	public void foreach(@NotNull Consumer<BasicBlock> consumer) {
		blocks.forEach(consumer);
	}

	public IRFunction flatten() {
		final List<IRInstruction> instructions = new ArrayList<>();
		for (BasicBlock block : blocks) {
			if (block.name.startsWith("@")) {
				instructions.add(new IRLabel(block.name));
			}
			instructions.addAll(block.instructions);
		}

		new Peephole2Optimization<>(instructions) {
			@Override
			protected void handle(IRInstruction item1, IRInstruction item2) {
				if (item1 instanceof IRJump jump
				    && item2 instanceof IRLabel label
				    && jump.label().equals(label.label())) {
					remove();
				}
			}
		}.process();

		return function.derive(instructions);
	}
}
