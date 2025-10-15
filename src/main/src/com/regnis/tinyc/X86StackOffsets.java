package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class X86StackOffsets {

	public static final X86StackOffsets DUMMY = new X86StackOffsets(List.of(), List.of(), 0);

	private final int[] localVarOffsets;
	private final int rspOffset;
	private final int callArgSpace;

	public X86StackOffsets(@NotNull List<IRVarDef> localVars, @NotNull List<List<IRVar>> callsArgs, int pushedNonvolatileRegisterCount) {
		checkLocalVars(localVars);

		final Map<IRVar, Integer> stackArgToOffset = new HashMap<>();
		callArgSpace = determineSpaceForCallArgs(callsArgs, stackArgToOffset);

		//  8h 6th argument
		//  8h 5th argument
		// 20h shadow space (= space for 4 first arguments)
		// -- aligned to 10h
		//  8h return address
		//                                                                                     -,
		//     free space for alignment                                                          > rspOffset
		//     local vars                                                                       |
		//                                                                                     -'
		//     pushed clobbered non-volatile regs
		//     space for call arguments (at least 20h shadow space if only up to 4 arguments)      callArgSpace
		// -- aligned to 10h

		final int localVarAreaBegin = callArgSpace + pushedNonvolatileRegisterCount * 8;

		localVarOffsets = new int[localVars.size()];
		int offset = localVarAreaBegin;
		// local vars
		for (IRVarDef def : localVars) {
			final IRVar var = def.var();
			if (var.scope() != VariableScope.function) {
				continue;
			}

			final int index = var.index();

			final Integer stackArgOffset = stackArgToOffset.get(var);
			if (stackArgOffset != null) {
				localVarOffsets[index] = stackArgOffset;
				continue;
			}

			final int varSize = def.size();
			offset = alignTo(offset, varSize);
			localVarOffsets[index] = offset;
			offset += varSize;
		}

		final int returnAddressSize = 8;
		final int argStartOffset = alignTo16(offset + returnAddressSize);
		// argument offsets
		for (IRVarDef def : localVars) {
			final IRVar var = def.var();
			final VariableScope scope = var.scope();
			if (scope != VariableScope.argument) {
				Utils.assertTrue(scope == VariableScope.function);
				break;
			}

			final int index = var.index();
			localVarOffsets[index] = argStartOffset + index * 8;
		}

		rspOffset = argStartOffset - localVarAreaBegin - returnAddressSize;
	}

	public int getOffset(@NotNull IRVar var) {
		Utils.assertTrue(var.scope() == VariableScope.argument
		                 || var.scope() == VariableScope.function);
		return localVarOffsets[var.index()];
	}

	public int getRspOffset() {
		return rspOffset;
	}

	public int getCallArgSpace() {
		return callArgSpace;
	}

	private void checkLocalVars(@NotNull List<IRVarDef> localVars) {
		int expectedIndex = 0;
		boolean expectLocalVar = false;
		for (IRVarDef def : localVars) {
			if (!expectLocalVar) {
				if (def.var().scope() != VariableScope.argument) {
					expectLocalVar = true;
				}
			}
			if (expectLocalVar) {
				Utils.assertTrue(def.var().scope() == VariableScope.function);
			}
			Utils.assertTrue(def.var().index() == expectedIndex);
			expectedIndex++;
		}
	}

	private int determineSpaceForCallArgs(List<List<IRVar>> callsArgs, Map<IRVar, Integer> stackArgToOffset) {
		// For simplicity we modify the stackoffset only at the begin of a function,
		// not for each call it performs. The longest call argument list defines how
		// much space is reserved. This is not the most space-efficient solution, but
		// for X86 this does not matter.
		int maxOffset = 0;
		for (List<IRVar> callArgs : callsArgs) {
			int offset = 0x20;
			for (int i = 0; i < callArgs.size(); i++) {
				final IRVar var = callArgs.get(i);
				if (i < 4) {
					Utils.assertTrue(var.scope() == VariableScope.register);
					continue;
				}

				Utils.assertTrue(var.scope() == VariableScope.function);
				Utils.assertTrue(!stackArgToOffset.containsKey(var), "each stack-arg var only is allowed to be used one time");
				stackArgToOffset.put(var, offset);
				// everything is 8 bytes large in X86_64
				offset += 8;
			}
			maxOffset = Math.max(maxOffset, offset);
		}
		return maxOffset;
	}

	private static int alignTo16(int offset) {
		return alignTo(offset, 16);
	}

	private static int alignTo(int offset, int alignment) {
		return (offset + alignment - 1) / alignment * alignment;
	}
}
