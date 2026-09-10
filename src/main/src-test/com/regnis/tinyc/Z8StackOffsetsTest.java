package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;
import com.regnis.tinyc.linearscanregalloc.*;

import java.util.*;

import org.jetbrains.annotations.*;
import org.junit.*;

import static org.junit.Assert.assertEquals;

/**
 * @author Thomas Singer
 */
public class Z8StackOffsetsTest {

	@Test
	public void testNoVars() {
		Z8StackOffsets offsets = run(List.of(), List.of(), 0);
		Assert.assertEquals(0, offsets.getRspOffset());

		offsets = run(List.of(), List.of(), 1);
		Assert.assertEquals(0, offsets.getRspOffset());
		Assert.assertEquals(0, offsets.getCallArgSpace());
	}

	@Test
	public void testLocalVars() {
		final IRVar a = new IRVar("a", 0, VariableScope.function, Type.I16);
		final IRVar b = new IRVar("b", 1, VariableScope.function, Type.U8);

		Z8StackOffsets offsets = run(List.of(
				new IRVarDef(a, 2)
		), List.of(), 0);
		Assert.assertEquals(2, offsets.getRspOffset());
		Assert.assertEquals(0, offsets.getCallArgSpace());
		Assert.assertEquals(0, offsets.getOffset(a));

		// 2 vars
		offsets = run(List.of(
				new IRVarDef(a, 2),
				new IRVarDef(b, 1)
		), List.of(), 0);
		Assert.assertEquals(3, offsets.getRspOffset());
		Assert.assertEquals(0, offsets.getCallArgSpace());
		Assert.assertEquals(0, offsets.getOffset(a));
		Assert.assertEquals(2, offsets.getOffset(b));
	}

	@Test
	public void testArgs() {
		final IRVar arg1 = new IRVar("a1", 0, VariableScope.parameter, Type.I16);
		final IRVar arg2 = new IRVar("a2", 1, VariableScope.parameter, Type.I16);
		final IRVar arg3 = new IRVar("a3", 2, VariableScope.parameter, Type.I16);
		final IRVar arg4 = new IRVar("a4", 3, VariableScope.parameter, Type.I16);
		final IRVar arg5 = new IRVar("a5", 4, VariableScope.parameter, Type.I16);
		final IRVar arg6 = new IRVar("a6", 5, VariableScope.parameter, Type.I16);
		final IRVar arg7 = new IRVar("a7", 6, VariableScope.parameter, Type.I16);
		final IRVar arg8 = new IRVar("a8", 7, VariableScope.parameter, Type.I16);
		final IRVar var1 = new IRVar("v1", 8, VariableScope.function, Type.I16);
		final IRVar var2 = new IRVar("v2", 9, VariableScope.function, Type.I16);

		Z8StackOffsets offsets = run(List.of(
				new IRVarDef(arg1, 2)
		), List.of(), 0);
		Assert.assertEquals(0, offsets.getRspOffset());
		Assert.assertEquals(0, offsets.getCallArgSpace());
		Assert.assertEquals(-1, offsets.getOffset(arg1));

		// 2 args
		offsets = run(List.of(
				new IRVarDef(arg1, 2),
				new IRVarDef(arg2, 2)
		), List.of(), 0);
		Assert.assertEquals(0, offsets.getRspOffset());
		Assert.assertEquals(0, offsets.getCallArgSpace());
		Assert.assertEquals(-1, offsets.getOffset(arg1)); // rr0
		Assert.assertEquals(-3, offsets.getOffset(arg2)); // rr2

		// 8 args
		//  8h arg8
		//  8h arg7
		// -- aligned to 10h
		//  8h return address
		//  8h free space for alignment
		//  0h local vars, including arg1..arg6 not stored in registers
		//  0h pushed clobbered non-volatile regs
		// -- aligned to 10h
		offsets = run(List.of(
				new IRVarDef(arg1, 2),
				new IRVarDef(arg2, 2),
				new IRVarDef(arg3, 2),
				new IRVarDef(arg4, 2),
				new IRVarDef(arg5, 2),
				new IRVarDef(arg6, 2),
				new IRVarDef(arg7, 2),
				new IRVarDef(arg8, 2),
				new IRVarDef(var1, 2),
				new IRVarDef(var2, 2)
		), List.of(), 6);
		assertEquals(4, offsets.getRspOffset());
		assertEquals(0, offsets.getCallArgSpace());
		assertEquals(-1, offsets.getOffset(arg1)); // rr0
		assertEquals(-3, offsets.getOffset(arg2)); // rr2
		assertEquals(-5, offsets.getOffset(arg3)); // rr4
		assertEquals(-7, offsets.getOffset(arg4)); // rr6
		assertEquals(12, offsets.getOffset(arg5));
		assertEquals(14, offsets.getOffset(arg6));
		assertEquals(16, offsets.getOffset(arg7));
		assertEquals(18, offsets.getOffset(arg8));
		assertEquals(6, offsets.getOffset(var1));
		assertEquals(8, offsets.getOffset(var2));
	}

	@Test
	public void testCallArgs() {
		Z8StackOffsets offsets = run(List.of(), List.of(
				List.of()
		), 0);
		Assert.assertEquals(0, offsets.getRspOffset());
		Assert.assertEquals(0, offsets.getCallArgSpace());

		offsets = run(List.of(), List.of(
				List.of(
						new IRVar("a", 0, VariableScope.register, Type.U8)
				)
		), 0);
		Assert.assertEquals(0, offsets.getRspOffset());
		Assert.assertEquals(0, offsets.getCallArgSpace());

		final IRVar vI = new IRVar("b", 1, VariableScope.register, Type.I16);
		final IRVar call1Arg1 = new IRVar("c1a1", 0, VariableScope.function, Type.I16);
		offsets = run(List.of(
				new IRVarDef(call1Arg1, 2)
		), List.of(
				List.of(vI, vI, vI, vI, call1Arg1)
		), 0);
		Assert.assertEquals(0, offsets.getRspOffset());
		Assert.assertEquals(2, offsets.getCallArgSpace());
		Assert.assertEquals(0, offsets.getOffset(call1Arg1));

		final IRVar call2Arg1 = new IRVar("c2a1", 1, VariableScope.function, Type.U8);
		final IRVar call2Arg2 = new IRVar("c2a2", 2, VariableScope.function, Type.I16);
		offsets = run(List.of(
				new IRVarDef(call1Arg1, 2),
				new IRVarDef(call2Arg1, 1),
				new IRVarDef(call2Arg2, 2)
		), List.of(
				List.of(vI, vI, vI, vI, call1Arg1),
				List.of(vI, vI, vI, vI, call2Arg1, call2Arg2)
		), 0);
		Assert.assertEquals(0, offsets.getRspOffset());
		Assert.assertEquals(3, offsets.getCallArgSpace());
		Assert.assertEquals(0, offsets.getOffset(call1Arg1));
		Assert.assertEquals(0, offsets.getOffset(call2Arg1));
		Assert.assertEquals(1, offsets.getOffset(call2Arg2));
	}

	@NotNull
	private Z8StackOffsets run(@NotNull List<IRVarDef> localVars, @NotNull List<List<IRVar>> callsArgs, int pushedNonvolatileRegisterCount) {
		return Z8StackOffsets.createInstance(localVars, callsArgs, pushedNonvolatileRegisterCount, Z8CallingConventionProvider.INSTANCE);
	}
}