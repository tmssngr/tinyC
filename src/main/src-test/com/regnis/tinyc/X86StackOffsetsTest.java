package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.junit.*;

import static org.junit.Assert.*;

/**
 * @author Thomas Singer
 */
public class X86StackOffsetsTest {

	@Test
	public void testNoVars() {
		X86StackOffsets offsets = X86StackOffsets.createWindowsInstance(List.of(), List.of(), 4, 0);
		assertEquals(8, offsets.getRspOffset());

		offsets = X86StackOffsets.createWindowsInstance(List.of(), List.of(), 4, 1);
		assertEquals(0, offsets.getRspOffset());
		assertEquals(0, offsets.getCallArgSpace());
	}

	@Test
	public void testLocalVars() {
		final IRVar a = new IRVar("a", 0, VariableScope.function, Type.I16);
		final IRVar b = new IRVar("b", 1, VariableScope.function, Type.I16);

		X86StackOffsets offsets = X86StackOffsets.createWindowsInstance(List.of(
				new IRVarDef(a, 2)
		), List.of(), 4, 0);
		assertEquals(8, offsets.getRspOffset());
		assertEquals(0, offsets.getCallArgSpace());
		assertEquals(0, offsets.getOffset(a));

		// 2 vars
		offsets = X86StackOffsets.createWindowsInstance(List.of(
				new IRVarDef(a, 2),
				new IRVarDef(b, 2)
		), List.of(), 4, 0);
		assertEquals(8, offsets.getRspOffset());
		assertEquals(0, offsets.getCallArgSpace());
		assertEquals(0, offsets.getOffset(a));
		assertEquals(2, offsets.getOffset(b));
	}

	@Test
	public void testArgs() {
		final IRVar arg1 = new IRVar("a1", 0, VariableScope.parameter, Type.I16);
		final IRVar arg2 = new IRVar("a2", 1, VariableScope.parameter, Type.I16);

		X86StackOffsets offsets = X86StackOffsets.createWindowsInstance(List.of(
				new IRVarDef(arg1, 2)
		), List.of(), 4, 0);
		assertEquals(8, offsets.getRspOffset());
		assertEquals(0, offsets.getCallArgSpace());
		assertEquals(16, offsets.getOffset(arg1));

		// 2 args
		offsets = X86StackOffsets.createWindowsInstance(List.of(
				new IRVarDef(arg1, 2),
				new IRVarDef(arg2, 2)
		), List.of(), 4, 0);
		assertEquals(8, offsets.getRspOffset());
		assertEquals(0, offsets.getCallArgSpace());
		assertEquals(16, offsets.getOffset(arg1));
		assertEquals(24, offsets.getOffset(arg2));
	}

	@Test
	public void testCallArgs() {
		X86StackOffsets offsets = X86StackOffsets.createWindowsInstance(List.of(), List.of(
				List.of()
		), 4, 0);
		// -- aligned to 10h
		//  8h return address
		//  8h free space for alignment
		//  0h local vars
		//  0h pushed clobbered non-volatile regs
		// 20h shadow space
		// -- aligned to 10h
		assertEquals(8, offsets.getRspOffset());
		assertEquals(0x20, offsets.getCallArgSpace());

		offsets = X86StackOffsets.createWindowsInstance(List.of(), List.of(
				List.of(
						new IRVar("a", 0, VariableScope.register, Type.U8)
				)
		), 4, 0);
		// -- aligned to 10h
		//  8h return address
		//  8h free space for alignment
		//  0h local vars
		//  0h pushed clobbered non-volatile regs
		// 20h shadow space
		// -- aligned to 10h
		assertEquals(8, offsets.getRspOffset());
		assertEquals(0x20, offsets.getCallArgSpace());

		final IRVar call1Arg1 = new IRVar("c1a1", 0, VariableScope.function, Type.U8);
		offsets = X86StackOffsets.createWindowsInstance(List.of(
				new IRVarDef(call1Arg1, 1)
		), List.of(
				List.of(
						new IRVar("a", 0, VariableScope.register, Type.U8),
						new IRVar("a", 0, VariableScope.register, Type.U8),
						new IRVar("a", 0, VariableScope.register, Type.U8),
						new IRVar("a", 0, VariableScope.register, Type.U8),
						call1Arg1
				)
		), 4, 0);
		// -- aligned to 10h
		//  8h return address
		//  0h free space for alignment
		//  0h local vars
		//  0h pushed clobbered non-volatile regs
		// 28h space for call arguments
		// -- aligned to 10h
		assertEquals(0, offsets.getRspOffset());
		assertEquals(0x28, offsets.getCallArgSpace());
		assertEquals(0x20, offsets.getOffset(call1Arg1));

		final IRVar varC = new IRVar("c", 1, VariableScope.function, Type.I16);
		offsets = X86StackOffsets.createWindowsInstance(List.of(
				new IRVarDef(call1Arg1, 1),
				new IRVarDef(varC, 2)
		), List.of(
				List.of(
						new IRVar("a", 0, VariableScope.register, Type.U8),
						new IRVar("a", 0, VariableScope.register, Type.U8),
						new IRVar("a", 0, VariableScope.register, Type.U8),
						new IRVar("a", 0, VariableScope.register, Type.U8),
						call1Arg1
				)
		), 4, 0);
		// -- aligned to 10h
		//  8h return address
		//  0h free space for alignment
		//  0h local vars
		//  0h pushed clobbered non-volatile regs
		// 28h space for call arguments
		// -- aligned to 10h
		assertEquals(16, offsets.getRspOffset());
		assertEquals(0x28, offsets.getCallArgSpace());
		assertEquals(0x20, offsets.getOffset(call1Arg1));
		assertEquals(0x28, offsets.getOffset(varC));
	}
}