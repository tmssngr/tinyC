package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class X86StackOffsets {

	public static X86StackOffsets createWindowsInstance(@NotNull List<IRVarDef> localVars, @NotNull List<List<IRVar>> callsArgs, int argCountInRegisters, int pushedNonvolatileRegisterCount) {
		checkLocalVars(localVars);

		final Map<IRVar, Integer> stackArgToOffset = new HashMap<>();
		final int callArgSpace = determineSpaceForCallArgs(callsArgs, argCountInRegisters, true, stackArgToOffset);

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
		final int[] localVarOffsets = new int[localVars.size()];
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

		final int rspOffset = argStartOffset - localVarAreaBegin - returnAddressSize;
		return new X86StackOffsets(callArgSpace, localVarOffsets, rspOffset);
	}

	public static X86StackOffsets createLinuxInstance(@NotNull List<IRVarDef> localVars, @NotNull List<List<IRVar>> callsArgs, int argCountInRegisters, int pushedNonvolatileRegisterCount) {
		checkLocalVars(localVars);

		final Map<IRVar, Integer> stackArgToOffset = new HashMap<>();
		final int callArgSpace = determineSpaceForCallArgs(callsArgs, argCountInRegisters, false, stackArgToOffset);

		//  8h 6th argument
		//  8h 5th argument
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
		final int[] localVarOffsets = new int[localVars.size()];
		int offset = localVarAreaBegin;
		// local vars
		for (IRVarDef def : localVars) {
			final IRVar var = def.var();
			if (var.scope() == VariableScope.argument) {
				if (var.index() >= argCountInRegisters) {
					continue;
				}
			}
			else if (var.scope() != VariableScope.function) {
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

		final int rspOffset = argStartOffset - localVarAreaBegin - returnAddressSize;
		return new X86StackOffsets(callArgSpace, localVarOffsets, rspOffset);
	}

	private final int[] localVarOffsets;
	private final int rspOffset;
	private final int callArgSpace;

	private X86StackOffsets(int callArgSpace, int[] localVarOffsets, int rspOffset) {
		this.localVarOffsets = localVarOffsets;
		this.callArgSpace = callArgSpace;
		this.rspOffset = rspOffset;
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

	private static void checkLocalVars(@NotNull List<IRVarDef> localVars) {
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

	private static int determineSpaceForCallArgs(List<List<IRVar>> callsArgs, int argCountInRegisters, boolean isWindows, Map<IRVar, Integer> stackArgToOffset) {
		// For simplicity we modify the stackoffset only at the begin of a function,
		// not for each call it performs. The longest call argument list defines how
		// much space is reserved. This is not the most space-efficient solution, but
		// for X86 this does not matter.
		int maxOffset = 0;
		for (List<IRVar> callArgs : callsArgs) {
			int offset = 0x20;
			for (int i = 0; i < callArgs.size(); i++) {
				final IRVar var = callArgs.get(i);
				if (i < argCountInRegisters) {
					Utils.assertTrue(var.scope() == VariableScope.register);
					continue;
				}

				if (var.scope() != VariableScope.function) {
					throw new IllegalStateException("");
				}
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
