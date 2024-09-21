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
				addrOf(reg(0, Type.POINTER_U8), new IRVar("chr", 0, VariableScope.argument, Type.U8, true)),
				literal(reg(1, Type.I64), 1),
				new IRCall(null, "printStringLength",
				           List.of(
						           reg(0, Type.POINTER_U8),
						           reg(1, Type.I64)
				           ),
				           LOCATION)
		), allocate(List.of(
				addrOf(tmp(1, Type.POINTER_U8), new IRVar("chr", 0, VariableScope.argument, Type.U8, true)),
				literal(tmpI64(2), 1),
				new IRCall(null, "printStringLength",
				           List.of(
						           tmp(1, Type.POINTER_U8),
						           tmpI64(2)
				           ),
				           LOCATION)
		)));
	}

	@Test
	public void testPrintUint_while_1_break() {
		assertEquals(List.of(
				copy(regU8(0), new IRVar("pos", 2, VariableScope.function, Type.U8, true)),
				cast(reg(1, Type.I64), regU8(0)),
				new IRAddrOfArray(reg(1, Type.POINTER_U8),
				                  new IRVar("buffer", 1, VariableScope.function, Type.POINTER_U8, false),
				                  reg(1, Type.I64),
				                  true, LOCATION),
				literal(regU8(2), 0x20),
				sub(regU8(0), regU8(2), regU8(0)),
				cast(reg(0, Type.I64), regU8(0)),
				new IRCall(null, "printStringLength",
				           List.of(reg(1, Type.POINTER_U8), reg(0, Type.I64)),
				           LOCATION)
		), allocate(List.of(
				cast(tmpI64(15), new IRVar("pos", 2, VariableScope.function, Type.U8, true)),
				new IRAddrOfArray(tmp(14, Type.POINTER_U8),
				                  new IRVar("buffer", 1, VariableScope.function, Type.POINTER_U8, false),
				                  tmpI64(15),
				                  true, LOCATION),
				literal(tmpU8(18), 0x20),
				sub(tmpU8(17), tmpU8(18), new IRVar("pos", 2, VariableScope.function, Type.U8, true)),
				cast(tmpI64(16), tmpU8(17)),
				new IRCall(null, "printStringLength",
				           List.of(tmp(14, Type.POINTER_U8), tmpI64(16)),
				           LOCATION)
		)));
	}

	@Test
	public void testSpilling() {
		final List<IRInstruction> instructions = List.of(
				literal(tmpI16(0), 10),
				// t0
				literal(tmpI16(1), 3),
				// t0, t1
				add(tmpI16(2), tmpI16(0), tmpI16(1)),
				// t0, t1, t2
				sub(tmpI16(3), tmpI16(0), tmpI16(1)),
				// t0, t1, t2, t3
				add(tmpI16(4), tmpI16(2), tmpI16(3)),
				// t0, t1, t2, t3, t4
				sub(tmpI16(5), tmpI16(0), tmpI16(1)),
				// t2, t3, t4, t5
				new IRCall(null, "print",
				           List.of(tmpI16(2),
				                   tmpI16(3),
				                   tmpI16(4),
				                   tmpI16(5)),
				           LOCATION)
		);
		assertEquals(List.of(
				__dbg__(null, null, null, null),
				literal(regI16(0), 10),
				__dbg__(tmpI16(0), null, null, null),
				literal(regI16(1), 3),
				__dbg__(tmpI16(0), tmpI16(1), null, null),
				add(regI16(2), regI16(0), regI16(1)),
				__dbg__(tmpI16(0), tmpI16(1), tmpI16(2), null),
				sub(regI16(3), regI16(0), regI16(1)),
				__dbg__(tmpI16(0), tmpI16(1), tmpI16(2), tmpI16(3)),
				new IRComment("Spill t.0"),
				copy(tmpI16(0), regI16(0)),
				__dbg__(null, tmpI16(1), tmpI16(2), tmpI16(3)),
				add(regI16(0), regI16(2), regI16(3)),
				__dbg__(tmpI16(4), tmpI16(1), tmpI16(2), tmpI16(3)),
				new IRComment("Spill t.4"),
				copy(tmpI16(4), regI16(0)),
				__dbg__(null, tmpI16(1), tmpI16(2), tmpI16(3)),
				copy(regI16(0), tmpI16(0)),
				sub(regI16(0), regI16(0), regI16(1)),
				__dbg__(tmpI16(5), null, tmpI16(2), tmpI16(3)),
				new IRCall(null, "print",
				           List.of(regI16(2),
				                   regI16(3),
				                   tmpI16(4),
				                   regI16(0)),
				           LOCATION),
				__dbg__(null, null, null, null)
		), allocate(instructions, 4, true));
	}

	private static List<IRInstruction> allocate(List<IRInstruction> instructions) {
		return allocate(instructions, 4, false);
	}

	private static List<IRInstruction> allocate(List<IRInstruction> instructions, int maxRegisters, boolean setProduceDebugInstructions) {
		final BasicBlock block = new BasicBlock("name", instructions, List.of(), List.of());
		DetectVarLiveness.processBlock(block, Set.of());
		final LinearScanRegisterAllocation allocation = new LinearScanRegisterAllocation(block, maxRegisters);
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
	private static IRVar regU8(int index) {
		return reg(index, Type.U8);
	}

	@NotNull
	private static IRVar regI16(int index) {
		return reg(index, Type.I16);
	}

	@NotNull
	private static IRVar reg(int index, Type type) {
		return new IRVar("r." + index, index, VariableScope.register, type, true);
	}

	@NotNull
	private static IRVar tmpU8(int index) {
		return tmp(index, Type.U8);
	}

	@NotNull
	private static IRVar tmpI16(int index) {
		return tmp(index, Type.I16);
	}

	@NotNull
	private static IRVar tmpI64(int index) {
		return tmp(index, Type.I64);
	}

	@NotNull
	private static IRVar tmp(int index, Type type) {
		return new IRVar("t." + index, index, VariableScope.function, type, true);
	}

	@NotNull
	private static IRCopy copy(IRVar target, IRVar source) {
		return new IRCopy(target, source, LOCATION);
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