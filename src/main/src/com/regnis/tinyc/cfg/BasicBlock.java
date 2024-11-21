package com.regnis.tinyc.cfg;

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
	private final Liveness[] instructionLivenesses;
	private final List<String> predecessors;
	private final List<String> successors;

	private Liveness live = new Liveness(Set.of(), Set.of(), Set.of());

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
				Utils.assertTrue(instructions.get(instructions.size() - 2) instanceof IRBranch);
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
		this.instructionLivenesses = new Liveness[instructions.size()];
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
		       && Objects.equals(successors, block.successors)
		       && Arrays.equals(instructionLivenesses, block.instructionLivenesses)
		       && Objects.equals(live, block.live);
	}

	@Override
	public int hashCode() {
		return Objects.hash(name, Arrays.hashCode(instructions), predecessors, successors, Arrays.hashCode(instructionLivenesses), live);
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

	@NotNull
	public Set<IRVar> getLiveBefore() {
		return live.liveBefore();
	}

	@NotNull
	public Set<IRVar> getLiveAfter() {
		return live.liveAfter();
	}

	public void setLive(@NotNull Set<IRVar> liveBefore, @NotNull Set<IRVar> liveAfter) {
		this.live = new Liveness(Set.copyOf(liveBefore), Set.copyOf(liveAfter), Set.of());
	}

	@NotNull
	public Set<IRVar> getLiveBefore(int index) {
		return instructionLivenesses[index]
				.liveBefore();
	}

	@NotNull
	public Set<IRVar> getLiveAfter(int index) {
		return instructionLivenesses[index]
				.liveAfter();
	}

	@NotNull
	public Set<IRVar> getLastUsed(int index) {
		return instructionLivenesses[index]
				.others;
	}

	public boolean setLive(int index, Set<IRVar> uses, Set<IRVar> defines, Set<IRVar> live) {
		final Set<IRVar> liveAfter = Set.copyOf(live);

		final Set<IRVar> lastUsed = new HashSet<>();
		live.removeAll(defines);
		for (IRVar use : uses) {
			if (live.add(use)) {
				lastUsed.add(use);
			}
		}
		final Liveness prevLiveness = instructionLivenesses[index];
		final Set<IRVar> prevLiveAfter = prevLiveness != null ? prevLiveness.liveAfter : null;
		final Liveness liveness = new Liveness(Set.copyOf(live), liveAfter, Set.copyOf(lastUsed));
		instructionLivenesses[index] = liveness;
		return !liveAfter.equals(prevLiveAfter);
	}

	public void printLiveness() {
		printLiveness(getLiveBefore());
		boolean printLiveBefore = false;
		for (int i = 0; i < instructions.length; i++) {
			final IRInstruction instruction = instructions[i];
			if (printLiveBefore) {
				printLiveness(getLiveBefore(i));
			}
			printLiveBefore = true;
			System.out.println(instruction);
		}
		printLiveness(getLiveAfter());
	}

	public void replaceJump(String from, String to) {
		for (int i = instructions.length - 1; i >= 0; i--) {
			final IRInstruction instruction = instructions[i];
			if (instruction instanceof IRJump jump) {
				if (jump.label().equals(from)) {
					instructions[i] = new IRJump(to);
				}
			}
			else if (instruction instanceof IRBranch branch) {
				if (branch.target().equals(from)) {
					instructions[i] = new IRBranch(branch.conditionVar(), branch.jumpOnTrue(), to, "");
				}
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

	private void printLiveness(Set<IRVar> liveVars) {
		System.out.println("; " + liveVars);
	}

	private static void replace(String from, String to, List<String> list) {
		final int index = list.indexOf(from);
		Utils.assertTrue(index >= 0);
		list.set(index, to);
	}

	public record Liveness(@NotNull Set<IRVar> liveBefore, @NotNull Set<IRVar> liveAfter, @NotNull Set<IRVar> others) {
	}
}
