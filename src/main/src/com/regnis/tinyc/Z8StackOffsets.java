package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;
import com.regnis.tinyc.linearscanregalloc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class Z8StackOffsets {

	private final int[] localVarOffsets;
	private final int localVarsSize;

	public Z8StackOffsets(@NotNull List<IRVarDef> varDefs, int nonvolatileRegistersToPushPopCount, @NotNull LSTypeRegisterCountProvider typeRegisterCountProvider) {
		// n-th argument
		// (n+1)th argument
		// return address
		// - " -
		// local var 0
		// local var 1
		// ...
		// top of stack

		// note, that multi-byte arguments are stored MSB first, which means they are on the stash as LSB, MSB

		localVarOffsets = new int[varDefs.size()];

		// first, we calculate the offsets from the end
		int offset = 0;
		int firstLocalVarOffset = -1;

		int expectedIndex = 0;
		for (IRVarDef varDef : varDefs) {
			final IRVar var = varDef.var();
			final int index = var.index();
			Utils.assertTrue(index == expectedIndex);
			expectedIndex++;
			if (firstLocalVarOffset < 0 && var.scope() == VariableScope.function) {
				// fix for the return address
				offset += 2;
				// and the pushed non-volatile registers
				offset += nonvolatileRegistersToPushPopCount;
				firstLocalVarOffset = offset;
			}
			localVarOffsets[index] = offset;
			offset += typeRegisterCountProvider.registerCount(var.type());
		}

		if (firstLocalVarOffset < 0) {
			// fix for the return address
			offset += 2;
			// and the pushed non-volatile registers
			offset += nonvolatileRegistersToPushPopCount;
			firstLocalVarOffset = offset;
		}

		// then we correct the indices
		for (int i = 0; i < localVarOffsets.length; i++) {
			localVarOffsets[i] = offset - localVarOffsets[i] - 1;
		}

		localVarsSize = offset - firstLocalVarOffset;
	}

	public int getOffset(@NotNull IRVar var) {
		Utils.assertTrue(var.scope() == VariableScope.argument
		                 || var.scope() == VariableScope.function);
		return localVarOffsets[var.index()];
	}

	public int getLocalVarsSize() {
		return localVarsSize;
	}
}
