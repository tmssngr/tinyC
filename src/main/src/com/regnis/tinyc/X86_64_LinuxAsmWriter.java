package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.io.*;
import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class X86_64_LinuxAsmWriter extends X86_64_AsmWriter {

	private final int argCountInRegisters;

	public X86_64_LinuxAsmWriter(@NotNull BufferedWriter writer, int argCountInRegisters, @NotNull X86Registers registers, @NotNull TypeChecker.CanonicalNameProvider canonicalNameProvider) {
		super(writer, registers, canonicalNameProvider);
		this.argCountInRegisters = argCountInRegisters;
	}

	public void write(@NotNull IRProgram program) throws IOException {
		writePreample();

		super.write(program);

		writePostamble(program.varInfos().vars(), program.stringLiterals());
	}

	@NotNull
	@Override
	protected X86StackOffsets createX86StackOffsets(List<IRVarDef> localVars, List<List<IRVar>> callsArgs, int nonvolatileRegistersToPushPop) {
		return X86StackOffsets.createLinuxInstance(localVars, callsArgs, argCountInRegisters, nonvolatileRegistersToPushPop);
	}

	private void writePreample() throws IOException {
		writeLines("""
				           format ELF64 executable 3
				           segment executable
				           entry _start

				           _start:""");
		writeIndented("call " + canonicalNameProvider.canonicalFunctionName("main", List.of()));

		writeIndented("mov rax, 60         ; sys_exit");
		writeIndented("xor rdi, rdi        ; exit code 0");
		writeIndented("syscall");
	}

	private void writePostamble(List<IRVarDef> globalVariables, List<IRStringLiteral> stringLiterals) throws IOException {
		writeNL();

		if (globalVariables.size() > 0) {
			writeLines("segment readable writable");
			writeGlobalVariables(globalVariables);
			writeNL();
		}

		if (stringLiterals.size() > 0) {
			writeLines("segment readable");
			writeStringLiterals(stringLiterals);
		}
	}
}
