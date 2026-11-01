package com.regnis.tinyc.ir;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.linearscanregalloc.*;

import java.util.*;
import java.util.function.*;

import org.jetbrains.annotations.*;
import org.junit.*;

/**
 * @author Thomas Singer
 */
public class IRLocalOptimizerTest {

	@Test
	public void testWideWriteInvalidatesOverlappingPointerZ8() {
		final IRVar score = new IRVar("score", 0, VariableScope.global, Type.I32);
		final IRVar address = new IRVar("address", 6, VariableScope.register, Type.pointer(Type.I32));
		final IRVar newAddress = new IRVar("address", 2, VariableScope.register, address.type());
		final IRVar value = new IRVar("value", 5, VariableScope.register, Type.I32);
		final List<IRInstruction> instructions = List.of(
				new IRAddrOf(address, score),
				new IRMove(value, new IRVar("value", 8, VariableScope.register, Type.I32)),
				new IRAddrOf(newAddress, score)
		);
		Assert.assertEquals(instructions, IRLocalOptimizer.cleanUp(instructions, new LSArchitecture.Z8()));
	}

	@Test
	public void testNarrowWriteInvalidatesOverlappingPointerZ8() {
		final IRVar score = new IRVar("score", 0, VariableScope.global, Type.I32);
		final IRVar address = new IRVar("address", 6, VariableScope.register, Type.pointer(Type.I32));
		for (int register = 6; register <= 7; register++) {
			final List<IRInstruction> instructions = List.of(
					new IRAddrOf(address, score),
					new IRMove(rU8("byte", register), 1),
					new IRAddrOf(new IRVar("address", 2, VariableScope.register, address.type()), score)
			);
			Assert.assertEquals(instructions, IRLocalOptimizer.cleanUp(instructions, new LSArchitecture.Z8()));
		}
	}

	@Test
	public void testReadWithDifferentRegisterWidthZ8() {
		final List<IRInstruction> instructions = List.of(
				new IRMove(rU8("byte", 0), rU8("byte", 4)),
				new IRMove(rI16("word", 0), rI16("word", 4))
		);
		Assert.assertEquals(instructions, IRLocalOptimizer.cleanUp(instructions, new LSArchitecture.Z8()));
	}

	@Test
	public void testCompareInvalidatesCachedRegister() {
		final IRVar flag = new IRVar("flag", 0, VariableScope.register, Type.BOOL);
		final List<IRInstruction> instructions = List.of(
				new IRMove(flag, 0),
				new IRCompare(flag, IRCompare.Op.Equals, rU8("a", 1), rU8("b", 2)),
				new IRMove(flag, 0)
		);
		Assert.assertEquals(instructions, cleanup(instructions));
	}

	@Test
	public void testMoveBackAndForth() {
		Assert.assertEquals(List.of(
				new IRMove(rU8("foo", 0), rU8("bar", 1))
		), cleanup(List.of(
				new IRMove(rU8("foo", 0), rU8("bar", 1)),
				new IRMove(rU8("bar", 1), rU8("foo", 0))
		)));
	}

	@Test
	public void testLoadStore() {
		final IRVar rAddr = new IRVar("addr", 2, VariableScope.register, Type.POINTER_U8);
		final IRVar stackVarA = new IRVar("a", 0, VariableScope.function, Type.U8);
		Assert.assertEquals(List.of(
				new IRAddrOf(rAddr, stackVarA),
				new IRMemLoad(rU8("b", 1), rAddr)
		), cleanup(List.of(
				new IRAddrOf(rAddr, stackVarA),
				new IRMemLoad(rU8("b", 1), rAddr),
				new IRAddrOf(rAddr, stackVarA),
				new IRMemStore(rAddr, rU8("b", 1))
		)));
	}

	@Test
	public void testStoreLoad() {
		final IRVar rAddr = new IRVar("addr", 2, VariableScope.register, Type.POINTER_U8);
		final IRVar stackVarA = new IRVar("a", 0, VariableScope.function, Type.U8);
		Assert.assertEquals(List.of(
				new IRAddrOf(rAddr, stackVarA),
				new IRMemStore(rAddr, rU8("b", 1))
		), cleanup(List.of(
				new IRAddrOf(rAddr, stackVarA),
				new IRMemStore(rAddr, rU8("b", 1)),
				new IRAddrOf(rAddr, stackVarA),
				new IRMemLoad(rU8("b", 1), rAddr)
		)));
	}

	@Test
	public void testStoreLoad2() {
		final IRVar rAddr = new IRVar("addr", 2, VariableScope.register, Type.POINTER_U8);
		final IRVar stackVarA = new IRVar("a", 0, VariableScope.function, Type.U8);
		Assert.assertEquals(List.of(
				new IRAddrOf(rAddr, stackVarA),
				new IRMemStore(rAddr, rU8("b", 1)),
				new IRMove(rU8("b", 2), rU8("b", 1))
		), cleanup(List.of(
				new IRAddrOf(rAddr, stackVarA),
				new IRMemStore(rAddr, rU8("b", 1)),
				new IRAddrOf(rAddr, stackVarA),
				new IRMemLoad(rU8("b", 2), rAddr)
		)));
	}

	@Test
	public void testMineRevealAround() {
		Assert.assertEquals(List.of(
				new IRMove(rU8("row", 8), rU8("row", 0)),
				new IRMove(rU8("column", 9), rU8("column", 1)),
//				new IRMove(rU8("row", 0), rU8("row", 8)),
//				new IRMove(rU8("column", 1), rU8("column", 9)),
				new IRCall(null, Type.VOID, "printCellAt", List.of(
						new IRValue(rU8("row", 0)),
						new IRValue(rU8("column", 1))
				)),
				new IRMove(rU8("row", 0), rU8("row", 8)),
				new IRMove(rU8("column", 1), rU8("column", 9)),
				new IRCall(rU8("t.10", 0), Type.U8, "getBombCountAround", List.of(
						new IRValue(rU8("row", 0)),
						new IRValue(rU8("column", 1))
				)),
				new IRBranch(IRCompare.Op.NotEquals, rU8("t.10", 0), 0, "ret", "if_30_end"),
				new IRMove(rU8("rowFrom", 10), rU8("row", 8)),
				new IRBranch(IRCompare.Op.LtEq, rU8("rowFrom", 10), 0, "if_31_end", "if_31_then"),
//				new IRMove(rU8("rowFrom", 10), rU8("row", 8)),
				new IRBinary(rU8("rowFrom", 10), IRBinary.Op.Sub, rU8("rowFrom", 10), 1),

				new IRLabel("if_31_then"),
				new IRMove(rU8("rowTo", 11), rU8("row", 8)),
				new IRBinary(rU8("rowTo", 11), IRBinary.Op.Add, rU8("rowTo", 11), 1),
				new IRBranch(IRCompare.Op.Lt, rU8("rowTo", 11), 20, "if_32_end", "if_32_then"),
				new IRBinary(rU8("rowTo", 11), IRBinary.Op.Sub, rU8("rowTo", 11), 1),

				new IRLabel("if_32_then"),
				new IRMove(rU8("colFrom", 12), rU8("column", 9)),
				new IRBranch(IRCompare.Op.LtEq, rU8("colFrom", 12), 0, "if_33_end", "if_33_then"),
				new IRBinary(rU8("colFrom", 12), IRBinary.Op.Sub, rU8("colFrom", 12), 1),

				new IRLabel("if_33_end"),
				new IRMove(rU8("colTo", 13), rU8("column", 9)),
				new IRBinary(rU8("colTo", 13), IRBinary.Op.Add, rU8("colTo", 13), 1),
				new IRBranch(IRCompare.Op.Lt, rU8("colTo", 13), 17, "if_34_end", "if_34_then"),
				new IRBinary(rU8("colTo", 13), IRBinary.Op.Sub, rU8("colTo", 13), 1),

				new IRLabel("if_34_end"),
				new IRJump("for_35"),

				new IRLabel("if_35_body"),
				new IRMove(rU8("r", 0), rU8("r", 10)),
				new IRMove(rU8("colFrom", 1), rU8("colFrom", 12)),
				new IRCall(rI16("index", 0), Type.I16, "rowColumnToCell", List.of(
						new IRValue(rU8("r", 0)),
						new IRValue(rU8("colFrom", 1))
				)),
				new IRMove(rU8("c", 2), rU8("colFrom", 12)),
				new IRMove(rI16("index", 2), rI16("index", 0)),
				new IRJump("for_36")
		), cleanup(List.of(
				new IRMove(rU8("row", 8), rU8("row", 0)),
				new IRMove(rU8("column", 9), rU8("column", 1)),
				new IRMove(rU8("row", 0), rU8("row", 8)),
				new IRMove(rU8("column", 1), rU8("column", 9)),
				new IRCall(null, Type.VOID, "printCellAt", List.of(
						new IRValue(rU8("row", 0)),
						new IRValue(rU8("column", 1))
				)),
				new IRMove(rU8("row", 0), rU8("row", 8)),
				new IRMove(rU8("column", 1), rU8("column", 9)),
				new IRCall(rU8("t.10", 0), Type.U8, "getBombCountAround", List.of(
						new IRValue(rU8("row", 0)),
						new IRValue(rU8("column", 1))
				)),
				new IRBranch(IRCompare.Op.NotEquals, rU8("t.10", 0), 0, "ret", "if_30_end"),
				new IRMove(rU8("rowFrom", 10), rU8("row", 8)),
				new IRBranch(IRCompare.Op.LtEq, rU8("rowFrom", 10), 0, "if_31_end", "if_31_then"),
				new IRMove(rU8("rowFrom", 10), rU8("row", 8)),
				new IRBinary(rU8("rowFrom", 10), IRBinary.Op.Sub, rU8("rowFrom", 10), 1),

				new IRLabel("if_31_then"),
				new IRMove(rU8("rowTo", 11), rU8("row", 8)),
				new IRBinary(rU8("rowTo", 11), IRBinary.Op.Add, rU8("rowTo", 11), 1),
				new IRBranch(IRCompare.Op.Lt, rU8("rowTo", 11), 20, "if_32_end", "if_32_then"),
				new IRBinary(rU8("rowTo", 11), IRBinary.Op.Sub, rU8("rowTo", 11), 1),

				new IRLabel("if_32_then"),
				new IRMove(rU8("colFrom", 12), rU8("column", 9)),
				new IRBranch(IRCompare.Op.LtEq, rU8("colFrom", 12), 0, "if_33_end", "if_33_then"),
				new IRBinary(rU8("colFrom", 12), IRBinary.Op.Sub, rU8("colFrom", 12), 1),

				new IRLabel("if_33_end"),
				new IRMove(rU8("colTo", 13), rU8("column", 9)),
				new IRBinary(rU8("colTo", 13), IRBinary.Op.Add, rU8("colTo", 13), 1),
				new IRBranch(IRCompare.Op.Lt, rU8("colTo", 13), 17, "if_34_end", "if_34_then"),
				new IRBinary(rU8("colTo", 13), IRBinary.Op.Sub, rU8("colTo", 13), 1),

				new IRLabel("if_34_end"),
				new IRJump("for_35"),

				new IRLabel("if_35_body"),
				new IRMove(rU8("r", 0), rU8("r", 10)),
				new IRMove(rU8("colFrom", 1), rU8("colFrom", 12)),
				new IRCall(rI16("index", 0), Type.I16, "rowColumnToCell", List.of(
						new IRValue(rU8("r", 0)),
						new IRValue(rU8("colFrom", 1))
				)),
				new IRMove(rU8("c", 2), rU8("colFrom", 12)),
				new IRMove(rI16("index", 2), rI16("index", 0)),
				new IRJump("for_36")
		)));
	}

	@NotNull
	private static IRVar rU8(String name, int index) {
		return new IRVar(name, index, VariableScope.register, Type.U8);
	}

	@NotNull
	private static IRVar rI16(String name, int index) {
		return new IRVar(name, index, VariableScope.register, Type.I16);
	}

	@NotNull
	private static List<IRInstruction> cleanup(List<IRInstruction> instructions) {
		return IRLocalOptimizer.cleanUp(instructions, instruction -> {
			if (instruction instanceof IRCall) {
				return i -> i < 8;
			}
			return null;
		});
	}
}
