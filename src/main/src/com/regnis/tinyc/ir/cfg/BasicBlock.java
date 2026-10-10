package com.regnis.tinyc.ir.cfg;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class BasicBlock {

	public static final List<IRInstruction> TEST_DUMMY_INSTRUCTIONS = List.of();

	public final String name;
	private final IRInstruction[] instructions;
	private final List<String> predecessors;
	private final List<String> successors;


	public BasicBlock(@NotNull String name,
	                  @NotNull List<IRInstruction> instructions,
	                  @NotNull List<String> predecessors,
	                  @NotNull List<String> successors) {
		checkInstructions(instructions);

		if (instructions != TEST_DUMMY_INSTRUCTIONS) {
			if (successors.size() == 1) {
				Utils.assertTrue(instructions.getLast() instanceof IRJump);
			}
			else if (successors.size() == 2) {
				final IRInstruction secondLastInstr = instructions.get(instructions.size() - 2);
				Utils.assertTrue(secondLastInstr instanceof IRBranch);
				Utils.assertTrue(instructions.getLast() instanceof IRJump);
			}
			else {
				Utils.assertTrue(successors.isEmpty());
			}
		}
		this.name = name;
		this.instructions = instructions.toArray(new IRInstruction[0]);
		this.predecessors = new ArrayList<>(predecessors);
		this.successors = new ArrayList<>(successors);
	}

	@Override
	public String toString() {
		return name;
	}

	@Override
	public boolean equals(Object o) {
		if (this == o) {
			return true;
		}
		if (o == null || getClass() != o.getClass()) {
			return false;
		}
		final BasicBlock block = (BasicBlock)o;
		return Objects.equals(name, block.name)
		       && Arrays.equals(instructions, block.instructions)
		       && Objects.equals(predecessors, block.predecessors)
		       && Objects.equals(successors, block.successors);
	}

	@Override
	public int hashCode() {
		return Objects.hash(name, Arrays.hashCode(instructions), predecessors, successors);
	}

	public List<IRInstruction> instructions() {
		return Collections.unmodifiableList(Arrays.asList(instructions));
	}

	public List<String> predecessors() {
		return Collections.unmodifiableList(predecessors);
	}

	public void setPredecessors(List<String> predecessors) {
		Utils.assertTrue(this.predecessors.isEmpty());
		this.predecessors.addAll(predecessors);
	}

	public void replacePredecessor(String from, String to) {
		replace(from, to, predecessors);
	}

	public List<String> successors() {
		return Collections.unmodifiableList(successors);
	}

	public void replaceSuccessor(String from, String to) {
		replace(from, to, successors);
	}

	public void replaceJump(String from, String to) {
		for (int i = instructions.length - 1; i >= 0; i--) {
			final IRInstruction instruction = instructions[i];
			if (instruction instanceof IRJump(String target)) {
				if (target.equals(from)) {
					instructions[i] = new IRJump(to);
				}
			}
			else if (instruction instanceof IRBranch branch) {
				String target = branch.target();
				String nextLabel = branch.nextLabel();
				if (target.equals(from)) {
					target = to;
				}
				if (nextLabel.equals(from)) {
					nextLabel = to;
				}
				instructions[i] = new IRBranch(branch.op(), branch.left(), branch.right(), target, nextLabel);
			}
			else {
				break;
			}
		}
	}

	private void checkInstructions(@NotNull List<IRInstruction> instructions) {
		boolean mustBeJump = false;
		for (IRInstruction instruction : instructions) {
			if (mustBeJump) {
				if (!(instruction instanceof IRJump)) {
					throw new IllegalStateException("expected jump");
				}
			}

			if (instruction instanceof IRLabel) {
				throw new IllegalStateException("labels are not allowed");
			}
			if (instruction instanceof IRBranch) {
				mustBeJump = true;
			}
			else if (instruction instanceof IRJump) {
				Utils.assertTrue(instruction == instructions.getLast());
				mustBeJump = false;
			}
		}
		if (mustBeJump) {
			throw new IllegalStateException("missing jump");
		}
	}

	private static void replace(String from, String to, List<String> list) {
		final int index = list.indexOf(from);
		Utils.assertTrue(index >= 0);
		list.set(index, to);
	}
}
