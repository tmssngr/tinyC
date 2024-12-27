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
		X86StackOffsets offsets = new X86StackOffsets(List.of(), 0);
		assertEquals(8, offsets.getRspOffset());

		offsets = new X86StackOffsets(List.of(), 1);
		assertEquals(0, offsets.getRspOffset());
	}

	@Test
	public void testLocalVars() {
		final IRVar a = new IRVar("a", 0, VariableScope.function, Type.I16);
		final IRVar b = new IRVar("b", 1, VariableScope.function, Type.I16);

		X86StackOffsets offsets = new X86StackOffsets(List.of(
				new IRVarDef(a, 2)
		), 0);
		assertEquals(8, offsets.getRspOffset());
		assertEquals(0, offsets.getOffset(a));

		// 2 vars
		offsets = new X86StackOffsets(List.of(
				new IRVarDef(a, 2),
				new IRVarDef(b, 2)
		), 0);
		assertEquals(8, offsets.getRspOffset());
		assertEquals(0, offsets.getOffset(a));
		assertEquals(2, offsets.getOffset(b));
	}

	@Test
	public void testArgs() {
		final IRVar a = new IRVar("a", 0, VariableScope.argument, Type.I16);
		final IRVar b = new IRVar("b", 1, VariableScope.argument, Type.I16);

		X86StackOffsets offsets = new X86StackOffsets(List.of(
				new IRVarDef(a, 2)
		), 0);
		assertEquals(8, offsets.getRspOffset());
		assertEquals(16, offsets.getOffset(a));

		// 2 vars
		offsets = new X86StackOffsets(List.of(
				new IRVarDef(a, 2),
				new IRVarDef(b, 2)
		), 0);
		assertEquals(8, offsets.getRspOffset());
		assertEquals(16, offsets.getOffset(a));
		assertEquals(24, offsets.getOffset(b));
	}
}