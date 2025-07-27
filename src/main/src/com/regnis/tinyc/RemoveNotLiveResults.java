package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.cfg.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

/**
 * @author Thomas Singer
 */
public class RemoveNotLiveResults {
	public static Pair<IRFunction, ControlFlowGraph> run(IRFunction function) {
		while (true) {
			final ControlFlowGraph cfg = CfgGenerator.create(function.name(), function.instructions());
			DetectVarLiveness.process(cfg, function.varInfos().cantBeRegister(), true);

			final RemoveNotLiveResults command = new RemoveNotLiveResults();
			final List<BasicBlock> blocks = cfg.blocks();
			for (BasicBlock block : blocks) {
				if (block.name.startsWith("@")) {
					command.add(new IRLabel(block.name));
				}

				final List<IRInstruction> instructions = block.instructions();
				for (int i = 0; i < instructions.size(); i++) {
					final IRInstruction instruction = instructions.get(i);
					final Set<IRVar> liveAfter = block.getLiveAfter(i);
					command.simplify(instruction, liveAfter);
				}
			}

			if (!command.changed) {
				return new Pair<>(function, cfg);
			}

			function = function.derive(command.instructions);
		}
	}

	private final List<IRInstruction> instructions = new ArrayList<>();

	private boolean changed;

	private RemoveNotLiveResults() {
	}

	private void simplify(IRInstruction instruction, Set<IRVar> live) {
		switch (instruction) {
		case IRAddConst i -> addIfIsLive(i.var(), i, live);
		case IRAddrOf i -> addIfIsLive(i.target(), i, live);
		case IRAddrOfArray i -> addIfIsLive(i.addr(), i, live);
		case IRBinary i -> addIfIsLive(i.target(), i, live);
		case IRBranch i -> add(i);
		case IRCall i -> {
			final IRVar target = i.target();
			if (target != null && !isLive(target, live)) {
				add(new IRCall(null, i.type(), i.name(), i.args(), i.location()));
				changed = true;
			}
			else {
				add(i);
			}
		}
		case IRCast i -> addIfIsLive(i.target(), i, live);
		case IRComment i -> add(i);
		case IRCompare i -> addIfIsLive(i.target(), i, live);
		case IRCompareConst i -> addIfIsLive(i.target(), i, live);
		case IRJump i -> add(i);
		case IRLiteral i -> addIfIsLive(i.target(), i, live);
		case IRMemLoad i -> addIfIsLive(i.target(), i, live);
		case IRMemStore i -> add(i);
		case IRMove i -> addIfIsLive(i.target(), i, live);
		case IRRetValue i -> add(i);
		case IRString i -> addIfIsLive(i.target(), i, live);
		case IRUnary i -> addIfIsLive(i.target(), i, live);
		default -> throw new UnsupportedOperationException(instruction.getClass().toString());
		}
	}

	private void add(IRInstruction instruction) {
		instructions.add(instruction);
	}

	private void addIfIsLive(IRVar target, IRInstruction instruction, Set<IRVar> live) {
		if (isLive(target, live)) {
			add(instruction);
		}
		else {
			changed = true;
		}
	}

	private boolean isLive(IRVar var, Set<IRVar> live) {
		Utils.assertTrue(var.scope() != VariableScope.register);
		return var.scope() == VariableScope.global || live.contains(var);
	}
}
