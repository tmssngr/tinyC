package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;
import com.regnis.tinyc.linearscanregalloc.*;

import java.io.*;
import java.nio.file.*;
import java.util.*;

import org.junit.*;

/**
 * @author Thomas Singer
 */
public final class AsmWriterTest {

	@Test
	public void testEmpty() throws IOException {
		write("empty", new IRProgram(List.of(), List.of(),
		                             new IRVarInfos(List.of(), Set.of(), null),
		                             List.of()));
	}

	@Test
	public void testFunctionX86() throws IOException {
		final IRVarInfos globalVarInfo = new IRVarInfos(List.of(), Set.of(), null);
		final IRVar varA = new IRVar("a", 0, VariableScope.parameter, Type.I16);
		final IRVar varB = new IRVar("b", 1, VariableScope.parameter, Type.I32);
		final IRVar varC = new IRVar("c", 2, VariableScope.parameter, Type.pointer(Type.VOID));
		final IRVar varD = new IRVar("d", 3, VariableScope.parameter, Type.I64);
		final IRVar varE = new IRVar("e", 4, VariableScope.parameter, Type.I64);
		final IRVar varF = new IRVar("f", 5, VariableScope.parameter, Type.I64);
		final IRVar varG = new IRVar("g", 6, VariableScope.parameter, Type.I64);
		final IRVar varTemp = new IRVar("temp", 7, VariableScope.parameter, Type.I64);
		writeX86("function", new IRProgram(
				List.of(
						new IRFunction("fn", Type.I64,
						               new IRVarInfos(List.of(
								               new IRVarDef(varA, 2),
								               new IRVarDef(varB, 4),
								               new IRVarDef(varC, 8),
								               new IRVarDef(varD, 8),
								               new IRVarDef(varE, 8),
								               new IRVarDef(varF, 8),
								               new IRVarDef(varG, 8),
								               new IRVarDef(varTemp, 8)
						               ), Set.of(), globalVarInfo),
						               List.of(
								               new IRMove(varA.asRegister(0), 10),
								               new IRMove(varB.asRegister(1), 20),
								               new IRAddrOf(varC.asRegister(2), varC),
								               new IRMemLoad(varD.asRegister(3), varC.asRegister(2))
						               ))
				),
				List.of(), globalVarInfo, List.of()));
	}

	@Test
	public void testFunctionZ8() throws IOException {
		final IRVarInfos globalVarInfo = new IRVarInfos(List.of(), Set.of(), null);
		final IRVar varA = new IRVar("a", 0, VariableScope.parameter, Type.I16);
		final IRVar varB = new IRVar("b", 1, VariableScope.parameter, Type.U8);
		final IRVar varC = new IRVar("c", 2, VariableScope.function, Type.U8);
		final IRVar varD = new IRVar("d", 3, VariableScope.function, Type.pointer(Type.VOID));
		writeZ8("function", new IRProgram(
				List.of(
						new IRFunction("fn", Type.I16,
						               new IRVarInfos(List.of(
								               new IRVarDef(varA, 2),
								               new IRVarDef(varB, 1),
								               new IRVarDef(varC, 1),
								               new IRVarDef(varD, 2)
						               ), Set.of(), globalVarInfo),
						               List.of(
								               new IRMove(varA.asRegister(0), 10),
								               new IRMove(varB.asRegister(2), 20),
								               new IRAddrOf(varD.asRegister(4), varC),
								               new IRMemLoad(varC.asRegister(3), varD.asRegister(4))
						               ))
				),
				List.of(), globalVarInfo, List.of()));
	}

	@Test
	public void testRegistersToPushZ8() throws IOException {
		final IRVarInfos globalVarInfo = new IRVarInfos(List.of(), Set.of(), null);
		int index = 0;
		final IRVar p0 = new IRVar("p" + index, index++, VariableScope.parameter, Type.U8);
		final IRVar p1 = new IRVar("p" + index, index++, VariableScope.parameter, Type.U8);
		final IRVar p2 = new IRVar("p" + index, index++, VariableScope.parameter, Type.U8);
		final IRVar p3 = new IRVar("p" + index, index++, VariableScope.parameter, Type.U8);
		final IRVar p4 = new IRVar("p" + index, index++, VariableScope.parameter, Type.U8);
		final IRVar p5 = new IRVar("p" + index, index++, VariableScope.parameter, Type.U8);
		final IRVar p6 = new IRVar("p" + index, index++, VariableScope.parameter, Type.U8);
		final IRVar p7 = new IRVar("p" + index, index++, VariableScope.parameter, Type.U8);
		final IRVar p8 = new IRVar("p" + index, index++, VariableScope.parameter, Type.U8);
		final IRVar p9 = new IRVar("p" + index, index++, VariableScope.parameter, Type.U8);
		final IRVar var10 = new IRVar("v" + index, index, VariableScope.function, Type.U8);
		writeZ8("regsToPush", new IRProgram(
				List.of(
						new IRFunction("fn", Type.U8,
						               new IRVarInfos(List.of(
								               new IRVarDef(p0, 1),
								               new IRVarDef(p1, 1),
								               new IRVarDef(p2, 1),
								               new IRVarDef(p3, 1),
								               new IRVarDef(p4, 1),
								               new IRVarDef(p5, 1),
								               new IRVarDef(p6, 1),
								               new IRVarDef(p7, 1),
								               new IRVarDef(p8, 1),
								               new IRVarDef(p9, 1),
								               new IRVarDef(var10, 1)
						               ), Set.of(), globalVarInfo),
						               List.of(
								               new IRMove(var10.asRegister(8), p0.asRegister(0))
						               ))
				),
				List.of(), globalVarInfo, List.of()));
	}

	@Test
	public void testRegistersToPushZ8WithStackArguments() throws IOException {
		final String assembly = renderZ8WithRegisterWrite(List.of(Type.U8, Type.U8, Type.U8, Type.U8, Type.U8,
		                                                          Type.U8, Type.U8, Type.U8, Type.U8, Type.U8),
		                                                  8, Z8CallingConventionProvider.INSTANCE);
		Assert.assertTrue(assembly, assembly.contains("push r8"));
		Assert.assertTrue(assembly, assembly.contains("pop  r8"));
	}

	@Test
	public void testRegistersToPushZ8WithWideRegisterArgument() throws IOException {
		final String assembly = renderZ8WithRegisterWrite(List.of(Type.U8, Type.U8, Type.U8,
		                                                          Type.U8, Type.U8, Type.U8,
		                                                          Type.I32),
		                                                  10, Z8CallingConventionProvider.INSTANCE);
		Assert.assertTrue(assembly, assembly.contains("push r10"));
		Assert.assertTrue(assembly, assembly.contains("pop  r10"));
		Assert.assertFalse(assembly, assembly.contains("push r8"));
	}

	@Test
	public void testRegistersToPushZ8WithInjectedCallingConvention() throws IOException {
		final LSCallingConventionProvider provider = (targetType, argumentTypes) -> new LSCallingConvention(List.of(), 10);
		final String assembly = renderZ8WithRegisterWrite(List.of(),
		                                                  10, provider);
		Assert.assertTrue(assembly, assembly.contains("push r10"));
		Assert.assertTrue(assembly, assembly.contains("pop  r10"));
		Assert.assertFalse(assembly, assembly.contains("push r8"));
	}

	@Test
	public void testCompareZ8() throws IOException {
		final IRVarInfos globalVarInfo = new IRVarInfos(List.of(), Set.of(), null);
		final IRVar b1 = new IRVar("b1", 0, VariableScope.function, Type.U8);
		final IRVar b2 = new IRVar("b2", 1, VariableScope.function, Type.U8);
		final IRVar i1 = new IRVar("i1", 2, VariableScope.function, Type.I16);
		final IRVar i2 = new IRVar("i2", 3, VariableScope.function, Type.I16);
		final IRVar w1 = new IRVar("w1", 4, VariableScope.function, Type.I32);
		final IRVar w2 = new IRVar("w2", 5, VariableScope.function, Type.I32);
		final IRVar vB = new IRVar("b", 6, VariableScope.function, Type.BOOL);
		writeZ8("compare", new IRProgram(
				List.of(
						new IRFunction("regReg", Type.VOID,
						               new IRVarInfos(List.of(
								               new IRVarDef(b1, 1),
								               new IRVarDef(b2, 1),
								               new IRVarDef(i1, 2),
								               new IRVarDef(i2, 2)
						               ), Set.of(), globalVarInfo),
						               List.of(
											   new IRCompare(vB.asRegister(0), IRCompare.Op.Equals, b1.asRegister(1), b2.asRegister(2)),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.Equals, i1.asRegister(2), i2.asRegister(4)),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.Equals, w1.asRegister(2), w2.asRegister(6)),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.NotEquals, b1.asRegister(1), b2.asRegister(2)),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.NotEquals, i1.asRegister(2), i2.asRegister(4)),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.NotEquals, w1.asRegister(2), w2.asRegister(6)),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.Lt, b1.asRegister(1), b2.asRegister(2)),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.Lt, i1.asRegister(2), i2.asRegister(4)),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.Lt, w1.asRegister(2), w2.asRegister(6)),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.LtEq, b1.asRegister(1), b2.asRegister(2)),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.LtEq, i1.asRegister(2), i2.asRegister(4)),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.LtEq, w1.asRegister(2), w2.asRegister(6)),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.GtEq, b1.asRegister(1), b2.asRegister(2)),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.GtEq, i1.asRegister(2), i2.asRegister(4)),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.GtEq, w1.asRegister(2), w2.asRegister(6)),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.Gt, b1.asRegister(1), b2.asRegister(2)),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.Gt, i1.asRegister(2), i2.asRegister(4)),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.Gt, w1.asRegister(2), w2.asRegister(6))
						               )),
						new IRFunction("regLit", Type.VOID,
						               new IRVarInfos(List.of(
								               new IRVarDef(b1, 1),
								               new IRVarDef(b2, 1),
								               new IRVarDef(i1, 2),
								               new IRVarDef(i2, 2)
						               ), Set.of(), globalVarInfo),
						               List.of(
											   new IRCompare(vB.asRegister(0), IRCompare.Op.Equals, b1.asRegister(1), 42, Location.DUMMY),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.Equals, i1.asRegister(2), 42, Location.DUMMY),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.Equals, w1.asRegister(2), 42, Location.DUMMY),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.NotEquals, b1.asRegister(1), 42, Location.DUMMY),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.NotEquals, i1.asRegister(2), 42, Location.DUMMY),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.NotEquals, w1.asRegister(2), 42, Location.DUMMY),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.Lt, b1.asRegister(1), 42, Location.DUMMY),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.Lt, i1.asRegister(2), 42, Location.DUMMY),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.Lt, w1.asRegister(2), 42, Location.DUMMY),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.LtEq, b1.asRegister(1), 42, Location.DUMMY),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.LtEq, i1.asRegister(2), 42, Location.DUMMY),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.LtEq, w1.asRegister(2), 42, Location.DUMMY),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.GtEq, b1.asRegister(1), 42, Location.DUMMY),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.GtEq, i1.asRegister(2), 42, Location.DUMMY),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.GtEq, w1.asRegister(2), 42, Location.DUMMY),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.Gt, b1.asRegister(1), 42, Location.DUMMY),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.Gt, i1.asRegister(2), 42, Location.DUMMY),
											   new IRCompare(vB.asRegister(0), IRCompare.Op.Gt, w1.asRegister(2), 42, Location.DUMMY)
						               ))
				),
				List.of(), globalVarInfo, List.of()));
	}

	@Test
	public void testBranchZ8() throws IOException {
		final IRVarInfos globalVarInfo = new IRVarInfos(List.of(), Set.of(), null);
		final IRVar b1 = new IRVar("b1", 0, VariableScope.function, Type.U8);
		final IRVar b2 = new IRVar("b2", 1, VariableScope.function, Type.U8);
		final IRVar i1 = new IRVar("i1", 2, VariableScope.function, Type.I16);
		final IRVar i2 = new IRVar("i2", 3, VariableScope.function, Type.I16);
		final IRVar w1 = new IRVar("w1", 4, VariableScope.function, Type.I32);
		final IRVar w2 = new IRVar("w2", 5, VariableScope.function, Type.I32);
		writeZ8("branch", new IRProgram(
				List.of(
						new IRFunction("branchRegReg", Type.VOID,
						               new IRVarInfos(List.of(
								               new IRVarDef(b1, 1),
								               new IRVarDef(b2, 1),
								               new IRVarDef(i1, 2),
								               new IRVarDef(i2, 2),
								               new IRVarDef(w1, 4),
								               new IRVarDef(w2, 4)
						               ), Set.of(), globalVarInfo),
						               List.of(
											   new IRBranch(IRCompare.Op.Equals, b1.asRegister(0), b2.asRegister(1), "target", "next"),
											   new IRBranch(IRCompare.Op.Equals, i1.asRegister(0), i2.asRegister(2), "target", "next"),
											   new IRBranch(IRCompare.Op.Equals, w1.asRegister(0), w2.asRegister(4), "target", "next"),
											   new IRBranch(IRCompare.Op.NotEquals, b1.asRegister(0), b2.asRegister(1), "target", "next"),
											   new IRBranch(IRCompare.Op.NotEquals, i1.asRegister(0), i2.asRegister(2), "target", "next"),
											   new IRBranch(IRCompare.Op.NotEquals, w1.asRegister(0), w2.asRegister(4), "target", "next"),
											   new IRBranch(IRCompare.Op.Lt, b1.asRegister(0), b2.asRegister(1), "target", "next"),
											   new IRBranch(IRCompare.Op.Lt, i1.asRegister(0), i2.asRegister(2), "target", "next"),
											   new IRBranch(IRCompare.Op.Lt, w1.asRegister(0), w2.asRegister(4), "target", "next"),
											   new IRBranch(IRCompare.Op.LtEq, b1.asRegister(0), b2.asRegister(1), "target", "next"),
											   new IRBranch(IRCompare.Op.LtEq, i1.asRegister(0), i2.asRegister(2), "target", "next"),
											   new IRBranch(IRCompare.Op.LtEq, w1.asRegister(0), w2.asRegister(4), "target", "next"),
											   new IRBranch(IRCompare.Op.GtEq, b1.asRegister(0), b2.asRegister(1), "target", "next"),
											   new IRBranch(IRCompare.Op.GtEq, i1.asRegister(0), i2.asRegister(2), "target", "next"),
											   new IRBranch(IRCompare.Op.GtEq, w1.asRegister(0), w2.asRegister(4), "target", "next"),
											   new IRBranch(IRCompare.Op.Gt, b1.asRegister(0), b2.asRegister(1), "target", "next"),
											   new IRBranch(IRCompare.Op.Gt, i1.asRegister(0), i2.asRegister(2), "target", "next"),
											   new IRBranch(IRCompare.Op.Gt, w1.asRegister(0), w2.asRegister(4), "target", "next")
						               )),
						new IRFunction("branchRegLit", Type.VOID,
						               new IRVarInfos(List.of(
								               new IRVarDef(b1, 1),
								               new IRVarDef(b2, 1),
								               new IRVarDef(i1, 2),
								               new IRVarDef(i2, 2),
								               new IRVarDef(w1, 4),
								               new IRVarDef(w2, 4)
						               ), Set.of(), globalVarInfo),
						               List.of(
											   new IRBranch(IRCompare.Op.Equals, b1.asRegister(0), 42, "target", "next", Location.DUMMY),
											   new IRBranch(IRCompare.Op.Equals, i1.asRegister(0), 42, "target", "next", Location.DUMMY),
											   new IRBranch(IRCompare.Op.Equals, w1.asRegister(0), 42, "target", "next", Location.DUMMY),
											   new IRBranch(IRCompare.Op.NotEquals, b1.asRegister(0), 42, "target", "next", Location.DUMMY),
											   new IRBranch(IRCompare.Op.NotEquals, i1.asRegister(0), 42, "target", "next", Location.DUMMY),
											   new IRBranch(IRCompare.Op.NotEquals, w1.asRegister(0), 42, "target", "next", Location.DUMMY),
											   new IRBranch(IRCompare.Op.Lt, b1.asRegister(0), 42, "target", "next", Location.DUMMY),
											   new IRBranch(IRCompare.Op.Lt, i1.asRegister(0), 42, "target", "next", Location.DUMMY),
											   new IRBranch(IRCompare.Op.Lt, w1.asRegister(0), 42, "target", "next", Location.DUMMY),
											   new IRBranch(IRCompare.Op.LtEq, b1.asRegister(0), 42, "target", "next", Location.DUMMY),
											   new IRBranch(IRCompare.Op.LtEq, i1.asRegister(0), 42, "target", "next", Location.DUMMY),
											   new IRBranch(IRCompare.Op.LtEq, w1.asRegister(0), 42, "target", "next", Location.DUMMY),
											   new IRBranch(IRCompare.Op.GtEq, b1.asRegister(0), 42, "target", "next", Location.DUMMY),
											   new IRBranch(IRCompare.Op.GtEq, i1.asRegister(0), 42, "target", "next", Location.DUMMY),
											   new IRBranch(IRCompare.Op.GtEq, w1.asRegister(0), 42, "target", "next", Location.DUMMY),
											   new IRBranch(IRCompare.Op.Gt, b1.asRegister(0), 42, "target", "next", Location.DUMMY),
											   new IRBranch(IRCompare.Op.Gt, i1.asRegister(0), 42, "target", "next", Location.DUMMY),
											   new IRBranch(IRCompare.Op.Gt, w1.asRegister(0), 42, "target", "next", Location.DUMMY)
						               ))
				),
				List.of(), globalVarInfo, List.of()));
	}

	@Test
	public void testUnaryZ8() throws IOException {
		final IRVarInfos globalVarInfo = new IRVarInfos(List.of(), Set.of(), null);
		final IRVar vU = new IRVar("u", 0, VariableScope.parameter, Type.U8);
		final IRVar vV = new IRVar("v", 1, VariableScope.parameter, Type.U8);
		final IRVar vI = new IRVar("i", 2, VariableScope.parameter, Type.I16);
		final IRVar vJ = new IRVar("j", 3, VariableScope.parameter, Type.I16);
		final IRVar vK = new IRVar("i", 4, VariableScope.function, Type.I32);
		final IRVar vL = new IRVar("j", 5, VariableScope.function, Type.I32);
		final IRVar vB = new IRVar("b", 6, VariableScope.function, Type.BOOL);
		final IRVar vC = new IRVar("c", 7, VariableScope.function, Type.BOOL);
		writeZ8("unary", new IRProgram(
				List.of(
						new IRFunction("fn", Type.I16,
						               new IRVarInfos(List.of(
								               new IRVarDef(vU, 1),
								               new IRVarDef(vV, 1),
								               new IRVarDef(vI, 2),
								               new IRVarDef(vJ, 2),
								               new IRVarDef(vK, 4),
								               new IRVarDef(vL, 4),
								               new IRVarDef(vB, 1),
								               new IRVarDef(vC, 1)
						               ), Set.of(), globalVarInfo),
						               List.of(
								               new IRUnary(IRUnary.Op.Neg, vU.asRegister(0), vV.asRegister(0)),
								               new IRUnary(IRUnary.Op.Neg, vU.asRegister(0), vV.asRegister(1)),
								               new IRUnary(IRUnary.Op.Neg, vI.asRegister(0), vJ.asRegister(0)),
								               new IRUnary(IRUnary.Op.Neg, vI.asRegister(0), vJ.asRegister(2)),
								               new IRUnary(IRUnary.Op.Neg, vK.asRegister(0), vL.asRegister(0)),
								               new IRUnary(IRUnary.Op.Neg, vK.asRegister(0), vL.asRegister(4)),
								               new IRUnary(IRUnary.Op.Not, vU.asRegister(0), vV.asRegister(0)),
								               new IRUnary(IRUnary.Op.Not, vU.asRegister(0), vV.asRegister(1)),
								               new IRUnary(IRUnary.Op.Not, vI.asRegister(0), vJ.asRegister(0)),
								               new IRUnary(IRUnary.Op.Not, vI.asRegister(0), vJ.asRegister(2)),
								               new IRUnary(IRUnary.Op.NotLog, vB.asRegister(0), vC.asRegister(0)),
								               new IRUnary(IRUnary.Op.NotLog, vB.asRegister(0), vC.asRegister(1))
						               ))
				),
				List.of(), globalVarInfo, List.of()));
	}

	@Test
	public void testCastZ8() throws IOException {
		final IRVarInfos globalVarInfo = new IRVarInfos(List.of(), Set.of(), null);
		final IRVar vU = new IRVar("u", 0, VariableScope.function, Type.U8);
		final IRVar vI = new IRVar("i", 1, VariableScope.function, Type.I16);
		final IRVar vK = new IRVar("k", 2, VariableScope.function, Type.I32);
		final List<IRVarDef> defs = List.of(
				new IRVarDef(vU, 1),
				new IRVarDef(vI, 2),
				new IRVarDef(vK, 4)
		);
		final List<IRInstruction> instructions = new ArrayList<>();
		for (IRVarDef targetDef : defs) {
			final IRVar target = targetDef.var();
			final int targetSize = Type.getSize(target.type(), Type.I16);
			for (IRVarDef sourceDef : defs) {
				final IRVar source = sourceDef.var();
				if (source == target) {
					continue;
				}

				final int sourceSize = Type.getSize(source.type(), Type.I16);

				if (targetSize < sourceSize) {
					instructions.add(new IRCast(target.asRegister(0), source.asRegister(targetSize)));
					instructions.add(new IRCast(target.asRegister(0), source.asRegister(0)));
					instructions.add(new IRCast(target.asRegister(sourceSize - targetSize), source.asRegister(0)));
					instructions.add(new IRCast(target.asRegister(sourceSize), source.asRegister(0)));
				}
				else if (targetSize > sourceSize) {
					instructions.add(new IRCast(target.asRegister(0), source.asRegister(targetSize)));
					instructions.add(new IRCast(target.asRegister(0), source.asRegister(targetSize - 1)));
					instructions.add(new IRCast(target.asRegister(0), source.asRegister(targetSize - sourceSize)));
					instructions.add(new IRCast(target.asRegister(0), source.asRegister(0)));
					instructions.add(new IRCast(target.asRegister(sourceSize), source.asRegister(0)));
				}
			}
		}
		writeZ8("cast", new IRProgram(
				List.of(
						new IRFunction("fn", Type.I16,
						               new IRVarInfos(defs, Set.of(), globalVarInfo),
						               instructions)
				),
				List.of(), globalVarInfo, List.of()));
	}

	@Test
	public void testMoveZ8() throws IOException {
		final IRVarInfos globalVarInfo = new IRVarInfos(List.of(), Set.of(), null);
		final IRVar i16 = new IRVar("i16", 0, VariableScope.function, Type.I16);
		writeZ8("move", new IRProgram(
				List.of(
						new IRFunction("fn", Type.I16,
						               new IRVarInfos(List.of(
								               new IRVarDef(i16, 2)
						               ), Set.of(), globalVarInfo),
						               List.of(
											   new IRMove(i16.asRegister(0), i16.asRegister(2)),
											   new IRMove(i16.asRegister(2), i16.asRegister(0)),
											   new IRMove(i16.asRegister(1), i16.asRegister(2)),
											   new IRMove(i16.asRegister(2), i16.asRegister(1))
						               ))
				),
				List.of(), globalVarInfo, List.of()));
	}

	@Test
	public void testShiftZ8() throws IOException {
		final IRVarInfos globalVarInfo = new IRVarInfos(List.of(), Set.of(), null);
		final IRVar u8 = new IRVar("u8", 0, VariableScope.function, Type.U8);
		final IRVar i32 = new IRVar("i32", 1, VariableScope.function, Type.I32);
		writeZ8("shift", new IRProgram(
				List.of(
						new IRFunction("fn", Type.I32,
						               new IRVarInfos(List.of(
								               new IRVarDef(u8, 1),
								               new IRVarDef(i32, 4)
						               ), Set.of(), globalVarInfo),
						               List.of(
								               new IRBinary(u8.asRegister(0), IRBinary.Op.ShiftLeft, u8.asRegister(0), 1),
								               new IRBinary(u8.asRegister(0), IRBinary.Op.ShiftRight, u8.asRegister(0), 1),
								               new IRBinary(u8.asRegister(1), IRBinary.Op.ShiftLeft, u8.asRegister(1), 2),
								               new IRBinary(u8.asRegister(1), IRBinary.Op.ShiftRight, u8.asRegister(1), 2),
								               new IRBinary(u8.asRegister(2), IRBinary.Op.ShiftLeft, u8.asRegister(2), 4),
								               new IRBinary(u8.asRegister(2), IRBinary.Op.ShiftRight, u8.asRegister(2), 4),
								               new IRBinary(u8.asRegister(3), IRBinary.Op.ShiftLeft, u8.asRegister(3), 8),
								               new IRBinary(u8.asRegister(3), IRBinary.Op.ShiftRight, u8.asRegister(3), 8),

								               new IRBinary(i32.asRegister(0), IRBinary.Op.ShiftLeft, i32.asRegister(0), 1),
								               new IRBinary(i32.asRegister(0), IRBinary.Op.ShiftRight, i32.asRegister(0), 1),
								               new IRBinary(i32.asRegister(4), IRBinary.Op.ShiftLeft, i32.asRegister(4), 2),
								               new IRBinary(i32.asRegister(4), IRBinary.Op.ShiftRight, i32.asRegister(4), 2),
								               new IRBinary(i32.asRegister(8), IRBinary.Op.ShiftLeft, i32.asRegister(8), 4),
								               new IRBinary(i32.asRegister(8), IRBinary.Op.ShiftRight, i32.asRegister(8), 4),
								               new IRBinary(i32.asRegister(0), IRBinary.Op.ShiftLeft, i32.asRegister(0), 8),
								               new IRBinary(i32.asRegister(0), IRBinary.Op.ShiftRight, i32.asRegister(0), 8)
						               ))
				),
				List.of(), globalVarInfo, List.of()));
	}

	private void write(String name, IRProgram program) throws IOException {
		writeX86(name, program);
		writeZ8(name, program);
	}

	private void writeX86(String name, IRProgram program) throws IOException {
		write(name, program, "x86win64", TargetArchitecture.WIN_X86_64);
		write(name, program, "x86linux64", TargetArchitecture.LINUX_X86_64);
	}

	private void writeZ8(String name, IRProgram program) throws IOException {
		write(name, program, "z8", TargetArchitecture.Z8);
	}

	private String renderZ8WithRegisterWrite(List<Type> argumentTypes, int register, LSCallingConventionProvider provider) throws IOException {
		final IRVarInfos globalVarInfo = new IRVarInfos(List.of(), Set.of(), null);
		final List<IRVarDef> arguments = new ArrayList<>();
		for (int index = 0; index < argumentTypes.size(); index++) {
			final Type type = argumentTypes.get(index);
			arguments.add(new IRVarDef(new IRVar("p" + index, index, VariableScope.parameter, type), Type.getSize(type, Z8CallingConventionProvider.POINTER_INT_TYPE)));
		}
		final IRVarInfos varInfos = new IRVarInfos(arguments, Set.of(), globalVarInfo);
		final IRFunction function = new IRFunction("fn", Type.U8, varInfos,
		                                           List.of(
														   new IRMove(new IRVar("value", register, VariableScope.register, Type.U8), 1)
		                                           ));
		final IRProgram program = new IRProgram(List.of(function), List.of(), globalVarInfo, List.of());

		final StringWriter output = new StringWriter();
		try (final BufferedWriter writer = new BufferedWriter(output)) {
			new Z8AsmWriter(writer, provider).write(program);
		}
		return output.toString();
	}

	private void write(String name, IRProgram program, String subdir, TargetArchitecture architecture) throws IOException {
		final Path dir = Path.of("src/main/resources-test/asmwriter").resolve(subdir);
		Files.createDirectories(dir);
		final Path asmFile = dir.resolve(name + ".asm");
		try (final BufferedWriter writer = Files.newBufferedWriter(asmFile)) {
			final AsmWriter output = architecture.createAsmWriter(writer);
			output.write(program);
		}
	}
}
