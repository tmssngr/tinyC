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

	private static final int TMP_REG = 99;
	private static final int FIRST_NON_VOLATILE_REGISTER = 6;

	private X86StackOffsets stackOffsets = X86StackOffsets.DUMMY;
	private int rspOffset;

	public X86Win64(@NotNull BufferedWriter writer) {
		super(writer);
	}

	public void write(@NotNull IRProgram program) throws IOException {
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

	protected void writeAddConst(IRAddConst addConst) throws IOException {
		final IRVar var = addConst.var();
		int offset = addConst.offset();
		final int reg = getRegisterVarRegisterIndex(var);
		final String regName = getRegName(reg, var);
		if (offset > 0) {
			if (offset == 1) {
				writeIndented("inc " + regName);
			}
			else {
				writeIndented("add " + regName + ", " + offset);
			}
		}
		else {
			offset = -offset;
			if (offset == 1) {
				writeIndented("dec " + regName);
			}
			else {
				writeIndented("sub " + regName + ", " + offset);
			}
		}
	}

	protected void writeAddrOf(IRAddrOf addrOf) throws IOException {
		final int addrReg = getRegisterVarRegisterIndex(addrOf.target());
		addrOf(addrReg, addrOf.source());
	}

	protected void writeAddrOfArray(IRAddrOfArray addrOf) throws IOException {
		final IRVar arrayOrPointer = addrOf.array();
		Utils.assertTrue(arrayOrPointer.scope() != VariableScope.register);
		final IRVar target = addrOf.addr();
		final int targetReg = getRegisterVarRegisterIndex(target);
		addrOf(targetReg, arrayOrPointer);
	}

	protected void writeBinary(IRBinary binary) throws IOException {
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
			Utils.assertTrue(leftReg == 0);
			final int targetReg = getRegisterVarRegisterIndex(binary.target());
			if (binary.op() == IRBinary.Op.Div) {
				Utils.assertTrue(targetReg == 0);
			}
			else {
				Utils.assertTrue(targetReg == 2);
			}
			final int rightReg = getRegisterVarRegisterIndex(binary.right());
			Utils.assertTrue(rightReg != 2);
			final String rightRegName = getRegName(rightReg);

			final int rdx = 2;
			Utils.assertTrue("rdx".equals(getRegName(rdx)));
			if (size != 8) {
				writeMovx("rax", leftReg, binary.left(), signed);
				writeMovx(rightRegName, rightReg, binary.right(), signed);
			}
			writeIndented("cqo"); // rdx := signbit(rax)
			writeIndented("idiv " + rightRegName);
		}

		case ShiftLeft, ShiftRight -> {
			final String op = binary.op() == IRBinary.Op.ShiftRight
					? signed ? "sar" : "shr"
					: signed ? "sal" : "shl";

			final int leftReg = getRegisterVarRegisterIndex(binary.left());
			final int targetReg = getRegisterVarRegisterIndex(binary.target());
			Utils.assertTrue(leftReg == targetReg);
			Utils.assertTrue(leftReg != 1);
			final int rightReg = getRegisterVarRegisterIndex(binary.right());
			Utils.assertTrue(rightReg == 1);
			final String leftRegName = getRegName(leftReg, binary.left());

			Utils.assertTrue("cl".equals(getRegName(rightReg, 1)));
			writeIndented(op + " " + leftRegName + ", cl");
		}

		case And -> writeBinary("and", binary);
		case Or -> writeBinary("or", binary);
		case Xor -> writeBinary("xor", binary);

		default -> throw new UnsupportedOperationException(String.valueOf(binary));
		}
	}

	protected void writeBranch(IRBranch branch) throws IOException {
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

	protected void writeCall(IRCall call) throws IOException {
		final IRVar target = call.target();
		if (target != null) {
			Utils.assertTrue(getRegisterVarRegisterIndex(target) == 0);
		}

		writeIndented("call @" + call.name());
	}

	protected void writeCast(IRCast cast) throws IOException {
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
			writeIndented("mov " + getRegName(targetReg, targetSize) + ", " + getRegName(sourceReg, targetSize));
		}
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

	protected void writeCompare(IRCompareConst compare) throws IOException {
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

	protected void writeMove(IRMove move) throws IOException {
		final IRVar source = move.source();
		final IRVar target = move.target();
		final int addrReg = TMP_REG;
		if (source.scope() == VariableScope.register) {
			if (target.scope() == VariableScope.register) {
				writeIndented("mov " + getRegName(target) + ", " + getRegName(move.source()));
				return;
			}

			addrOf(addrReg, target);
			writeIndented("mov [" + getRegName(addrReg) + "], " + getRegName(source));
			return;
		}

		Utils.assertTrue(target.scope() == VariableScope.register, move.toString(true));
		addrOf(addrReg, source);
		writeIndented("mov " + getRegName(target) + ", [" + getRegName(addrReg) + "]");
	}

	protected void writeLiteral(IRLiteral literal) throws IOException {
		final IRVar target = literal.target();
		final int value = literal.value();
		writeIndented("mov " + getRegName(target) + ", " + value);
	}

	protected void writeMemLoad(IRMemLoad load) throws IOException {
		final int addrReg = getRegisterVarRegisterIndex(load.addr());
		writeIndented("mov " + getRegName(load.target()) + ", [" + getRegName(addrReg) + "]");
	}

	protected void writeMemStore(IRMemStore store) throws IOException {
		final int addrReg = getRegisterVarRegisterIndex(store.addr());
		writeIndented("mov [" + getRegName(addrReg) + "], " + getRegName(store.value()));
	}

	protected void writeRetValue(IRRetValue retValue) throws IOException {
		final int valueReg = getRegisterVarRegisterIndex(retValue.var());
		writeIndented("mov rax, " + getRegName(valueReg));
	}

	protected void writeString(IRString literal) throws IOException {
		writeIndented("lea " + getRegName(literal.target()) + ", [" + getStringLiteralName(literal.stringIndex()) + "]");
	}

	protected void writeUnary(IRUnary unary) throws IOException {
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

	protected void writeJump(IRJump jump) throws IOException {
		writeIndented("jmp " + jump.label());
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

		final List<IRInstruction> instructions = function.instructions();
		final int nonvolatileRegistersToPushPop = getNonVolatileRegistersToPushPop(instructions);
		final List<IRVarDef> localVars = function.varInfos().vars();
		final List<List<IRVar>> callsArgs = getCallsWithStackArgs(instructions);
		stackOffsets = new X86StackOffsets(localVars, callsArgs, nonvolatileRegistersToPushPop);
		final int rspOffset = stackOffsets.getRspOffset();
		final int callArgSpace = stackOffsets.getCallArgSpace();
		writeVarOffsetAsComments(localVars);
		writeLabel(function.label());
		writeFunctionProlog(rspOffset, nonvolatileRegistersToPushPop, callArgSpace);

		writeInstructions(instructions);

		writeFunctionEpilog(rspOffset, nonvolatileRegistersToPushPop, callArgSpace);
		stackOffsets = X86StackOffsets.DUMMY;
	}

	private List<List<IRVar>> getCallsWithStackArgs(List<IRInstruction> instructions) {
		final List<List<IRVar>> calls = new ArrayList<>();
		instructions.forEach(instruction -> {
			if (instruction instanceof IRCall call) {
				calls.add(call.args());
			}
		});
		return calls;
	}

	private int getNonVolatileRegistersToPushPop(List<IRInstruction> instructions) {
		final int maxReg = IRUtils.getMaxReg(instructions);
		return Math.max(0, maxReg - FIRST_NON_VOLATILE_REGISTER);
	}

	private void writeVarOffsetAsComments(List<IRVarDef> localVars) throws IOException {
		for (IRVarDef varDef : localVars) {
			final IRVar var = varDef.var();
			if (var.scope() == VariableScope.parameter) {
				writeComment("  rsp+" + stackOffsets.getOffset(var) + ": arg " + var.name());
			}
			else {
				Utils.assertTrue(var.scope() == VariableScope.function);
				writeComment("  rsp+" + stackOffsets.getOffset(var) + ": var " + var.name());
			}
		}
	}

	private void writeFunctionProlog(int rspOffset, int pushedNonvolatileRegisterCount, int callArgSpace) throws IOException {
		if (rspOffset > 0) {
			writeIndented("sub rsp, " + rspOffset);
		}

		if (pushedNonvolatileRegisterCount > 0) {
			writeComment("save clobbered non-volatile registers");
			for (int i = 0; i < pushedNonvolatileRegisterCount; i++) {
				writeIndented("push " + getRegName(FIRST_NON_VOLATILE_REGISTER + i));
			}
		}

		if (callArgSpace > 0) {
			writeIndented("sub rsp, " + callArgSpace);
		}
	}

	private void writeFunctionEpilog(int rspOffset, int pushedNonvolatileRegisterCount, int callArgSpace) throws IOException {
		if (callArgSpace > 0) {
			writeIndented("add rsp, " + callArgSpace);
		}

		if (pushedNonvolatileRegisterCount > 0) {
			writeComment("restore clobbered non-volatile registers");
			for (int i = pushedNonvolatileRegisterCount; i-- > 0; ) {
				writeIndented("pop " + getRegName(FIRST_NON_VOLATILE_REGISTER + i));
			}
		}

		if (rspOffset > 0) {
			writeIndented("add rsp, " + rspOffset);
		}
		writeIndented("ret");
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

	private void writeCompare(String command, IRCompare compare) throws IOException {
		final int leftReg = getRegisterVarRegisterIndex(compare.left());
		final String leftRegName = getRegName(leftReg, compare.left());
		final int rightReg = getRegisterVarRegisterIndex(compare.right());
		final String rightRegName = getRegName(rightReg, compare.right());
		final int targetReg = getRegisterVarRegisterIndex(compare.target());
		writeIndented("cmp " + leftRegName + ", " + rightRegName);
		writeIndented(command + " " + getRegName(targetReg, 1));
	}

	private void writeCompare(String command, IRCompareConst compare) throws IOException {
		final int leftReg = getRegisterVarRegisterIndex(compare.left());
		final String leftRegName = getRegName(leftReg, compare.left());
		final int targetReg = getRegisterVarRegisterIndex(compare.target());
		writeIndented("cmp " + leftRegName + ", " + compare.value());
		writeIndented(command + " " + getRegName(targetReg, 1));
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
		case function, parameter -> {
			final int offset = stackOffsets.getOffset(var) + rspOffset;
			writeIndented("lea " + addrReg + ", [rsp+" + offset + "]");
		}
		default -> throw new UnsupportedOperationException(String.valueOf(var.scope()));
		}
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
		return var.index();
	}

	private static String getRegName(int reg) {
		return getRegName(reg, 0);
	}

	private static String getRegName(int reg, int size) {
		return switch (reg) {
			case 0 -> getXRegName('a', size); // return
			case 1 -> getXRegName('c', size); // first arg
			case 2 -> getXRegName('d', size); // second arg
			case 3 -> getNRegName(8, size);   // third arg
			case 4 -> getNRegName(9, size);   // fourth arg
			case 5 -> getNRegName(10, size);
			// non-volatile
			case 6 -> getXRegName('b', size);
			case 7 -> getNRegName(12, size);
			case 8 -> getNRegName(13, size);
			case 9 -> getNRegName(14, size);
			case 10 -> getNRegName(15, size);
			case TMP_REG -> getNRegName(11, size); // temp
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
