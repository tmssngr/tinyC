package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

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
						new IRFunction("fn", "@fn", Type.I64,
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
								               new IRLiteral(varA.asRegister(0), 10),
								               new IRLiteral(varB.asRegister(1), 20),
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
		final IRVar varC = new IRVar("c", 2, VariableScope.parameter, Type.U8);
		final IRVar varD = new IRVar("d", 3, VariableScope.parameter, Type.pointer(Type.VOID));
		writeZ8("function", new IRProgram(
				List.of(
						new IRFunction("fn", "@fn", Type.I16,
						               new IRVarInfos(List.of(
								               new IRVarDef(varA, 2),
								               new IRVarDef(varB, 1),
								               new IRVarDef(varC, 1),
								               new IRVarDef(varD, 2)
						               ), Set.of(), globalVarInfo),
						               List.of(
								               new IRLiteral(varA.asRegister(0), 10),
								               new IRLiteral(varB.asRegister(2), 20),
								               new IRAddrOf(varD.asRegister(4), varC),
								               new IRMemLoad(varC.asRegister(3), varD.asRegister(4))
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
