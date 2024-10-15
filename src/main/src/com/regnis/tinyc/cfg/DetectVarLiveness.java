package com.regnis.tinyc.cfg;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
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

		final List<IRInstruction> instructions = new ArrayList<>(block.instructions());
		Collections.reverse(instructions);
		for (IRInstruction instruction : instructions) {
			final Set<IRVar> uses = new HashSet<>();
			final Set<IRVar> defines = new HashSet<>();
			detectLiveness(instruction, uses, defines);
			if (block.setLive(live, uses, defines, instruction)) {
				changed = true;
			}
		}

		block.setLive(live, liveAfter);
		return changed;
	}

	public static void detectLiveness(IRInstruction instruction, Set<IRVar> uses, Set<IRVar> defines) {
		switch (instruction) {
		case IRAddrOf addrOf -> {
			defined(addrOf.target(), defines);
			uses(addrOf.source(), uses);
		}
		case IRAddrOfArray addrOfArray -> {
			defined(addrOfArray.addr(), defines);
		}
		case IRBinary binary -> {
			defined(binary.target(), defines);
			uses(binary.left(), uses);
			uses(binary.right(), uses);
		}
		case IRCopy copy -> {
			defined(copy.target(), defines);
			uses(copy.source(), uses);
		}
		case IRLiteral literal -> {
			defined(literal.target(), defines);
		}
		case IRCall call -> {
			final IRVar target = call.target();
			if (target != null) {
				defined(target, defines);
			}
			for (IRVar arg : call.args()) {
				uses(arg, uses);
			}
		}
		case IRMemLoad load -> {
			defined(load.target(), defines);
			uses(load.addr(), uses);
		}
		case IRMemStore store -> {
			uses(store.addr(), uses);
			uses(store.value(), uses);
		}
		case IRString string -> {
			defined(string.target(), defines);
		}
		case IRRetValue retValue -> {
			uses(retValue.var(), uses);
		}
		case IRUnary unary -> {
			defined(unary.target(), defines);
			uses(unary.source(), uses);
		}
		case IRCast cast -> {
			defined(cast.target(), defines);
			uses(cast.source(), uses);
		}
		case IRBranch branch -> {
			uses(branch.conditionVar(), uses);
		}
		default -> {
		}
		}
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

	private static void uses(IRVar var, Set<IRVar> uses) {
		Utils.assertTrue(var.scope() != VariableScope.register);
		uses.add(var);
	}

	private static void defined(IRVar var, Set<IRVar> defines) {
		Utils.assertTrue(var.scope() != VariableScope.register);
		defines.add(var);
	}
}
