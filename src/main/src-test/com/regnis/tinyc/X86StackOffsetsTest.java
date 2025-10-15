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
		X86StackOffsets offsets = new X86StackOffsets(List.of(), List.of(), 0);
		assertEquals(8, offsets.getRspOffset());

		offsets = new X86StackOffsets(List.of(), List.of(), 1);
		assertEquals(0, offsets.getRspOffset());
		assertEquals(0, offsets.getCallArgSpace());
	}

	@Test
	public void testLocalVars() {
		final IRVar a = new IRVar("a", 0, VariableScope.function, Type.I16);
		final IRVar b = new IRVar("b", 1, VariableScope.function, Type.I16);

		X86StackOffsets offsets = new X86StackOffsets(List.of(
				new IRVarDef(a, 2)
		), List.of(), 0);
		assertEquals(8, offsets.getRspOffset());
		assertEquals(0, offsets.getCallArgSpace());
		assertEquals(0, offsets.getOffset(a));

		// 2 vars
		offsets = new X86StackOffsets(List.of(
				new IRVarDef(a, 2),
				new IRVarDef(b, 2)
		), List.of(), 0);
		assertEquals(8, offsets.getRspOffset());
		assertEquals(0, offsets.getCallArgSpace());
		assertEquals(0, offsets.getOffset(a));
		assertEquals(2, offsets.getOffset(b));
	}

	@Test
	public void testArgs() {
		final IRVar a = new IRVar("a", 0, VariableScope.argument, Type.I16);
		final IRVar b = new IRVar("b", 1, VariableScope.argument, Type.I16);

		X86StackOffsets offsets = new X86StackOffsets(List.of(
				new IRVarDef(a, 2)
		), List.of(), 0);
		assertEquals(8, offsets.getRspOffset());
		assertEquals(0, offsets.getCallArgSpace());
		assertEquals(16, offsets.getOffset(a));

		// 2 vars
		offsets = new X86StackOffsets(List.of(
				new IRVarDef(a, 2),
				new IRVarDef(b, 2)
		), List.of(), 0);
		assertEquals(8, offsets.getRspOffset());
		assertEquals(0, offsets.getCallArgSpace());
		assertEquals(16, offsets.getOffset(a));
		assertEquals(24, offsets.getOffset(b));
	}

	@Test
	public void testCallArgs() {
		// -- aligned to 10h
		//  8h return address
		//  8h free space for alignment
		//  0h local vars
		//  0h pushed clobbered non-volatile regs
		// 20h space for call arguments
		// -- aligned to 10h
		X86StackOffsets offsets = new X86StackOffsets(List.of(), List.of(
				List.of(
						new IRVar("a", 0, VariableScope.register, Type.U8),
						new IRVar("a", 0, VariableScope.register, Type.U8),
						new IRVar("a", 0, VariableScope.register, Type.U8),
						new IRVar("a", 0, VariableScope.register, Type.U8)
				)
		), 0);
		assertEquals(8, offsets.getRspOffset());
		assertEquals(0x20, offsets.getCallArgSpace());

		final IRVar varB = new IRVar("b", 0, VariableScope.function, Type.U8);
		// -- aligned to 10h
		//  8h return address
		//  0h free space for alignment
		//  0h local vars
		//  0h pushed clobbered non-volatile regs
		// 28h space for call arguments
		// -- aligned to 10h
		offsets = new X86StackOffsets(List.of(
				new IRVarDef(varB, 1)
		), List.of(
				List.of(
						new IRVar("a", 0, VariableScope.register, Type.U8),
						new IRVar("a", 0, VariableScope.register, Type.U8),
						new IRVar("a", 0, VariableScope.register, Type.U8),
						new IRVar("a", 0, VariableScope.register, Type.U8),
						varB
				)
		), 0);
		assertEquals(0, offsets.getRspOffset());
		assertEquals(0x28, offsets.getCallArgSpace());
		assertEquals(0x20, offsets.getOffset(varB));

		final IRVar varC = new IRVar("c", 1, VariableScope.function, Type.I16);
		// -- aligned to 10h
		//  8h return address
		//  8h free space for alignment
		//  8h local vars
		//  0h pushed clobbered non-volatile regs
		// 28h space for call arguments
		// -- aligned to 10h
		offsets = new X86StackOffsets(List.of(
				new IRVarDef(varB, 1),
				new IRVarDef(varC, 2)
		), List.of(
				List.of(
						new IRVar("a", 0, VariableScope.register, Type.U8),
						new IRVar("a", 0, VariableScope.register, Type.U8),
						new IRVar("a", 0, VariableScope.register, Type.U8),
						new IRVar("a", 0, VariableScope.register, Type.U8),
						varB
				)
		), 0);
		assertEquals(16, offsets.getRspOffset());
		assertEquals(0x28, offsets.getCallArgSpace());
		assertEquals(0x20, offsets.getOffset(varB));
		assertEquals(0x28, offsets.getOffset(varC));
	}
}