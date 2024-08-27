package com.regnis.tinyc.cfg;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class BasicBlock {
	public final String name;
	public final List<IRInstruction> instructions;
	public final List<String> predecessors;
	public final List<String> successors;
	private final Map<IRInstruction, Liveness> instructionToLiveness = new HashMap<>();

	private Liveness live = new Liveness(Set.of(), Set.of(), Set.of());

	public BasicBlock(@NotNull String name,
	                  @NotNull List<IRInstruction> instructions,
	                  @NotNull List<String> predecessors,
	                  @NotNull List<String> successors) {
		for (IRInstruction instruction : instructions) {
			if (instruction instanceof IRLabel) {
				throw new IllegalStateException();
			}
			else if (instruction instanceof IRJump
			         || instruction instanceof IRBranch) {
				Utils.assertTrue(instruction == instructions.getLast());
			}
		}

		if (successors.size() == 1) {
			Utils.assertTrue(instructions.getLast() instanceof IRJump);
		}
		else if (successors.size() == 2) {
			Utils.assertTrue(instructions.getLast() instanceof IRBranch);
		}
		else {
			Utils.assertTrue(successors.isEmpty());
		}
		this.name = name;
		this.instructions = List.copyOf(instructions);
		this.predecessors = List.copyOf(predecessors);
		this.successors = List.copyOf(successors);
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
		       && Objects.equals(instructions, block.instructions)
		       && Objects.equals(predecessors, block.predecessors)
		       && Objects.equals(successors, block.successors)
		       && Objects.equals(instructionToLiveness, block.instructionToLiveness)
		       && Objects.equals(live, block.live);
	}

	@Override
	public int hashCode() {
		return Objects.hash(name, instructions, predecessors, successors, instructionToLiveness, live);
	}

	@NotNull
	public Set<LiveVar> getLiveBefore() {
		return live.liveBefore();
	}

	@NotNull
	public Set<LiveVar> getLiveAfter() {
		return live.liveAfter();
	}

	public void setLive(@NotNull Set<LiveVar> liveBefore, @NotNull Set<LiveVar> liveAfter) {
		this.live = new Liveness(Set.copyOf(liveBefore), Set.copyOf(liveAfter), Set.of());
	}

	@NotNull
	public Set<LiveVar> getLiveBefore(@NotNull IRInstruction instruction) {
		return instructionToLiveness.get(instruction)
				.liveBefore();
	}

	@NotNull
	public Set<LiveVar> getLiveAfter(@NotNull IRInstruction instruction) {
		return instructionToLiveness.get(instruction)
				.liveAfter();
	}

	@NotNull
	public Set<LiveVar> getLastUsed(@NotNull IRInstruction instruction) {
		return instructionToLiveness.get(instruction)
				.others;
	}

	public boolean setLive(Set<LiveVar> live, Set<LiveVar> uses, Set<LiveVar> defines, IRInstruction instruction) {
		final Set<LiveVar> liveAfter = Set.copyOf(live);

		final Set<LiveVar> lastUsed = new HashSet<>();
		live.removeAll(defines);
		for (LiveVar use : uses) {
			if (live.add(use)) {
				lastUsed.add(use);
			}
		}
		final Liveness prevLiveness = instructionToLiveness.get(instruction);
		final Set<LiveVar> prevLiveAfter = prevLiveness != null ? prevLiveness.liveAfter : null;
		final Liveness liveness = new Liveness(Set.copyOf(live), liveAfter, Set.copyOf(lastUsed));
		instructionToLiveness.put(instruction, liveness);
		return !liveAfter.equals(prevLiveAfter);
	}

	public record Liveness(@NotNull Set<LiveVar> liveBefore, @NotNull Set<LiveVar> liveAfter, @NotNull Set<LiveVar> others) {
	}
}
