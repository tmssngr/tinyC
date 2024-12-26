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
	private static final int TMP_REG = 0;

	private final BufferedWriter writer;

	@SuppressWarnings("unused") private boolean debug;
	private int[] localVarOffsets = new int[0];
	private int rspOffset;

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

	private void writeAsmFunction(IRAsmFunction function) throws IOException {
		writeComment(function.toString());

		writeLabel(function.label());
		for (String line : function.asmLines()) {
			writeLines(line, line.contains(":") ? "" : INDENTATION);
		}
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

	private void writeInstructions(List<IRInstruction> instructions) throws IOException {
		for (IRInstruction instruction : instructions) {
			writeInstruction(instruction);
		}
	}

	private void writeInstruction(IRInstruction instruction) throws IOException {
		if (!(instruction instanceof IRComment)
		    && !(instruction instanceof IRLabel)
		    && !(instruction instanceof IRJump)) {
			writeComment(String.valueOf(instruction));
		}

		switch (instruction) {
		case IRAddrOf addrOf -> writeAddrOf(addrOf);
		case IRAddrOfArray addrOf -> writeAddrOfArray(addrOf);
		case IRBinary binary -> writeBinary(binary);
		case IRBranch branch -> writeBranch(branch);
		case IRCall call -> writeCall(call);
		case IRCast cast -> writeCast(cast);
		case IRComment comment -> writeComment(comment.comment());
		case IRCompare compare -> writeCompare(compare);
		case IRJump jump -> writeJump(jump);
		case IRLabel label -> writeLabel(label.label());
		case IRLiteral literal -> writeLiteral(literal);
		case IRMemLoad load -> writeLoad(load);
		case IRMemStore store -> writeStore(store);
		case IRMove copy -> writeCopy(copy);
		case IRRetValue retValue -> writeRetValue(retValue);
		case IRString literal -> writeString(literal);
		case IRUnary unary -> writeUnary(unary);
		default -> throw new UnsupportedOperationException(instruction.getClass() + " " + instruction);
		}
	}

	private void writeAddrOf(IRAddrOf addrOf) throws IOException {
		final int addrReg = getRegisterVarRegisterIndex(addrOf.target());
		addrOf(addrReg, addrOf.source());
	}

	private void writeAddrOfArray(IRAddrOfArray addrOf) throws IOException {
		final IRVar arrayOrPointer = addrOf.array();
		Utils.assertTrue(arrayOrPointer.scope() != VariableScope.register);
		final IRVar target = addrOf.addr();
		final int targetReg = getRegisterVarRegisterIndex(target);
		addrOf(targetReg, arrayOrPointer);
	}

	private void writeLiteral(IRLiteral literal) throws IOException {
		final IRVar target = literal.target();
		final int value = literal.value();
		writeIndented("mov " + getRegName(target) + ", " + value);
	}

	private void writeString(IRString literal) throws IOException {
		writeIndented("lea " + getRegName(literal.target()) + ", [" + getStringLiteralName(literal.stringIndex()) + "]");
	}

	private void writeCopy(IRMove copy) throws IOException {
		final IRVar source = copy.source();
		final IRVar target = copy.target();
		final int addrReg = TMP_REG;
		if (source.scope() == VariableScope.register) {
			if (target.scope() == VariableScope.register) {
				writeIndented("mov " + getRegName(target) + ", " + getRegName(copy.source()));
				return;
			}

			addrOf(addrReg, target);
			writeIndented("mov [" + getRegName(addrReg) + "], " + getRegName(source));
			return;
		}

		Utils.assertTrue(target.scope() == VariableScope.register);
		addrOf(addrReg, source);
		writeIndented("mov " + getRegName(target) + ", [" + getRegName(addrReg) + "]");
	}

	private void writeBinary(IRBinary binary) throws IOException {
		final boolean signed = binary.left().type() != Type.U8;
		switch (binary.op()) {
		case Add -> writeBinary("add", binary);
		case Sub -> writeBinary("sub", binary);
		case Mul -> {
			final int leftReg = getRegisterVarRegisterIndex(binary.left());
			final String leftRegName = getRegName(leftReg);
			final int rightReg = getRegisterVarRegisterIndex(binary.right());
			final String rightRegName = getRegName(rightReg);
			final int targetReg = getRegisterVarRegisterIndex(binary.target());
			final String targetRegName = getRegName(targetReg);
			if (getTypeSize(binary.left().type()) != 8) {
				writeMovx(leftRegName, leftReg, binary.left(), true);
			}

			if (getTypeSize(binary.right().type()) != 8) {
				writeMovx(rightRegName, rightReg, binary.right(), true);
			}

			if (targetReg == leftReg) {
				writeIndented("imul " + " " + leftRegName + ", " + rightRegName);
			}
			else {
				// maybe combine with movsx above
				writeIndented("mov rax, " + leftRegName);
				writeIndented("imul rax, " + rightRegName);
				writeIndented("mov " + targetRegName + ", rax");
			}
		}
		case Div, Mod -> {
			final Type type = binary.left().type();
			Utils.assertTrue(Objects.equals(type, binary.right().type()));
			final int size = getTypeSize(type);
			// https://www.felixcloutier.com/x86/idiv
			// (rdx rax) / %reg -> rax
			// (rdx rax) % %reg -> rdx
			final int leftReg = getRegisterVarRegisterIndex(binary.left());
			final String leftRegName = getRegName(leftReg);
			final int rightReg = getRegisterVarRegisterIndex(binary.right());
			final String rightRegName = getRegName(rightReg);
			final int targetReg = getRegisterVarRegisterIndex(binary.target());
			final String targetRegName = getRegName(targetReg);

			final int rdx = 3;
			Utils.assertTrue("rdx".equals(getRegName(rdx)));
			final boolean pushPopRdx = targetReg != rdx;
			if (pushPopRdx) {
				writeIndented("push rdx");
			}

			if (size == 8) {
				writeIndented("mov rax, " + leftRegName);
				writeIndented("mov rbx, " + rightRegName);
			}
			else {
				writeMovx("rax", leftReg, binary.left(), signed);
				writeMovx("rbx", rightReg, binary.right(), signed);
			}
			writeIndented("cqo"); // rdx := signbit(rax)
			writeIndented("idiv rbx");
			if (pushPopRdx) {
				writeIndented("mov " + targetRegName + ", " + (binary.op() == IRBinary.Op.Mod ? "rdx" : "rax"));
				writeIndented("pop rdx");
			}
			else if (binary.op() == IRBinary.Op.Div) {
				writeIndented("mov " + targetRegName + ", rax");
			}
		}

		case ShiftLeft, ShiftRight -> {
			final String op = binary.op() == IRBinary.Op.ShiftRight
					? signed ? "sar" : "shr"
					: signed ? "sal" : "shl";

			final int leftReg = getRegisterVarRegisterIndex(binary.left());
			final String leftRegName = getRegName(leftReg, binary.left());
			final int rightReg = getRegisterVarRegisterIndex(binary.right());
			final int targetReg = getRegisterVarRegisterIndex(binary.target());
			final String targetRegName = getRegName(targetReg, binary.target());

			final int cl = 2;
			Utils.assertTrue("cl".equals(getRegName(cl, 1)));
			final int tmpReg = TMP_REG;
			final String tmpRegName = getRegName(tmpReg, binary.left());
			if (targetReg == cl) {
				writeIndented("mov " + tmpRegName + ", " + leftRegName);
				if (targetReg != rightReg) {
					writeIndented("mov " + targetRegName + ", " + getRegName(rightReg, binary.right()));
				}
				writeIndented(op + " " + tmpRegName + ", cl");
				writeIndented("mov " + targetRegName + ", " + tmpRegName);
			}
			else {
				writeIndented("mov rbx, rcx");
				writeIndented("mov " + tmpRegName + ", " + leftRegName);
				if (rightReg != cl) {
					writeIndented("mov cl, " + getRegName(rightReg, 1));
				}
				writeIndented(op + " " + tmpRegName + ", cl");
				writeIndented("mov " + targetRegName + ", " + tmpRegName);
				writeIndented("mov rcx, rbx");
			}
		}

		case And -> writeBinary("and", binary);
		case Or -> writeBinary("or", binary);
		case Xor -> writeBinary("xor", binary);

		default -> throw new UnsupportedOperationException(String.valueOf(binary));
		}
	}

	private void writeBinary(String op, IRBinary binary) throws IOException {
		final IRVar left = binary.left();
		final IRVar target = binary.target();
		final int leftReg = getRegisterVarRegisterIndex(left);
		final String leftRegName = getRegName(leftReg, left);
		final int rightReg = getRegisterVarRegisterIndex(binary.right());
		final String rightRegName = getRegName(rightReg, binary.right());
		final int targetReg = getRegisterVarRegisterIndex(target);
		final String targetRegName = getRegName(targetReg, left);
		if (targetReg == leftReg) {
			writeIndented(op + " " + targetRegName + ", " + rightRegName);
		}
		else if (targetReg == rightReg) {
			final String tmpRegName = getRegName(TMP_REG, target);
			writeIndented("mov " + tmpRegName + ", " + leftRegName);
			writeIndented(op + " " + tmpRegName + ", " + rightRegName);
			writeIndented("mov " + targetRegName + ", " + tmpRegName);
		}
		else {
			writeIndented("mov " + targetRegName + ", " + leftRegName);
			writeIndented(op + " " + targetRegName + ", " + rightRegName);
		}
	}

	private void writeCompare(IRCompare compare) throws IOException {
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

	private void writeCompare(String command, IRCompare compare) throws IOException {
		final int leftReg = getRegisterVarRegisterIndex(compare.left());
		final String leftRegName = getRegName(leftReg, compare.left());
		final int rightReg = getRegisterVarRegisterIndex(compare.right());
		final String rightRegName = getRegName(rightReg, compare.right());
		final int targetReg = getRegisterVarRegisterIndex(compare.target());
		writeIndented("cmp " + leftRegName + ", " + rightRegName);
		writeIndented(command + " " + getRegName(targetReg, 1));
	}

	private void writeUnary(IRUnary unary) throws IOException {
		switch (unary.op()) {
		case Neg, Not -> {
			final int valueReg = getRegisterVarRegisterIndex(unary.source());
			final int targetReg = getRegisterVarRegisterIndex(unary.target());
			final String targetRegName = getRegName(targetReg);
			if (valueReg != targetReg) {
				writeIndented("mov " + targetRegName + ", " + getRegName(valueReg));
			}

			if (unary.op() == IRUnary.Op.Neg) {
				writeIndented("neg " + targetRegName);
			}
			else {
				writeIndented("not " + targetRegName);
			}
		}
		case NotLog -> {
			final int valueReg = getRegisterVarRegisterIndex(unary.source());
			final String regName = getRegName(valueReg, unary.source());
			writeIndented("or " + regName + ", " + regName);
			writeIndented("sete " + getRegName(unary.target()));
		}
		default -> throw new UnsupportedOperationException(String.valueOf(unary));
		}
	}

	private void writeCast(IRCast cast) throws IOException {
		final IRVar source = cast.source();
		final IRVar target = cast.target();
		final int sourceReg = getRegisterVarRegisterIndex(source);
		final int targetReg = getRegisterVarRegisterIndex(target);
		final int sourceSize = getTypeSize(source.type());
		final int targetSize = getTypeSize(target.type());
		if (targetSize > sourceSize) {
			writeIndented("movzx " + getRegName(targetReg, targetSize) + ", " + getRegName(sourceReg, sourceSize));
		}
		else if (sourceReg != targetReg) {
			writeIndented("mov " + getRegName(targetReg, targetSize) + ", " + getRegName(sourceReg, sourceSize));
		}
	}

	private void writeLoad(IRMemLoad load) throws IOException {
		final int addrReg = getRegisterVarRegisterIndex(load.addr());
		writeIndented("mov " + getRegName(load.target()) + ", [" + getRegName(addrReg) + "]");
	}

	private void writeStore(IRMemStore store) throws IOException {
		final int addrReg = getRegisterVarRegisterIndex(store.addr());
		writeIndented("mov [" + getRegName(addrReg) + "], " + getRegName(store.value()));
	}

	private void writeBranch(IRBranch branch) throws IOException {
		final int conditionReg = getRegisterVarRegisterIndex(branch.conditionVar());
		final String conditionRegName = getRegName(conditionReg, 1);
		writeIndented("or " + conditionRegName + ", " + conditionRegName);
		if (branch.jumpOnTrue()) {
			writeIndented("jnz " + branch.target());
		}
		else {
			writeIndented("jz " + branch.target());
		}
	}

	private void writeCall(IRCall call) throws IOException {
		final List<IRVar> args = call.args();
		final int argsSize = args.size() * 8;
		final int offset = (args.size() + 1) % 2 * 8;
		for (IRVar arg : args) {
			final int argValue = loadVar(arg);
			writeIndented("push " + getRegName(argValue));
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
			Utils.assertTrue("rax".equals(getRegName(0)));
			final String valueRegName = getRegName(0, target);
			writeIndented("mov " + getRegName(target) + ", " + valueRegName);
		}
	}

	private void writeRetValue(IRRetValue retValue) throws IOException {
		final int valueReg = getRegisterVarRegisterIndex(retValue.var());
		writeIndented("mov rax, " + getRegName(valueReg));
	}

	private void writeMovx(String targetRegName, int sourceReg, IRVar sourceVar, boolean signed) throws IOException {
		final String signedString = signed ? "s" : "z";
		final String op = getTypeSize(sourceVar.type()) == 4 ? "xd" : "x";
		writeIndented("mov" + signedString + op + " " + targetRegName + ", " + getRegName(sourceReg, sourceVar));
	}

	private int loadVar(IRVar var) throws IOException {
		if (var.scope() == VariableScope.register) {
			return getRegisterVarRegisterIndex(var);
		}

		final int reg = TMP_REG;
		addrOf(reg, var);
		final String addRegName = getRegName(reg);
		final String valueRegName = getRegName(reg, var);
		writeIndented("mov " + valueRegName + ", [" + addRegName + "]");
		return reg;
	}

	private void addrOf(int register, IRVar var) throws IOException {
		final String addrReg = getRegName(register);
		switch (var.scope()) {
		case global -> writeIndented("lea " + addrReg + ", [" + getGlobalVarName(var.index()) + "]");
		case function, argument -> {
			final int offset = localVarOffsets[var.index()] + rspOffset;
			writeIndented("lea " + addrReg + ", [rsp+" + offset + "]");
		}
		default -> throw new UnsupportedOperationException(String.valueOf(var.scope()));
		}
	}

	private void writeJump(IRJump jump) throws IOException {
		writeIndented("jmp " + jump.label());
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

	private static int alignTo16(int offset) {
		return alignTo(offset, 16);
	}

	private static int alignTo(int offset, int alignment) {
		return (offset + alignment - 1) / alignment * alignment;
	}

	@NotNull
	private static String getRegName(int valueReg, IRVar var) {
		return getRegName(valueReg, getTypeSize(var.type()));
	}

	private static String getRegName(IRVar var) {
		final int reg = getRegisterVarRegisterIndex(var);
		return getRegName(reg, getTypeSize(var.type()));
	}

	private static int getRegisterVarRegisterIndex(IRVar var) {
		Utils.assertTrue(var.scope() == VariableScope.register);
		return var.index() + 2;
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
			case 4 -> getNRegName(9, size);
			case 5 -> getNRegName(10, size);
			default -> throw new IllegalStateException();
		};
	}

	@NotNull
	private static String getNRegName(int reg, int size) {
		return switch (size) {
			case 1 -> "r" + reg + "b";
			case 2 -> "r" + reg + "w";
			case 4 -> "r" + reg + "d";
			default -> "r" + reg;
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
}
