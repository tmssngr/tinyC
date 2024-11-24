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
		final IRVar chr = new IRVar("chr", 0, VariableScope.argument, Type.U8);
		final IRVar t1 = tmp(1, Type.POINTER_U8);
		final IRVar t2 = tmp(2, Type.I64);
		assertEquals(List.of(
				addrOf(reg(0, t1), chr),
				literal(reg(1, t2), 1),
				new IRCall(null, "printStringLength",
				           List.of(reg(0, t1), reg(1, t2)),
				           LOCATION)
		), allocate(List.of(
				addrOf(t1, chr),
				literal(t2, 1),
				new IRCall(null, "printStringLength",
				           List.of(t1, t2),
				           LOCATION)
		), Set.of(), 4, false));
	}

	@Test
	public void testPrintUint_while_1_break() {
		final IRVar pos = new IRVar("pos", 2, VariableScope.function, Type.U8);
		final IRVar buffer = new IRVar("buffer", 1, VariableScope.function, Type.POINTER_U8);
		final IRVar t14 = tmp(14, Type.POINTER_U8);
		final IRVar t15 = tmp(15, Type.I64);
		final IRVar t16 = tmp(16, Type.I64);
		final IRVar t17 = tmp(17, Type.U8);
		final IRVar t18 = tmp(18, Type.U8);
		assertEquals(List.of(
				new IRAddrOfArray(reg(0, t14),
				                  buffer,
				                  LOCATION),
				literal(reg(1, t18), 0x20),
				copy(reg(2, pos), pos),
				sub(reg(1, t17), reg(1, t18), reg(2, pos)),
				cast(reg(1, t16), reg(1, t17)),
				new IRCall(null, "printStringLength",
				           List.of(reg(0, t14), reg(1, t16)),
				           LOCATION)
		), allocate(List.of(
				new IRAddrOfArray(t14,
				                  buffer,
				                  LOCATION),
				literal(t18, 0x20),
				sub(t17, t18, pos),
				cast(t16, t17),
				new IRCall(null, "printStringLength",
				           List.of(t14, t16),
				           LOCATION)
		), Set.of(buffer), 4, false));
	}

	@Test
	public void testSpilling() {
		final IRVar t0 = tmp(0, Type.I16);
		final IRVar t1 = tmp(1, Type.I16);
		final IRVar t2 = tmp(2, Type.I16);
		final IRVar t3 = tmp(3, Type.I16);
		final IRVar t4 = tmp(4, Type.I16);
		final IRVar t5 = tmp(5, Type.I16);
		assertEquals(List.of(
				__dbg__(null, null, null, null),
				literal(reg(0, t0), 10),
				__dbg__(t0, null, null, null),
				literal(reg(1, t1), 3),
				__dbg__(t0, t1, null, null),
				add(reg(2, t2), reg(0, t0), reg(1, t1)),
				__dbg__(t0, t1, t2, null),
				sub(reg(3, t3), reg(0, t0), reg(1, t1)),
				__dbg__(t0, t1, t2, t3),
				new IRComment("Spill t.0"),
				copy(t0, reg(0, t0)),
				__dbg__(null, t1, t2, t3),
				add(reg(0, t4), reg(2, t2), reg(3, t3)),
				__dbg__(t4, t1, t2, t3),
				new IRComment("Spill t.4"),
				copy(t4, reg(0, t4)),
				__dbg__(null, t1, t2, t3),
				copy(reg(0, t0), t0),
				sub(reg(0, t5), reg(0, t0), reg(1, t1)),
				__dbg__(t5, null, t2, t3),
				new IRCall(null, "print",
				           List.of(reg(2, t2),
				                   reg(3, t3),
				                   t4,
				                   reg(0, t5)),
				           LOCATION),
				__dbg__(null, null, null, null)
		), allocate(List.of(
				literal(t0, 10),
				// t0
				literal(t1, 3),
				// t0, t1
				add(t2, t0, t1),
				// t0, t1, t2
				sub(t3, t0, t1),
				// t0, t1, t2, t3
				add(t4, t2, t3),
				// t0, t1, t2, t3, t4
				sub(t5, t0, t1),
				// t2, t3, t4, t5
				new IRCall(null, "print",
				           List.of(t2, t3, t4, t5),
				           LOCATION)
		), Set.of(), 4, true));
	}

	private static List<IRInstruction> allocate(List<IRInstruction> instructions, Set<IRVar> cantBeRegister, int maxRegisters, boolean setProduceDebugInstructions) {
		final BasicBlock block = new BasicBlock("name", instructions, List.of(), List.of());
		DetectVarLiveness.processBlock(block, Set.of());
		final LinearScanRegisterAllocation allocation = new LinearScanRegisterAllocation(block,
		                                                                                 var -> !cantBeRegister.contains(var),
		                                                                                 maxRegisters);
		if (setProduceDebugInstructions) {
			allocation.setProduceDebugInstructions();
		}
		return allocation.process().instructions();
	}

	@NotNull
	private static IRDebugComment __dbg__(IRVar... debugInfos) {
		return new IRDebugComment(Arrays.asList(debugInfos));
	}

	@NotNull
	private static IRCast cast(IRVar target, IRVar source) {
		return new IRCast(target, source, LOCATION);
	}

	@NotNull
	private static IRAddrOf addrOf(IRVar target, IRVar source) {
		return new IRAddrOf(target, source, LOCATION);
	}

	@NotNull
	private static IRLiteral literal(IRVar var, int value) {
		return new IRLiteral(var, value, LOCATION);
	}

	@NotNull
	private static IRVar reg(int index, IRVar var) {
		return var.asRegister(index);
	}

	@NotNull
	private static IRVar tmp(int index, Type type) {
		return new IRVar("t." + index, index, VariableScope.function, type);
	}

	@NotNull
	private static IRMove copy(IRVar target, IRVar source) {
		return new IRMove(target, source, LOCATION);
	}

	@NotNull
	private static IRBinary sub(IRVar target, IRVar left, IRVar right) {
		return new IRBinary(target,
		                    IRBinary.Op.Sub,
		                    left,
		                    right,
		                    LOCATION);
	}

	@NotNull
	private static IRBinary add(IRVar target, IRVar left, IRVar right) {
		return new IRBinary(target,
		                    IRBinary.Op.Add,
		                    left,
		                    right,
		                    LOCATION);
	}
}