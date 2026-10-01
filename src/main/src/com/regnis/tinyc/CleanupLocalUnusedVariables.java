package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;
import com.regnis.tinyc.linearscanregalloc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public class CleanupLocalUnusedVariables {

	private final LSArchitecture architecture;

	public CleanupLocalUnusedVariables(@NotNull LSArchitecture architecture) {
		this.architecture = architecture;
	}

	public IRFunction process(IRFunction function) {
		final Set<Integer> usedFunctionVars = collectUsedVars(function.instructions());

		final LocalVarReplacer replacer = new LocalVarReplacer(function.varInfos(), usedFunctionVars);

		final List<IRInstruction> instructions = new ArrayList<>();
		for (IRInstruction instruction : function.instructions()) {
			instructions.add(replacer.replaceFor(instruction));
		}

		final ListIterator<IRInstruction> listIterator = instructions.listIterator(instructions.size());
		final TrivialLiveTracker liveTracker = new TrivialLiveTracker(architecture);
		while (listIterator.hasPrevious()) {
			final IRInstruction instruction = listIterator.previous();
			if (!liveTracker.process(instruction)) {
				listIterator.remove();
			}
		}

		return new IRFunction(function.name(), function.returnType(), replacer.newVarInfos, instructions);
	}

	private Set<Integer> collectUsedVars(List<IRInstruction> instructions) {
		final Set<Integer> usedFunctionVars = new HashSet<>();
		final VarUseTracker varUseTracker = new VarUseTracker(new VarUseTracker.Handler() {
			@Override
			public void read(@NotNull IRVar var) {
				written(var);
			}

			@Override
			public void written(@NotNull IRVar var) {
				if (var.scope() == VariableScope.function) {
					usedFunctionVars.add(var.index());
				}
			}
		});

		varUseTracker.process(instructions);

		return usedFunctionVars;
	}

	private static final class TrivialLiveTracker {

		private final boolean[] live;
		private final LSCallingConventionProvider callingConventionProvider;

		public TrivialLiveTracker(@NotNull LSArchitecture architecture) {
			live = new boolean[architecture.registerCount()];
			callingConventionProvider = architecture.getCallingConventionProvider();
			setAllLive();
		}

		@Override
		public String toString() {
			final StringBuilder buffer = new StringBuilder();
			for (boolean b : live) {
				buffer.append(b ? '*' : '.');
			}
			return buffer.toString();
		}

		public boolean process(IRInstruction instruction) {
			return switch (instruction) {
				case IRAddrOf i -> {
					if (!isLive(i.target())) {
						yield false;
					}

					setIsLive(i.target(), false);
					yield true;
				}
				case IRBinary i -> {
					if (!isLive(i.target())) {
						yield false;
					}

					setIsLive(i.target(), false);
					setIsLive(i.left(), true);
					setIsLive(i.right());
					yield true;
				}
				case IRBranch i -> {
					setAllLive();
					yield true;
				}
				case IRCall i -> {
					final IRVar target = i.target();
					if (target != null) {
						setIsLive(target, false);
					}
					final LSCallingConvention callingConvention = callingConventionProvider.getCallingConvention(target != null ? target.type() : Type.VOID, i.getArgumentTypes());
					for (int j = 0; j < callingConvention.volatileRegisterCount(); j++) {
						live[j] = true;
					}
					yield true;
				}
				case IRCast i -> {
					if (!isLive(i.target())) {
						yield false;
					}

					setIsLive(i.target(), false);
					setIsLive(i.source(), true);
					yield true;
				}
				case IRComment i -> true;
				case IRCompare i -> {
					if (!isLive(i.target())) {
						yield false;
					}

					setIsLive(i.target(), false);
					setIsLive(i.left(), true);
					setIsLive(i.right());
					yield true;
				}
				case IRJump ignored -> {
					setAllLive();
					yield true;
				}
				case IRLabel ignored -> {
					setAllLive();
					yield true;
				}
				case IRMemLoad i -> {
					if (!isLive(i.target())) {
						yield false;
					}

					setIsLive(i.target(), false);
					setIsLive(i.addr(), true);
					yield true;
				}
				case IRMemStore i -> {
					setIsLive(i.addr(), true);
					setIsLive(i.value(), true);
					yield true;
				}
				case IRMove i -> {
					if (!isLive(i.target())) {
						yield false;
					}

					setIsLive(i.target(), false);
					setIsLive(i.source());
					yield true;
				}
				case IRString i -> {
					if (!isLive(i.target())) {
						yield false;
					}

					setIsLive(i.target(), false);
					yield true;
				}
				case IRUnary i -> {
					if (!isLive(i.target())) {
						yield false;
					}

					setIsLive(i.target(), false);
					setIsLive(i.source(), true);
					yield true;
				}
				default -> throw new IllegalStateException(instruction.toString());
			};
		}

		private boolean isLive(@NotNull IRVar var) {
			Utils.assertTrue(var.scope() == VariableScope.register);
			return live[var.index()];
		}

		private void setIsLive(IRValue value) {
			final IRVar var = value.var();
			if (var != null) {
				setIsLive(var, true);
			}
		}

		private void setIsLive(IRVar var, boolean isLive) {
			Utils.assertTrue(var.scope() == VariableScope.register);
			live[var.index()] = isLive;
		}

		private void setAllLive() {
			Arrays.fill(live, true);
		}
	}

	private static final class LocalVarReplacer extends IRVarReplacer {
		private final Map<IRVar, IRVar> oldToNewVar = new HashMap<>();
		private final IRVarInfos newVarInfos;

		public LocalVarReplacer(IRVarInfos varInfos, Set<Integer> usedFunctionVars) {
			final List<IRVarDef> localVars = varInfos.vars();

			final List<IRVarDef> newLocalVars = new ArrayList<>();
			final Set<IRVar> newCantBeRegister = new HashSet<>();

			int newIndex = 0;
			for (IRVarDef def : localVars) {
				final IRVar var = def.var();
				if (var.scope() == VariableScope.parameter) {
					oldToNewVar.put(var, var);
					newLocalVars.add(def);
					newIndex++;
					continue;
				}

				if (!usedFunctionVars.contains(var.index())) {
					continue;
				}

				final IRVar newVar = new IRVar(var.name(), newIndex, var.scope(), var.type());
				oldToNewVar.put(var, newVar);
				if (!varInfos.canBeRegister(var)) {
					newCantBeRegister.add(newVar);
				}

				newLocalVars.add(new IRVarDef(newVar, def.size(), def.isArray()));

				newIndex++;
			}

			newVarInfos = new IRVarInfos(newLocalVars, newCantBeRegister, Objects.requireNonNull(varInfos.global()));
		}

		@NotNull
		@Override
		protected IRVar replace(@NotNull IRVar var) {
			if (var.scope() != VariableScope.function) {
				return var;
			}

			return oldToNewVar.get(var);
		}
	}
}
