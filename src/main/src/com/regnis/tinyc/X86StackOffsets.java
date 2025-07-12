package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class X86StackOffsets {

	public static final X86StackOffsets DUMMY = new X86StackOffsets(List.of(), 0);

	private final int[] localVarOffsets;
	private final int rspOffset;

	public X86StackOffsets(@NotNull List<IRVarDef> localVars, int pushedNonvolatileRegisterCount) {
		checkLocalVars(localVars);

		//  8h 6th argument
		//  8h 5th argument
		// 20h shadow space
		// -- aligned to 10h
		//  8h return address
		//     unused
		//     local vars
		//     pushed gobbled non-volatile regs
		// -- aligned to 10h

		final int pushOffset = pushedNonvolatileRegisterCount * 8;

		localVarOffsets = new int[localVars.size()];
		int offset = pushOffset;
		// local vars
		for (IRVarDef def : localVars) {
			final IRVar var = def.var();
			if (var.scope() == VariableScope.function) {
				final int varSize = def.size();
				offset = alignTo(offset, varSize);
				final int index = var.index();
				localVarOffsets[index] = offset;
				offset += varSize;
			}
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

		rspOffset = argStartOffset - pushOffset - returnAddressSize;
	}

	public int getOffset(@NotNull IRVar var) {
		Utils.assertTrue(var.scope() == VariableScope.argument
		                 || var.scope() == VariableScope.function);
		return localVarOffsets[var.index()];
	}

	public int getRspOffset() {
		return rspOffset;
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

	private static int alignTo16(int offset) {
		return alignTo(offset, 16);
	}

	private static int alignTo(int offset, int alignment) {
		return (offset + alignment - 1) / alignment * alignment;
	}
}
