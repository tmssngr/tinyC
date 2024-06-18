package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;

import java.io.*;
import java.util.*;

/**
 * @author Thomas Singer
 */
public class X86Win64 {

	private static final String INDENTATION = "        ";
	private static final String EMIT = "__emit";
	private static final String PRINT_STRING = "__printString";
	private static final String PRINT_UINT = "__printUint";

	private final Writer writer;
	private int freeRegs;

	public X86Win64(Writer writer) {
		this.writer = writer;
	}

	public void write(List<AstNode> nodes) throws IOException {
		writePreample();

		final Variables variables = Variables.detectFrom(nodes);

		writeLabel("main");
		for (AstNode node : nodes) {
			write(node, variables);
		}
		writeIndented("ret");

		writePostample(variables);
	}

	private int write(AstNode node, Variables variables) throws IOException {
		switch (node.type()) {
		case IntLit -> {
			final int value = node.value();
			writeComment("int lit " + value);
			final int reg = getFreeReg();
			writeIndented("mov " + getRegName(reg) + ", " + value);
			return reg;
		}
		case Print -> {
			final int reg = write(node.left(), variables);
			final String regName = getRegName(reg);
			writeComment("print");
			if (!regName.equals("rcx")) {
				writeIndented("mov rcx, " + regName);
			}
			writeIndented("sub rsp, 8");
			writeIndented("  call " + PRINT_UINT);
			writeIndented("mov rcx, 0x0a");
			writeIndented("  call " + EMIT);
			writeIndented("add rsp, 8");
			return -1;
		}
		case VarRead -> {
			final String varName = node.text();
			final int reg = getFreeReg();
			final int varIndex = variables.indexOf(varName);
			final String regName = getRegName(reg);
			writeComment("read var ");
			writeIndented("lea " + regName + ", [" + getVarName(varIndex) + "]");
			writeIndented("mov qword " + regName + ", [" + regName + "]");
			return reg;
		}
		case VarLhs -> {
			final String varName = node.text();
			final int reg = getFreeReg();
			final int varIndex = variables.indexOf(varName);
			writeComment("var address " + varName);
			writeIndented("lea " + getRegName(reg) + ", [" + getVarName(varIndex) + "]");
			return reg;
		}
		case Assign -> {
			final int expressionReg = write(node.left(), variables);
			final int varReg = write(node.right(), variables);
			writeComment("assign");
			writeIndented("mov qword [" + getRegName(varReg) + "], " + getRegName(expressionReg));
			freeReg(expressionReg);
			freeReg(varReg);
			return -1;
		}
		case Add -> {
			final int leftReg = write(node.left(), variables);
			final int rightReg = write(node.right(), variables);
			writeComment("add");
			writeIndented("add " + getRegName(leftReg) + ", " + getRegName(rightReg));
			freeReg(rightReg);
			return leftReg;
		}
		case Multiply -> {
			final int leftReg = write(node.left(), variables);
			final int rightReg = write(node.right(), variables);
			writeComment("multiply");
			writeIndented("imul " + getRegName(leftReg) + ", " + getRegName(rightReg));
			freeReg(rightReg);
			return leftReg;
		}
		default -> throw new UnsupportedOperationException(node.toString());
		}
	}

	private int getFreeReg() {
		int mask = 1;
		for (int i = 0; i < 3; i++, mask += mask) {
			if ((freeRegs & mask) == 0) {
				freeRegs |= mask;
				return i;
			}
		}
		throw new IllegalStateException("no free reg");
	}

	private void freeReg(int reg) {
		freeRegs &= ~(1 << reg);
	}

	private void writePreample() throws IOException {
		write("""
				      format pe64 console
				      include 'win64ax.inc'

				      STD_IN_HANDLE = -10
				      STD_OUT_HANDLE = -11
				      STD_ERR_HANDLE = -12

				      entry start

				      section '.text' code readable executable

				      start:""");
		writeIndented("sub rsp, 8");
		writeIndented("  call init");
		writeIndented("add rsp, 8");
		writeIndented("  call main");
		writeIndented("mov rcx, 0");
		writeIndented("sub rsp, 0x20");
		writeIndented("  call [ExitProcess]");
		writeNL();
	}

	private void writePostample(Variables variables) throws IOException {
		writeInit();
		writeEmit();
		writeStringPrint();
		writeUintPrint();
		writeNL();

		write("section '.data' data readable writeable");
		writeIndented("""
				              hStdIn  rb 8
				              hStdOut rb 8
				              hStdErr rb 8""");
		for (int i = 0; i < variables.count(); i++) {
			writeIndented(getVarName(i) + " rb 8");
		}
		writeNL();
		write("""
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

	private String getVarName(int i) {
		return "var" + i;
	}

	private void writeInit() throws IOException {
		writeLabel("init");
		writeIndented("""
				              sub rsp, 20h
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
				              add rsp, 20h
				              ret""");
	}

	private void writeEmit() throws IOException {
		// rcx = char
		writeLabel(EMIT);
		// push char to stack
		// use that address as buffer to print
		// use length 1
		writeIndented("push rcx ; = sub rsp, 8");
		writeIndented("  mov rcx, rsp");
		writeIndented("  mov rdx, 1");
		writeIndented("  call " + PRINT_STRING);
		writeIndented("pop rcx");
		writeIndented("ret");
	}

	private void writeStringPrint() throws IOException {
		// rcx = pointer to text
		// rdx = length
		// BOOL WriteFile(
		//  [in]                HANDLE       hFile,                    rcx
		//  [in]                LPCVOID      lpBuffer,                 rdx
		//  [in]                DWORD        nNumberOfBytesToWrite,    r8
		//  [out, optional]     LPDWORD      lpNumberOfBytesWritten,   r9
		//  [in, out, optional] LPOVERLAPPED lpOverlapped              stack
		//);
		writeLabel(PRINT_STRING);
		writeIndented("""
				              mov     rdi, rsp
				              and     spl, 0xf0

				              mov     r8, rdx
				              mov     rdx, rcx
				              lea     rcx, [hStdOut]
				              mov     rcx, qword [rcx]
				              xor     r9, r9
				              push    0
				                sub     rsp, 20h
				                  call    [WriteFile]
				                add     rsp, 20h
				              ; add     rsp, 8
				              mov     rsp, rdi
				              ret
				              """);
	}

	private void writeUintPrint() throws IOException {
		// input: rcx
		// rsp+0   = buf (20h long)
		// rsp+20h = pos
		// rsp+24h = x
		writeLabel(PRINT_UINT);
		writeIndented("""
				              push   rbp
				              mov    rbp,rsp
				              sub    rsp, 50h
				              mov    qword [rsp+24h], rcx

				              ; int pos = sizeof(buf);
				              mov    ax, 20h
				              mov    word [rsp+20h], ax

				              ; do {
				              """);
		writeLabel(".print");
		writeIndented("""
				              ; pos--;
				              mov    ax, word [rsp+20h]
				              dec    ax
				              mov    word [rsp+20h], ax

				              ; int remainder = x mod 10;
				              ; x = x / 10;
				              mov    rax, qword [rsp+24h]
				              mov    ecx, 10
				              xor    edx, edx
				              div    ecx
				              mov    qword [rsp+24h], rax

				              ; int digit = remainder + '0';
				              add    dl, '0'

				              ; buf[pos] = digit;
				              mov    ax, word [rsp+20h]
				              movzx  rax, ax
				              lea    rcx, qword [rsp]
				              add    rcx, rax
				              mov    byte [rcx], dl

				              ; } while (x > 0);
				              mov    rax, qword [rsp+24h]
				              cmp    rax, 0
				              ja     .print

				              ; rcx = &buf[pos]

				              ; rdx = sizeof(buf) - pos
				              mov    ax, word [rsp+20h]
				              movzx  rax, ax
				              mov    rdx, 20h
				              sub    rdx, rax

				              ;sub    rsp, 8  not necessary because initial push rbp""");
		writeIndented("  call   " + PRINT_STRING);
		writeIndented("""
				              ;add    rsp, 8
				              leave ; Set SP to BP, then pop BP
				              ret
				              """);
	}

	private void writeLabel(String label) throws IOException {
		writer.write(label + ":");
		writeNL();
	}

	private void writeComment(String s) throws IOException {
		writeIndented("; " + s);
	}

	private void writeIndented(String text) throws IOException {
		writeLines(text, INDENTATION);
	}

	private void write(String text) throws IOException {
		writeLines(text, null);
	}

	private void writeLines(String text, String leading) throws IOException {
		final String[] lines = text.split("\\r?\\n");
		for (String line : lines) {
			if (leading != null && line.length() > 0) {
				writer.write(leading);
			}
			writer.write(line);
			writeNL();
		}
	}

	private void writeNL() throws IOException {
		writer.write(System.lineSeparator());
	}

	private static String getRegName(int reg) {
		return switch (reg) {
			case 0 -> "rcx";
			case 1 -> "rax";
			case 2 -> "rbx";
			default -> throw new IllegalStateException();
		};
	}
}