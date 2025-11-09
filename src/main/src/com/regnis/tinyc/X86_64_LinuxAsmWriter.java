package com.regnis.tinyc;

import com.regnis.tinyc.ir.*;

import java.io.*;
import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class X86_64_LinuxAsmWriter extends X86_64_AsmWriter {

	public X86_64_LinuxAsmWriter(@NotNull BufferedWriter writer, int argCountInRegisters, @NotNull X86Registers registers) {
		super(writer, argCountInRegisters, registers);
	}

	public void write(@NotNull IRProgram program) throws IOException {
		writePreample();

		super.write(program);

		writePostamble(program.varInfos().vars(), program.stringLiterals());
	}

	private void writePreample() throws IOException {
		writeLines("""
				           format ELF64 executable 3
				           segment executable
				           entry _start

				           _start:""");
		writeIndented("call @main");

		writeIndented("mov rax, 60         ; sys_exit");
		writeIndented("xor rdi, rdi        ; exit code 0");
		writeIndented("syscall");
		writeNL();
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
