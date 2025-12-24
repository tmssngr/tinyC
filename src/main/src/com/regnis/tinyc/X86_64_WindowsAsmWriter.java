package com.regnis.tinyc;

import com.regnis.tinyc.ir.*;

import java.io.*;
import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class X86_64_WindowsAsmWriter extends X86_64_AsmWriter {

	private final int argCountInRegisters;

	public X86_64_WindowsAsmWriter(@NotNull BufferedWriter writer, int argCountInRegisters, @NotNull X86Registers registers) {
		super(writer, registers);
		this.argCountInRegisters = argCountInRegisters;
	}

	public void write(@NotNull IRProgram program) throws IOException {
		writePreample();

		super.write(program);

		writeInit();
		writeNL();
		writePostamble(program.varInfos().vars(), program.stringLiterals());
	}

	@NotNull
	@Override
	protected X86StackOffsets createX86StackOffsets(List<IRVarDef> localVars, List<List<IRVar>> callsArgs, int nonvolatileRegistersToPushPop) {
		return new X86StackOffsets(localVars, callsArgs, argCountInRegisters, nonvolatileRegistersToPushPop);
	}

	private void writePreample() throws IOException {
		writeLines("""
				           format pe64 console
				           include 'win64ax.inc'

				           STD_IN_HANDLE = -10
				           STD_OUT_HANDLE = -11
				           STD_ERR_HANDLE = -12

				           entry start

				           section '.text' code readable executable

				           start:""");
		writeComment("alignment");
		writeIndented("and rsp, -16");
		writeIndented("call init");
		writeIndented("call @main");
		writeIndented("mov rcx, 0");
		writeIndented("sub rsp, 0x20");
		writeIndented("call [ExitProcess]");
		writeNL();
	}

	private void writeInit() throws IOException {
		writeLabel("init");
		// 8 to compensate for the return address; 20h for the shadow space
		writeIndented("""
				              sub rsp, 28h
				                mov rcx, STD_IN_HANDLE
				                call [GetStdHandle]
				                ; handle in rax, 0 if invalid
				                lea rcx, [hStdIn]
				                mov qword [rcx], rax

				                mov rcx, STD_OUT_HANDLE
				                call [GetStdHandle]
				                ; handle in rax, 0 if invalid
				                lea rcx, [hStdOut]
				                mov qword [rcx], rax

				                mov rcx, STD_ERR_HANDLE
				                call [GetStdHandle]
				                ; handle in rax, 0 if invalid
				                lea rcx, [hStdErr]
				                mov qword [rcx], rax
				              add rsp, 28h
				              ret
				              """);
	}

	private void writePostamble(List<IRVarDef> globalVariables, List<IRStringLiteral> stringLiterals) throws IOException {
		writeLines("section '.data' data readable writeable");
		writeIndented("""
				              hStdIn  rb 8
				              hStdOut rb 8
				              hStdErr rb 8""");

		writeGlobalVariables(globalVariables);
		writeNL();

		if (stringLiterals.size() > 0) {
			writeLines("section '.data' data readable");
			writeStringLiterals(stringLiterals);
		}

		writeLines("""
				           section '.idata' import data readable writeable

				           library kernel32,'KERNEL32.DLL',\\
				                   msvcrt,'MSVCRT.DLL'

				           import kernel32,\\
				                  ExitProcess,'ExitProcess',\\
				                  GetStdHandle,'GetStdHandle',\\
				                  SetConsoleCursorPosition,'SetConsoleCursorPosition',\\
				                  WriteFile,'WriteFile'

				           import msvcrt,\\
				                  _getch,'_getch'
				           """);
	}
}
