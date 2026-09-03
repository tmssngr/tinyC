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

	public static Z8StackOffsets createInstance(@NotNull List<IRVarDef> localVars, @NotNull List<List<IRVar>> callsArgs, int pushedNonvolatileRegisterCount, @NotNull LSCallingConventionProvider callingConventionProvider) {
		checkLocalVars(localVars);

		final Map<IRVar, Integer> stackArgToOffset = new HashMap<>();
		final int callArgSpace = determineSpaceForCallArgs(callsArgs, stackArgToOffset, callingConventionProvider);

		//    pushed argument n
		//    pushed argument n + 1
		//  2 return address
		//    local vars
		//    pushed clobbered non-volatile regs
		//    space for call arguments                                           callArgSpace

		final int localVarAreaBegin = callArgSpace + pushedNonvolatileRegisterCount;
		final int[] localVarOffsets = new int[localVars.size()];
		Arrays.fill(localVarOffsets, -1);
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

			localVarOffsets[index] = offset;
			offset += def.size();
		}

		final int returnAddressSize = 2;
		final int argStartOffset = offset + returnAddressSize;

		final List<Type> parameterTypes = localVars.stream()
				.filter(def -> def.var().scope() == VariableScope.parameter)
				.map(def -> def.var().type())
				.toList();
		final LSCallingConvention callingConvention = callingConventionProvider.getCallingConvention(Type.VOID, parameterTypes);
		final List<Integer> argRegisters = callingConvention.argRegisters();
		final int argCountInRegisters = argRegisters.size();

		offset = argStartOffset;
		// argument offsets
		for (IRVarDef def : localVars) {
			final IRVar var = def.var();
			final VariableScope scope = var.scope();
			if (scope != VariableScope.parameter) {
				Utils.assertTrue(scope == VariableScope.function);
				break;
			}

			final int index = var.index();
			if (index < argCountInRegisters) {
				// use negative numbers for register args (r0 -> -1, r1 -> -2, ...) - for logging purposes
				localVarOffsets[index] = -1 - argRegisters.get(index);
				continue;
			}

			localVarOffsets[index] = offset;
			offset += def.size();
		}

		final int rspOffset = argStartOffset - localVarAreaBegin - returnAddressSize;
		return new Z8StackOffsets(callArgSpace, localVarOffsets, rspOffset);
	}

	private final int[] localVarOffsets;
	private final int rspOffset;
	private final int callArgSpace;

	private Z8StackOffsets(int callArgSpace, int[] localVarOffsets, int rspOffset) {
		this.localVarOffsets = localVarOffsets;
		this.callArgSpace = callArgSpace;
		this.rspOffset = rspOffset;
	}

	public int getOffset(@NotNull IRVar var) {
		Utils.assertTrue(var.scope() == VariableScope.parameter
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
				if (def.var().scope() != VariableScope.parameter) {
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

	private static int determineSpaceForCallArgs(List<List<IRVar>> callsArgs, Map<IRVar, Integer> stackArgToOffset, LSCallingConventionProvider callingConventionProvider) {
		// For simplicity we modify the stackoffset only at the begin of a function,
		// not for each call it performs. The longest call argument list defines how
		// much space is reserved.
		int maxOffset = 0;
		for (List<IRVar> callArgs : callsArgs) {
			final List<Type> argumentTypes = callArgs.stream()
					.map(IRVar::type)
					.toList();
			final LSCallingConvention callingConvention = callingConventionProvider.getCallingConvention(Type.VOID, argumentTypes);
			final int argsInRegisters = callingConvention.argRegisters().size();
			int offset = 0;
			for (int i = 0; i < callArgs.size(); i++) {
				final IRVar var = callArgs.get(i);
				if (i < argsInRegisters) {
					Utils.assertTrue(var.scope() == VariableScope.register);
					continue;
				}

				Utils.assertTrue(var.scope() == VariableScope.function);
				Utils.assertTrue(!stackArgToOffset.containsKey(var), "each stack-arg var only is allowed to be used one time");
				stackArgToOffset.put(var, offset);
				final int size = Type.getSize(var.type(), Z8CallingConventionProvider.POINTER_INT_TYPE);
				offset += size;
			}
			maxOffset = Math.max(maxOffset, offset);
		}
		return maxOffset;
	}
}
