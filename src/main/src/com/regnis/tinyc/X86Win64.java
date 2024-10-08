package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.io.*;
import java.nio.charset.*;
import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class X86Win64 {

	private static final String INDENTATION = "        ";
	private static final String EMIT = "__emit";
	private static final String PRINT_STRING = "__printString";
	private static final String PRINT_STRING_ZERO = "__printStringZero";
	private static final String PRINT_UINT = "__printUint";

	private final BufferedWriter writer;

	@SuppressWarnings("unused") private boolean debug;
	private int[] localVarOffsets = new int[0];

	public X86Win64(@NotNull BufferedWriter writer) {
		this.writer = writer;
	}

	public void write(IRProgram program) throws IOException {
		writePreample();

		boolean addEmptyLine = false;
		for (IRFunction function : program.functions()) {
			if (addEmptyLine) {
				writeNL();
			}
			write(function);
			addEmptyLine = true;
		}

		writeInit();
		writePostamble(program.globalVars(), program.stringLiterals());
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

		writeIndented("sub rsp, 8");
		writeIndented("  call init");
		writeIndented("add rsp, 8");
		writeIndented("  call @main");
		writeIndented("mov rcx, 0");
		writeIndented("sub rsp, 0x20");
		writeIndented("  call [ExitProcess]");
		writeNL();
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
				              ret
				              """);
	}

	private void writePostamble(List<IRGlobalVar> globalVariables, List<IRStringLiteral> stringLiterals) throws IOException {
		writeEmit();
		writeStringPrint();
		writeUintPrint();
		writeNL();

		writeLines("section '.data' data readable writeable");
		writeIndented("""
				              hStdIn  rb 8
				              hStdOut rb 8
				              hStdErr rb 8""");
		for (IRGlobalVar variable : globalVariables) {
			writeComment("variable " + variable);
			writeIndented(getGlobalVarName(variable.index()) + " rb " + variable.size());
		}
		writeNL();

		if (stringLiterals.size() > 0) {
			writeLines("section '.data' data readable");
			for (IRStringLiteral literal : stringLiterals) {
				final String encoded = encode((literal.text()).getBytes(StandardCharsets.UTF_8));
				writeIndented(getStringLiteralName(literal.index()) + " db " + encoded);
			}
			writeNL();
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
		writeLabel(PRINT_STRING_ZERO);
		writeIndented("mov rdx, rcx");
		writeLabel(PRINT_STRING_ZERO + "_1");
		writeIndented("mov r9l, [rdx]");
		writeIndented("or  r9l, r9l");
		writeIndented("jz " + PRINT_STRING_ZERO + "_2");
		writeIndented("add rdx, 1");
		writeIndented("jmp " + PRINT_STRING_ZERO + "_1");
		writeLabel(PRINT_STRING_ZERO + "_2");
		writeIndented("sub rdx, rcx");

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

	private void write(IRFunction function) throws IOException {
		writeComment(function.toString());
		writeLabel(function.label());

		final List<IRLocalVar> localVars = function.localVars();
		final int size = prepareLocalVars(localVars);
		if (size > 0) {
			writeComment("reserve space for local variables");
			writeIndented("sub rsp, " + size);
		}
		writeInstructions(function.instructions());
		if (size > 0) {
			writeComment("release space for local variables");
			writeIndented("add rsp, " + size);
		}
		localVarOffsets = new int[0];
		writeIndented("ret");
	}

	private int prepareLocalVars(List<IRLocalVar> localVars) {
		localVarOffsets = new int[localVars.size()];
		int i = 0;
		int offset = 0;
		for (IRLocalVar var : localVars) {
			localVarOffsets[i] = offset;
			offset += var.size();
			i++;
		}
		return (offset + 15) / 16 * 16;
	}

	private void writeInstructions(List<IRInstruction> instructions) throws IOException {
		for (IRInstruction instruction : instructions) {
			writeInstruction(instruction);
		}
	}

	private void writeInstruction(IRInstruction instruction) throws IOException {
		switch (instruction) {
		case IRLabel label -> writeLabel(label.label());
		case IRComment comment -> writeComment(comment.comment());
		case IRLoadReg copy -> writeCopy(copy);
		case IRMemLoad load -> writeLoad(load);
		case IRLoadInt load -> writeLoad(load);
		case IRLoadString load -> writeLoadStringLit(load);
		case IRAddrOfVar addrOf -> writeAddrOfVar(addrOf);
		case IRMemStore store -> writeStore(store);
		case IRUnary unary -> writeUnary(unary);
		case IRBinary binary -> writeBinary(binary);
		case IRCompare compare -> writeCompare(compare);
		case IRCast cast -> writeCast(cast);
		case IRMul mul -> writeMul(mul);
		case IRBranch branch -> writeBranch(branch);
		case IRJump jump -> writeJump(jump);
		case IRPrintStringZero print -> writePrintStringZero(print);
		case IRPrintInt print -> writePrintInt(print);
		case IRCall call -> writeCall(call);
		case IRReturnValue ret -> writeReturnValue(ret);
		default -> throw new UnsupportedOperationException(instruction.getClass() + " " + String.valueOf(instruction));
		}
	}

	private void writeCopy(IRLoadReg copy) throws IOException {
		final int size = copy.size();
		writeIndented("mov " + getRegName(copy.targetReg(), size) + ", " + getRegName(copy.sourceReg(), size));
	}

	private void writeLoad(IRLoadInt load) throws IOException {
		writeIndented("mov " + getRegName(load.valueReg(), load.size()) + ", " + load.constant());
	}

	private void writeLoad(IRMemLoad load) throws IOException {
		final String addrRegName = getRegName(load.addrReg());
		final String valueRegName = getRegName(load.valueReg(), load.size());
		writeIndented("mov " + valueRegName + ", [" + addrRegName + "]");
	}

	private void writeLoadStringLit(IRLoadString load) throws IOException {
		writeIndented("lea " + getRegName(load.addrReg()) + ", [" + getStringLiteralName(load.literalIndex()) + "]");
	}

	private void writeAddrOfVar(IRAddrOfVar addrOf) throws IOException {
		final String addrReg = getRegName(addrOf.reg());
		if (addrOf.scope() == VariableScope.global) {
			writeIndented("lea " + addrReg + ", [" + getGlobalVarName(addrOf.index()) + "]");
		}
		else {
			final int offset = localVarOffsets[addrOf.index()];
			writeIndented("lea " + addrReg + ", [rsp+" + offset + "]");
		}
	}

	private void writeStore(IRMemStore store) throws IOException {
		writeIndented("mov [" + getRegName(store.addrReg()) + "], " + getRegName(store.valueReg(), store.size()));
	}

	private void writeUnary(IRUnary unary) throws IOException {
		final String regName = getRegName(unary.valueReg(), unary.size());

		switch (unary.op()) {
		case neg -> writeIndented("neg " + regName);
		case not -> writeIndented("not " + regName);
		case notLog -> {
			writeIndented("or " + regName + ", " + regName);
			writeIndented("sete " + regName);
		}
		default -> throw new UnsupportedOperationException("Unsupported " + unary.op());
		}
	}

	private void writeBinary(IRBinary binary) throws IOException {
		final int targetReg = binary.targetReg();
		final int sourceReg = binary.sourceReg();
		final int size = binary.size();
		final String targetRegName = getRegName(targetReg, size);
		final String sourceRegName = getRegName(sourceReg, size);

		switch (binary.op()) {
		case Add -> writeIndented("add " + targetRegName + ", " + sourceRegName);
		case Sub -> writeIndented("sub " + targetRegName + ", " + sourceRegName);
		case And -> writeIndented("and " + targetRegName + ", " + sourceRegName);
		case Or -> writeIndented("or " + targetRegName + ", " + sourceRegName);
		case Xor -> writeIndented("xor " + targetRegName + ", " + sourceRegName);
		case Multiply -> {
			if (size != 8) {
				writeIndented("movsx " + getRegName(targetReg) + ", " + getRegName(targetReg, size));
				writeIndented("movsx " + getRegName(sourceReg) + ", " + getRegName(sourceReg, size));
			}
			writeIndented("imul " + getRegName(targetReg) + ", " + getRegName(sourceReg));
		}
		default -> throw new UnsupportedOperationException("binary " + binary.op());
		}
	}

	private void writeCompare(IRCompare compare) throws IOException {
		final int size = getTypeSize(compare.type());
		final String leftRegName = getRegName(compare.leftReg(), size);
		final String resultRegName = getRegName(compare.resultReg(), 1);
		writeIndented("cmp " + leftRegName + ", " + getRegName(compare.rightReg(), size));
		writeIndented(switch (compare.op()) {
			case Lt -> "setl";
			case LtEq -> "setle";
			case Equals -> "sete";
			case NotEquals -> "setne";
			case GtEq -> "setge";
			case Gt -> "setg";
			default -> throw new UnsupportedOperationException("Unsupported operand " + compare.op());
		} + " " + resultRegName);
		writeIndented("and " + resultRegName + ", 0xFF");
	}

	private void writeCast(IRCast cast) throws IOException {
		final int sourceSize = getTypeSize(cast.sourceType());
		final int targetSize = getTypeSize(cast.targetType());
		if (targetSize > sourceSize) {
			writeIndented("movzx " + getRegName(cast.targetReg(), targetSize) + ", " + getRegName(cast.sourceReg(), sourceSize));
		}
	}

	private void writeMul(IRMul mul) throws IOException {
		writeIndented("imul " + getRegName(mul.reg()) + ", " + mul.factor());
	}

	private void writeBranch(IRBranch branch) throws IOException {
		final String conditionRegName = getRegName(branch.conditionReg(), 1);
		writeIndented("or " + conditionRegName + ", " + conditionRegName);
		if (branch.jumpOnTrue()) {
			writeIndented("jnz " + branch.label());
		}
		else {
			writeIndented("jz " + branch.label());
		}
	}

	private void writeJump(IRJump jump) throws IOException {
		writeIndented("jmp " + jump.target());
	}

	private void writePrintStringZero(IRPrintStringZero print) throws IOException {
		final String regName = getRegName(print.addrReg());
		writeIndented("sub rsp, 8");
		if (!regName.equals("rcx")) {
			writeIndented("  mov rcx, " + regName);
		}
		writeIndented("  call " + PRINT_STRING_ZERO);
		writeIndented("add rsp, 8");
	}

	private void writePrintInt(IRPrintInt print) throws IOException {
		final String regName = getRegName(print.reg());
		writeIndented("sub rsp, 8");
		if (!regName.equals("rcx")) {
			writeIndented("  mov rcx, " + regName);
		}
		writeIndented("  call " + PRINT_UINT);
		writeIndented("  mov rcx, 0x0a");
		writeIndented("  call " + EMIT);
		writeIndented("add rsp, 8");
	}

	private void writeCall(IRCall call) throws IOException {
		for (IRCall.Arg arg : call.args()) {
			final int reg = arg.reg();
			final int size = getTypeSize(arg.type());
			final String regName = getRegName(reg);
			if (size != 8) {
				writeIndented("movzx rcx, " + getRegName(reg, size));
			}
			else if (!regName.equals("rcx")) {
				writeIndented("mov rcx, " + regName);
			}
		}
		writeIndented("sub rsp, 8");
		writeIndented("  call " + call.label());
		writeIndented("add rsp, 8");
	}

	private void writeReturnValue(IRReturnValue ret) throws IOException {
		final String regName = getRegName(ret.reg());
		if (!regName.equals("rax")) {
			writeIndented("mov rax, " + regName);
		}
	}

	private void writeLabel(String label) throws IOException {
		write(label + ":");
		writeNL();
	}

	private void writeComment(String s) throws IOException {
		writeIndented("; " + s);
	}

	private void writeIndented(String text) throws IOException {
		writeLines(text, INDENTATION);
	}

	private void writeLines(String text) throws IOException {
		writeLines(text, null);
	}

	private void writeLines(String text, @Nullable String leading) throws IOException {
		final String[] lines = text.split("\\r?\\n");
		for (String line : lines) {
			if (leading != null && line.length() > 0) {
				write(leading);
			}
			write(line);
			writeNL();
		}
	}

	private void writeNL() throws IOException {
		write(System.lineSeparator());
	}

	private void write(String text) throws IOException {
		writer.write(text);
		if (debug) {
			System.out.print(text);
		}
	}

	private static String getRegName(int reg) {
		return getRegName(reg, 0);
	}

	private static String getRegName(int reg, int size) {
		return switch (reg) {
			case 0 -> getXRegName('c', size);
			case 1 -> getXRegName('a', size);
			case 2 -> getXRegName('b', size);
			case 3 -> getXRegName('d', size);
			case 4 -> switch (size) {
				case 1 -> "r9b";
				case 2 -> "r9w";
				case 4 -> "r9d";
				default -> "r9";
			};
			default -> throw new IllegalStateException();
		};
	}

	@NotNull
	private static String getXRegName(char chr, int size) {
		return switch (size) {
			case 1 -> chr + "l";
			case 2 -> chr + "x";
			case 4 -> "e" + chr + "x";
			default -> "r" + chr + "x";
		};
	}

	private static int getTypeSize(Type type) {
		if (type.isPointer()) {
			return 8;
		}
		return Type.getSize(type);
	}

	private static String encode(byte[] bytes) {
		final StringBuilder buffer = new StringBuilder();
		boolean stringIsOpen = false;
		for (byte b : bytes) {
			if (b >= 0x20 && b < 0x7f && b != '\'') {
				if (!stringIsOpen) {
					if (buffer.length() > 0) {
						buffer.append(", ");
					}
					buffer.append("'");
					stringIsOpen = true;
				}
				buffer.append((char)b);
			}
			else {
				if (stringIsOpen) {
					buffer.append("'");
					stringIsOpen = false;
				}
				if (buffer.length() > 0) {
					buffer.append(", ");
				}
				buffer.append("0x");
				Utils.toHex(b, 2, buffer);
			}
		}
		if (stringIsOpen) {
			buffer.append("'");
		}
		return buffer.toString();
	}

	private static String getGlobalVarName(int index) {
		return "var" + index;
	}

	private static String getStringLiteralName(int index) {
		return "string_" + index;
	}
}
