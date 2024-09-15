package com.regnis.tinyc.cfg;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;
import org.junit.*;

import static org.junit.Assert.assertEquals;

/**
 * @author Thomas Singer
 */
public class LinearScanRegisterAllocationTest {

	private static final Location LOCATION = Location.DUMMY;

	@Test
	public void testPrintChar() {
		assertEquals(List.of(
				new IRAddrOf(reg(0, Type.POINTER_U8),
				             new IRVar("chr", 0, VariableScope.argument, Type.U8, true),
				             LOCATION),
				new IRLiteral(reg(1, Type.I64),
				              1,
				              LOCATION),
				new IRCall(null, "printStringLength",
				           List.of(
						           reg(0, Type.POINTER_U8),
						           reg(1, Type.I64)
				           ),
				           LOCATION)
		), allocate(List.of(
				new IRAddrOf(tmp(1, Type.POINTER_U8),
				             new IRVar("chr", 0, VariableScope.argument, Type.U8, true),
				             LOCATION),
				new IRLiteral(tmp(2, Type.I64),
				              1,
				              LOCATION),
				new IRCall(null, "printStringLength",
				           List.of(
						           tmp(1, Type.POINTER_U8),
						           tmp(2, Type.I64)
				           ),
				           LOCATION)
		)));
	}

	@Test
	public void testPrintUint_while_1_break() {
		assertEquals(List.of(
				new IRCopy(reg(0, Type.U8),
				           new IRVar("pos", 2, VariableScope.function, Type.U8, true),
				           LOCATION),
				new IRCast(reg(1, Type.I64),
				           reg(0, Type.U8),
				           LOCATION),
				new IRAddrOfArray(reg(1, Type.POINTER_U8),
				                  new IRVar("buffer", 1, VariableScope.function, Type.POINTER_U8, false),
				                  reg(1, Type.I64),
				                  true, LOCATION),
				new IRLiteral(reg(2, Type.U8), 0x20, LOCATION),
				new IRBinary(reg(0, Type.U8),
				             IRBinary.Op.Sub,
				             reg(2, Type.U8),
				             reg(0, Type.U8),
				             LOCATION),
				new IRCast(reg(0, Type.I64),
				           reg(0, Type.U8),
				           LOCATION),
				new IRCall(null, "printStringLength",
				           List.of(reg(1, Type.POINTER_U8), reg(0, Type.I64)),
				           LOCATION)
		), allocate(List.of(
				new IRCast(tmp(15, Type.I64),
				           new IRVar("pos", 2, VariableScope.function, Type.U8, true),
				           LOCATION),
				new IRAddrOfArray(tmp(14, Type.POINTER_U8),
				                  new IRVar("buffer", 1, VariableScope.function, Type.POINTER_U8, false),
				                  tmp(15, Type.I64),
				                  true, LOCATION),
				new IRLiteral(tmp(18, Type.U8), 0x20, LOCATION),
				new IRBinary(tmp(17, Type.U8),
				             IRBinary.Op.Sub,
				             tmp(18, Type.U8),
				             new IRVar("pos", 2, VariableScope.function, Type.U8, true),
				             LOCATION),
				new IRCast(tmp(16, Type.I64),
				           tmp(17, Type.U8),
				           LOCATION),
				new IRCall(null, "printStringLength",
				           List.of(tmp(14, Type.POINTER_U8), tmp(16, Type.I64)),
				           LOCATION)
		)));
	}

	@NotNull
	private static IRVar reg(int index, Type type) {
		return new IRVar("r." + index, index, VariableScope.register, type, true);
	}

	@NotNull
	private static IRVar tmp(int index, Type type) {
		return new IRVar("t." + index, index, VariableScope.function, type, true);
	}

	private static List<IRInstruction> allocate(List<IRInstruction> instructions) {
		final BasicBlock block = new BasicBlock("name", instructions, List.of(), List.of());
		DetectVarLiveness.processBlock(block, Set.of());
		final LinearScanRegisterAllocation allocation = new LinearScanRegisterAllocation(block, 4);
		return allocation.process().instructions;
	}
}