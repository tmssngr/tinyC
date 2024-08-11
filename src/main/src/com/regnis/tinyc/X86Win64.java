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
			writeFunction(function);
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

	private void writeFunction(IRFunction function) throws IOException {
		writeComment(function.toString());
		writeLabel(function.label());

		final List<String> asmLines = function.asmLines();
		if (asmLines.isEmpty()) {
			final int size = prepareLocalVars(function.localVars());
			writeFunctionProlog(size);

			writeInstructions(function.instructions());

			writeFunctionEpilog(size);
			localVarOffsets = new int[0];
			return;
		}

		for (String line : asmLines) {
			writeLines(line, line.contains(":") ? "" : INDENTATION);
		}
	}

	private int prepareLocalVars(List<IRLocalVar> localVars) {
		localVarOffsets = new int[localVars.size()];
		int argCount = 0;
		int offset = 0;
		int i = 0;
		for (IRLocalVar var : localVars) {
			if (var.isArg()) {
				argCount++;
			}
			else {
				localVarOffsets[i] = offset;
				offset += var.size();
			}
			i++;
		}
		final int localVarSize = alignTo16(offset);
		// first arg 8 bytes
		// second arg 8 bytes
		// third arg 8 bytes
		// fill area 0/8 bytes
		// return address 8 bytes
		// local vars <size> bytes
		int argOffset = alignTo16(argCount * 8) + localVarSize;
		i = 0;
		for (IRLocalVar var : localVars) {
			if (!var.isArg()) {
				break;
			}

			argOffset -= 8;
			localVarOffsets[i] = argOffset;
			i++;
		}
		return localVarSize;
	}

	private void writeFunctionProlog(int size) throws IOException {
		if (size > 0) {
			writeComment("reserve space for local variables");
			writeIndented("sub rsp, " + size);
		}
	}

	private void writeFunctionEpilog(int size) throws IOException {
		if (size > 0) {
			writeComment("release space for local variables");
			writeIndented("add rsp, " + size);
		}
		writeIndented("ret");
	}

	private int alignTo16(int offset) {
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
		case IRLoadReg copy -> writeLoadReg(copy);
		case IRMemLoad load -> writeLoad(load);
		case IRLoadInt load -> writeLoadInt(load);
		case IRLoadString load -> writeLoadString(load);
		case IRAddrOfVar addrOf -> writeAddrOfVar(addrOf);
		case IRMemStore store -> writeStore(store);
		case IRUnary unary -> writeUnary(unary);
		case IRBinary binary -> writeBinary(binary);
		case IRCompare compare -> writeCompare(compare);
		case IRCast cast -> writeCast(cast);
		case IRMul mul -> writeMul(mul);
		case IRBranch branch -> writeBranch(branch);
		case IRJump jump -> writeJump(jump);
		case IRCall call -> writeCall(call);
		case IRReturnValue ret -> writeReturnValue(ret);
		default -> throw new UnsupportedOperationException(instruction.getClass() + " " + String.valueOf(instruction));
		}
	}

	private void writeLoadReg(IRLoadReg copy) throws IOException {
		final int size = copy.size();
		writeIndented("mov " + getRegName(copy.targetReg(), size) + ", " + getRegName(copy.sourceReg(), size));
	}

	private void writeLoadInt(IRLoadInt load) throws IOException {
		writeIndented("mov " + getRegName(load.valueReg(), load.size()) + ", " + load.constant());
	}

	private void writeLoadString(IRLoadString load) throws IOException {
		writeIndented("lea " + getRegName(load.addrReg()) + ", [" + getStringLiteralName(load.literalIndex()) + "]");
	}

	private void writeLoad(IRMemLoad load) throws IOException {
		final String addrRegName = getRegName(load.addrReg());
		final String valueRegName = getRegName(load.valueReg(), load.size());
		writeIndented("mov " + valueRegName + ", [" + addrRegName + "]");
	}

	private void writeAddrOfVar(IRAddrOfVar addrOf) throws IOException {
		final String addrReg = getRegName(addrOf.reg());
		final VariableScope scope = addrOf.scope();
		if (scope == VariableScope.global) {
			writeIndented("lea " + addrReg + ", [" + getGlobalVarName(addrOf.index()) + "]");
		}
		else {
			writeAddressOfLocalVar(addrReg, addrOf.index(), 0);
		}
	}

	private void writeAddressOfLocalVar(String addrReg, int index, int offset) throws IOException {
		offset += localVarOffsets[index];
		writeIndented("lea " + addrReg + ", [rsp+" + offset + "]");
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
		case Mul -> {
			if (size != 8) {
				writeIndented("movsx " + getRegName(targetReg) + ", " + getRegName(targetReg, size));
				writeIndented("movsx " + getRegName(sourceReg) + ", " + getRegName(sourceReg, size));
			}
			writeIndented("imul " + getRegName(targetReg) + ", " + getRegName(sourceReg));
		}
		case Div, Mod -> {
			// https://www.felixcloutier.com/x86/idiv
			// (edx eax) / %reg -> eax
			// (edx eax) % %reg -> edx

			// we can't be 100% sure that other registers are not currently in use, so we need to push/pop them
			if (getRegName(targetReg).equals("rax") && getRegName(sourceReg).equals("rbx")) {
				if (size != 8) { // TODO use movzx for unsigned types
					writeIndented("movsx rax, " + targetRegName);
					writeIndented("movsx rbx, " + sourceRegName);
				}
				writeIndented("cqo"); // rdx := signbit(rax)
				writeIndented("push rdx");
				writeIndented("idiv rbx"); // div-result in rax, remainder in rdx
				if (binary.op() == IRBinary.Op.Mod) {
					writeIndented("mov rax, rdx");
				}
				writeIndented("pop rdx");
			}
			else if (getRegName(targetReg).equals("rbx") && getRegName(sourceReg).equals("rax")) {
				if (size != 8) { // TODO use movzx for unsigned types
					writeIndented("movsx rax, " + sourceRegName);
					writeIndented("movsx rbx, " + targetRegName);
				}
				writeIndented("push rdx");
				writeIndented("mov rdx, rax");
				writeIndented("mov rax, rbx");
				writeIndented("mov rbx, rdx");
				writeIndented("cqo"); // rdx := signbit(rax)
				writeIndented("idiv rbx"); // div-result in rax, remainder in rdx
				if (binary.op() == IRBinary.Op.Mod) {
					writeIndented("mov rbx, rdx");
				}
				else {
					writeIndented("mov rbx, rax");
				}
				writeIndented("pop rdx");
			}
			else if (getRegName(targetReg).equals("rbx") && getRegName(sourceReg).equals("rcx")) {
				if (size != 8) { // TODO use movzx for unsigned types
					writeIndented("movsx rbx, " + targetRegName);
					writeIndented("movsx rcx, " + sourceRegName);
				}
				writeIndented("push rax");
				writeIndented("push rdx");
				writeIndented("mov rax, rbx");
				writeIndented("cqo"); // rdx := signbit(rax)
				writeIndented("idiv rcx"); // div-result in rax, remainder in rdx
				if (binary.op() == IRBinary.Op.Mod) {
					writeIndented("mov rbx, rdx");
				}
				else {
					writeIndented("mov rbx, rax");
				}
				writeIndented("pop rdx");
				writeIndented("pop rax");
			}
			else {
				throw new UnsupportedOperationException("unsupported registers " + targetReg + ", " + sourceReg);
			}
		}
		default -> throw new UnsupportedOperationException("binary " + binary.op());
		}
	}

	private void writeCompare(IRCompare compare) throws IOException {
		final Type type = compare.type();
		final boolean signed = type != Type.U8;
		final int size = getTypeSize(type);
		final String leftRegName = getRegName(compare.leftReg(), size);
		final String resultRegName = getRegName(compare.resultReg(), 1);
		writeIndented("cmp " + leftRegName + ", " + getRegName(compare.rightReg(), size));
		writeIndented(switch (compare.op()) {
			case Lt -> signed ? "setl" : "setb" ; // setb (below) = setc (carry)
			case LtEq -> signed ? "setle" : "setbe";
			case Equals -> "sete";
			case NotEquals -> "setne";
			case GtEq -> signed ? "setge" : "setae"; // setae (above or equal) == setnc (not carry)
			case Gt -> signed ? "setg" : "seta";
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

	private void writeCall(IRCall call) throws IOException {
		final String label = call.label();
		final List<IRCall.Arg> args = call.args();
		final int argsSize = args.size() * 8;
		final int offset = (args.size() + 1) % 2 * 8;
		int localVarOffset = 0;
		for (IRCall.Arg arg : args) {
			final int size = getTypeSize(arg.type());
			final char regChr = 'a';
			final String addrRegName = getXRegName(regChr, 0);
			writeAddressOfLocalVar(addrRegName, arg.localVarIndex(), localVarOffset);
			writeIndented("mov " + getXRegName(regChr, size) + ", [" + addrRegName + "]");
			writeIndented("push " + addrRegName);
			// we have pushed 8 bytes, so the local variables are accessed with an 8 byte larger offset
			localVarOffset += 8;
		}
		if (offset != 0) {
			writeIndented("sub rsp, " + offset);
		}
		writeIndented("  call " + label);
		writeIndented("add rsp, " + (offset + argsSize));
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
			// ofset 0 mean result reg -> rax
			case 0 -> getXRegName('a', size);
			case 1 -> getXRegName('b', size);
			case 2 -> getXRegName('c', size);
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
