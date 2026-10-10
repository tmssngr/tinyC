package com.regnis.tinyc.ir.cfg;

import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class VarLiveness {
	private final Map<String, Block> nameToBlockLiveness;

	VarLiveness(@NotNull Map<String, Block> nameToBlockLiveness) {
		this.nameToBlockLiveness = nameToBlockLiveness;
	}

	@NotNull
	public Block get(@NotNull String name) {
		return nameToBlockLiveness.get(name);
	}

	public static final class Block {

		private final Liveness[] instructionLivenesses;
		private Liveness live = new Liveness(Set.of(), Set.of(), Set.of());

		Block(@NotNull BasicBlock block) {
			this.instructionLivenesses = new Liveness[block.instructions().size()];
		}

		@NotNull
		public Set<IRVar> getLiveBefore() {
			return Collections.unmodifiableSet(live.liveBefore());
		}

		@NotNull
		public Set<IRVar> getLiveAfter() {
			return Collections.unmodifiableSet(live.liveAfter());
		}

		@NotNull
		public Set<IRVar> getLiveAfter(int index) {
			return Collections.unmodifiableSet(instructionLivenesses[index]
					                                   .liveAfter());
		}

		boolean setLive(int index, @NotNull Set<IRVar> uses, @NotNull Set<IRVar> defines, @NotNull Set<IRVar> live) {
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

		void setLive(@NotNull Set<IRVar> liveBefore, @NotNull Set<IRVar> liveAfter) {
			this.live = new Liveness(Set.copyOf(liveBefore), Set.copyOf(liveAfter), Set.of());
		}
	}

	private record Liveness(@NotNull Set<IRVar> liveBefore, @NotNull Set<IRVar> liveAfter, @NotNull Set<IRVar> others) {
	}
}
