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
public final class X86Win64 extends AsmWriter {

	private final TrivialRegisterAllocator allocator = new TrivialRegisterAllocator();

	@SuppressWarnings("unused") private boolean debug;
	private int[] localVarOffsets = new int[0];
	private int rspOffset;

	public X86Win64(@NotNull BufferedWriter writer) {
		super(writer);
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

		for (IRAsmFunction function : program.asmFunctions()) {
			if (addEmptyLine) {
				writeNL();
			}
			writeAsmFunction(function);
			addEmptyLine = true;
		}

		writeInit();
		writePostamble(program.varInfos().vars(), program.stringLiterals());
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

	private void writePostamble(List<IRVarDef> globalVariables, List<IRStringLiteral> stringLiterals) throws IOException {
		writeNL();

		writeLines("section '.data' data readable writeable");
		writeIndented("""
				              hStdIn  rb 8
				              hStdOut rb 8
				              hStdErr rb 8""");
		for (IRVarDef variable : globalVariables) {
			writeComment("variable " + variable.getString());
			writeIndented(getGlobalVarName(variable.var().index()) + " rb " + variable.size());
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

		final List<IRVarDef> localVars = function.varInfos().vars();
		final int size = prepareLocalVarsOffsets(localVars);
		writeVarOffsets(localVars);
		writeLabel(function.label());
		writeFunctionProlog(size);

		writeInstructions(function.instructions());

		writeFunctionEpilog(size);
		localVarOffsets = new int[0];
	}

	private int prepareLocalVarsOffsets(List<IRVarDef> localVars) {
		localVarOffsets = new int[localVars.size()];
		int argCount = 0;
		int offset = 0;
		int i = 0;
		for (IRVarDef var : localVars) {
			if (var.var().scope() == VariableScope.argument) {
				argCount++;
			}
			else {
				final int varSize = var.size();
				offset = alignTo(offset, varSize);
				localVarOffsets[i] = offset;
				offset += varSize;
			}
			i++;
		}
		final int localVarSize = alignTo16(offset);
		// first arg 8 bytes
		// second arg 8 bytes
		// third arg 8 bytes
		// fill area 0/8 bytes
		// return address 8 bytes ----------------------
		// local vars <localVarSize> bytes              v
		int argOffset = alignTo16(argCount * 8 + 8) + localVarSize;
		i = 0;
		for (IRVarDef var : localVars) {
			final VariableScope scope = var.var().scope();
			if (scope != VariableScope.argument) {
				Utils.assertTrue(scope == VariableScope.function);
				break;
			}

			argOffset -= 8;
			localVarOffsets[i] = argOffset;
			i++;
		}

		return localVarSize;
	}

	private void writeVarOffsets(List<IRVarDef> localVars) throws IOException {
		for (IRVarDef varDef : localVars) {
			final IRVar var = varDef.var();
			if (var.scope() == VariableScope.argument) {
				writeComment("  rsp+" + localVarOffsets[var.index()] + ": arg " + var.name());
			}
			else {
				Utils.assertTrue(var.scope() == VariableScope.function);
				writeComment("  rsp+" + localVarOffsets[var.index()] + ": var " + var.name());
			}
		}
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

	protected void writeInstruction(IRInstruction instruction) throws IOException {
		Utils.assertTrue(allocator.isNoneUsed());
		super.writeInstruction(instruction);
		Utils.assertTrue(allocator.isNoneUsed(), instruction + ": not all regs freed");
	}

	protected void writeAddrOf(IRAddrOf addrOf) throws IOException {
		final int addrReg = addrOf(addrOf.source());
		storeVar(addrOf.target(), addrReg);
		free(addrReg);
	}

	protected void writeAddrOfArray(IRAddrOfArray addrOf) throws IOException {
		final int addrReg = addrOf(addrOf.array());
		storeVar(addrOf.addr(), addrReg);
		free(addrReg);
	}

	protected void writeBinary(IRBinary binary) throws IOException {
		final boolean signed = binary.left().type() != Type.U8;
		switch (binary.op()) {
		case Add -> writeBinary("add", binary);
		case Sub -> writeBinary("sub", binary);
		case Mul -> {
			final int leftReg = loadVar(binary.left());
			final String leftRegName = getRegName(leftReg);
			final int rightReg = loadVar(binary.right());
			final String rightRegName = getRegName(rightReg);
			if (getTypeSize(binary.left().type()) != 8) {
				writeMovx(leftRegName, leftReg, binary.left(), true);
			}
			if (getTypeSize(binary.right().type()) != 8) {
				writeMovx(rightRegName, rightReg, binary.right(), true);
			}
			writeIndented("imul " + " " + leftRegName + ", " + rightRegName);
			storeVar(binary.target(), leftReg);
			free(rightReg);
			free(leftReg);
		}
		case Div, Mod -> {
			final Type type = binary.left().type();
			Utils.assertTrue(Objects.equals(type, binary.right().type()));
			final int size = getTypeSize(type);
			// https://www.felixcloutier.com/x86/idiv
			// (edx eax) / %reg -> eax
			// (edx eax) % %reg -> edx
			final int leftReg = loadVar(binary.left());
			final String leftRegName = getRegName(leftReg);
			Utils.assertTrue("rbx".equals(leftRegName));

			final int rightReg = loadVar(binary.right());
			final String rightRegName = getRegName(rightReg);
			Utils.assertTrue("rcx".equals(rightRegName));

			final int rax = getFreeReg();
			Utils.assertTrue("rax".equals(getRegName(rax)));

			if (size == 8) {
				writeIndented("mov rax, " + leftRegName);
			}
			else if (type.equals(Type.U8)) {
				writeIndented("movzx rax, " + getRegName(leftReg, size));
				writeIndented("movzx rcx, " + getRegName(rightReg, size));
			}
			else {
				writeMovx("rax", leftReg, binary.left(), signed);
				writeMovx("rcx", rightReg, binary.right(), signed);
			}
			writeIndented("cqo"); // rdx := signbit(rax)
			writeIndented("idiv " + rightRegName);
			writeIndented("mov rbx, " + (binary.op() == IRBinary.Op.Mod ? "rdx" : "rax"));
			storeVar(binary.target(), leftReg);
			free(rax);
			free(rightReg);
			free(leftReg);
		}

		case ShiftLeft -> {
			final int leftReg = loadVar(binary.left());
			final String leftRegName = getRegName(leftReg, binary.left());
			final int rightReg = loadVar(binary.right());
			final String rightRegName = getRegName(rightReg, 1);
			Utils.assertTrue("cl".equals(rightRegName));
			if (signed) {
				writeIndented("sal" + " " + leftRegName + ", cl");
			}
			else {
				writeIndented("shl" + " " + leftRegName + ", cl");
			}
			storeVar(binary.target(), leftReg);
			free(rightReg);
			free(leftReg);
		}
		case ShiftRight -> {
			final int leftReg = loadVar(binary.left());
			final String leftRegName = getRegName(leftReg, binary.left());
			final int rightReg = loadVar(binary.right());
			final String rightRegName = getRegName(rightReg, 1);
			Utils.assertTrue("cl".equals(rightRegName));
			if (signed) {
				writeIndented("sar" + " " + leftRegName + ", cl");
			}
			else {
				writeIndented("shr" + " " + leftRegName + ", cl");
			}
			storeVar(binary.target(), leftReg);
			free(rightReg);
			free(leftReg);
		}

		case And -> writeBinary("and", binary);
		case Or -> writeBinary("or", binary);
		case Xor -> writeBinary("xor", binary);

		default -> throw new UnsupportedOperationException(String.valueOf(binary));
		}
	}

	protected void writeBranch(IRBranch branch) throws IOException {
		final int conditionReg = loadVar(branch.conditionVar());
		final String conditionRegName = getRegName(conditionReg, 1);
		writeIndented("or " + conditionRegName + ", " + conditionRegName);
		free(conditionReg);
		if (branch.jumpOnTrue()) {
			writeIndented("jnz " + branch.target());
		}
		else {
			writeIndented("jz " + branch.target());
		}
	}

	protected void writeCall(IRCall call) throws IOException {
		final List<IRVar> args = call.args();
		final int argsSize = args.size() * 8;
		final int offset = (args.size() + 1) % 2 * 8;
		for (IRVar arg : args) {
			final int argValue = loadVar(arg);
			writeIndented("push " + getRegName(argValue));
			free(argValue);
			this.rspOffset += 8;
		}
		this.rspOffset = 0;

		if (offset != 0) {
			writeIndented("sub rsp, " + offset);
		}
		writeIndented("  call @" + call.name());
		writeIndented("add rsp, " + (offset + argsSize));

		final IRVar target = call.target();
		if (target != null) {
			final int valueReg = getFreeReg();
			Utils.assertTrue("rax".equals(getRegName(valueReg)));
			storeVar(target, valueReg);
			free(valueReg);
		}
	}

	protected void writeCast(IRCast cast) throws IOException {
		final int valueReg = loadVar(cast.source());
		final int sourceSize = getTypeSize(cast.source().type());
		final int targetSize = getTypeSize(cast.target().type());
		if (targetSize > sourceSize) {
			writeIndented("movzx " + getRegName(valueReg, targetSize) + ", " + getRegName(valueReg, sourceSize));
		}
		storeVar(cast.target(), valueReg);
		free(valueReg);
	}

	protected void writeCompare(IRCompare compare) throws IOException {
		final boolean signed = compare.left().type() != Type.U8;
		switch (compare.op()) {
		case Lt -> writeCompare(signed ? "setl" : "setb", compare); // setb (below) = setc (carry)
		case LtEq -> writeCompare(signed ? "setle" : "setbe", compare);
		case Equals -> writeCompare("sete", compare);
		case NotEquals -> writeCompare("setne", compare);
		case GtEq -> writeCompare(signed ? "setge" : "setae", compare); // setae (above or equal) = setnc (not carry)
		case Gt -> writeCompare(signed ? "setg" : "seta", compare); // seta (above)

		default -> throw new UnsupportedOperationException(String.valueOf(compare));
		}
	}

	protected void writeMove(IRMove copy) throws IOException {
		final int valueReg = loadVar(copy.source());
		storeVar(copy.target(), valueReg);
		free(valueReg);
	}

	protected void writeLiteral(IRLiteral literal) throws IOException {
		final int valueReg = getFreeReg();
		writeIndented("mov " + getRegName(valueReg, literal.target()) + ", " + literal.value());
		storeVar(literal.target(), valueReg);
		free(valueReg);
	}

	protected void writeMemLoad(IRMemLoad load) throws IOException {
		final int addrReg = loadVar(load.addr());
		final String addrRegName = getRegName(addrReg);
		final int valueReg = getFreeReg();
		writeIndented("mov " + getRegName(valueReg, load.target()) + ", [" + addrRegName + "]");
		free(addrReg);
		storeVar(load.target(), valueReg);
		free(valueReg);
	}

	protected void writeMemStore(IRMemStore store) throws IOException {
		final int addrReg = loadVar(store.addr());
		final String addrRegName = getRegName(addrReg);
		final int valueReg = loadVar(store.value());
		writeIndented("mov [" + addrRegName + "], " + getRegName(valueReg, store.value()));
		free(valueReg);
		free(addrReg);
	}

	protected void writeRetValue(IRRetValue retValue) throws IOException {
		final int valueReg = loadVar(retValue.var());
		writeIndented("mov rax, " + getRegName(valueReg));
		free(valueReg);
	}

	protected void writeString(IRString literal) throws IOException {
		final int valueReg = getFreeReg();
		writeIndented("lea " + getRegName(valueReg) + ", [" + getStringLiteralName(literal.stringIndex()) + "]");
		storeVar(literal.target(), valueReg);
		free(valueReg);
	}

	protected void writeUnary(IRUnary unary) throws IOException {
		switch (unary.op()) {
		case Neg -> {
			final int valueReg = loadVar(unary.source());
			writeIndented("neg " + getRegName(valueReg));
			storeVar(unary.target(), valueReg);
			free(valueReg);
		}
		case Not -> {
			final int valueReg = loadVar(unary.source());
			writeIndented("not " + getRegName(valueReg));
			storeVar(unary.target(), valueReg);
			free(valueReg);
		}
		case NotLog -> {
			final int valueReg = loadVar(unary.source());
			final String regName = getRegName(valueReg, unary.source());
			writeIndented("or " + regName + ", " + regName);
			writeIndented("sete " + regName);
			storeVar(unary.target(), valueReg);
			free(valueReg);
		}
		default -> throw new UnsupportedOperationException(String.valueOf(unary));
		}
	}

	private void writeBinary(String op, IRBinary binary) throws IOException {
		final int leftReg = loadVar(binary.left());
		final String leftRegName = getRegName(leftReg, binary.left());
		final int rightReg = loadVar(binary.right());
		final String rightRegName = getRegName(rightReg, binary.right());
		writeIndented(op + " " + leftRegName + ", " + rightRegName);
		storeVar(binary.target(), leftReg);
		free(rightReg);
		free(leftReg);
	}

	private void writeCompare(String command, IRCompare compare) throws IOException {
		final int leftReg = loadVar(compare.left());
		final String leftRegName = getRegName(leftReg, compare.left());
		final int rightReg = loadVar(compare.right());
		final String rightRegName = getRegName(rightReg, compare.right());
		writeIndented("cmp " + leftRegName + ", " + rightRegName);
		writeIndented(command + " " + getRegName(leftReg, 1));
		storeVar(compare.target(), leftReg);
		free(rightReg);
		free(leftReg);
	}

	private void writeMovx(String targetRegName, int sourceReg, IRVar sourceVar, boolean signed) throws IOException {
		final String signedString = signed ? "s" : "z";
		final String op = getTypeSize(sourceVar.type()) == 4 ? "xd" : "x";
		writeIndented("mov" + signedString + op + " " + targetRegName + ", " + getRegName(sourceReg, sourceVar));
	}

	private void storeVar(IRVar var, int valueReg) throws IOException {
		final int addrReg = addrOf(var);
		final String addRegName = getRegName(addrReg);

		final String valueRegName = getRegName(valueReg, var);
		writeIndented("mov [" + addRegName + "], " + valueRegName);

		free(addrReg);
	}

	private int loadVar(IRVar var) throws IOException {
		final int addrReg = addrOf(var);
		final String addRegName = getRegName(addrReg);

		final int valueReg = getFreeReg();
		final String valueRegName = getRegName(valueReg, var);
		writeIndented("mov " + valueRegName + ", [" + addRegName + "]");

		free(addrReg);
		return valueReg;
	}

	private int addrOf(IRVar var) throws IOException {
		final int addrReg = getFreeReg();
		final String addr = getRegName(addrReg);
		if (var.scope() == VariableScope.global) {
			writeIndented("lea " + addr + ", [" + getGlobalVarName(var.index()) + "]");
		}
		else {
			final int offset = localVarOffsets[var.index()] + rspOffset;
			writeIndented("lea " + addr + ", [rsp+" + offset + "]");
		}
		return addrReg;
	}

	private int getFreeReg() {
		return allocator.allocate();
	}

	private void free(int addrReg) {
		allocator.free(addrReg);
	}

	protected void writeJump(IRJump jump) throws IOException {
		writeIndented("jmp " + jump.label());
	}

	@NotNull
	private String getRegName(int valueReg, IRVar var) {
		return getRegName(valueReg, getTypeSize(var.type()));
	}

	private static int alignTo16(int offset) {
		return alignTo(offset, 16);
	}

	private static int alignTo(int offset, int alignment) {
		return (offset + alignment - 1) / alignment * alignment;
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
		return "var_" + index;
	}

	private static String getStringLiteralName(int index) {
		return "string_" + index;
	}

	private static class TrivialRegisterAllocator {

		private static final int MAX_REGISTERS = 4;

		private int freeRegs;

		@Override
		public String toString() {
			final StringBuilder buffer = new StringBuilder();
			buffer.append("used: ");
			int mask = 1;
			boolean first = true;
			for (int i = 0; i < MAX_REGISTERS; i++, mask += mask) {
				if ((freeRegs & mask) != 0) {
					if (first) {
						first = false;
					}
					else {
						buffer.append(", ");
					}
					buffer.append(i);
				}
			}
			if (first) {
				buffer.append("none");
			}
			return buffer.toString();
		}

		public int allocate() {
			int mask = 1;
			for (int i = 0; i < MAX_REGISTERS; i++, mask += mask) {
				if ((freeRegs & mask) == 0) {
					freeRegs |= mask;
					return i;
				}
			}
			throw new IllegalStateException("no free reg");
		}

		public void free(int reg) {
			final int mask = 1 << reg;
			Utils.assertTrue((freeRegs & mask) != 0);
			freeRegs ^= mask;
		}

		public boolean isNoneUsed() {
			return freeRegs == 0;
		}
	}
}
