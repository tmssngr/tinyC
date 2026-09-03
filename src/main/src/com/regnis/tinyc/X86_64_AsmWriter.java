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
public abstract class X86_64_AsmWriter extends AsmWriter {

	@NotNull
	protected abstract X86StackOffsets createX86StackOffsets(List<IRVarDef> localVars, List<List<IRVar>> callsArgs, int nonvolatileRegistersToPushPop);

	private static final int FIRST_NON_VOLATILE_REGISTER = 6;

	private final X86Registers registers;

	private X86StackOffsets stackOffsets;

	protected X86_64_AsmWriter(@NotNull BufferedWriter writer, @NotNull X86Registers registers) {
		super(writer);
		this.registers = registers;
	}

	@Override
	protected void writeFunction(IRFunction function) throws IOException {
		writeComment(function.toString());

		final List<IRInstruction> instructions = function.instructions();
		final int nonvolatileRegistersToPushPop = getNonVolatileRegistersToPushPop(instructions);
		final List<IRVarDef> localVars = function.varInfos().vars();
		final List<List<IRVar>> callsArgs = getCallArgs(instructions);
		stackOffsets = createX86StackOffsets(localVars, callsArgs, nonvolatileRegistersToPushPop);
		final int rspOffset = stackOffsets.getRspOffset();
		final int callArgSpace = stackOffsets.getCallArgSpace();
		writeVarOffsetAsComments(localVars);
		writeLabel(function.label());
		writeFunctionProlog(rspOffset, nonvolatileRegistersToPushPop, callArgSpace);

		writeInstructions(instructions);

		writeFunctionEpilog(rspOffset, nonvolatileRegistersToPushPop, callArgSpace);
		stackOffsets = null;
	}

	@Override
	protected void writeAddrOf(int addrReg, IRVar source) throws IOException {
		addrOf(addrReg, source);
	}

	@Override
	protected void writeAddrOfArray(int addrReg, IRVar arrayOrPointer) throws IOException {
		addrOf(addrReg, arrayOrPointer);
	}

	@Override
	protected void writeBinary(IRBinary.Op op, int targetReg, int leftReg, Type leftType, int rightReg, Type rightType) throws IOException {
		final boolean signed = leftType != Type.U8;
		switch (op) {
		case Add -> writeBinary("add", targetReg, leftReg, leftType, rightReg, rightType);
		case Sub -> writeBinary("sub", targetReg, leftReg, leftType, rightReg, rightType);
		case Mul -> {
			final String leftRegName = registers.getRegName(leftReg);
			final String rightRegName = registers.getRegName(rightReg);
			final String targetRegName = registers.getRegName(targetReg);
			if (getTypeSize(leftType) != 8) {
				writeMovx(leftRegName, leftReg, leftType, true);
			}

			if (getTypeSize(rightType) != 8) {
				writeMovx(rightRegName, rightReg, rightType, true);
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
			final Type type = leftType;
			Utils.assertTrue(Objects.equals(type, rightType));
			final int size = getTypeSize(type);
			// https://www.felixcloutier.com/x86/idiv
			// (rdx rax) / %reg -> rax
			// (rdx rax) % %reg -> rdx
			Utils.assertTrue(leftReg == registers.rax());
			if (op == IRBinary.Op.Div) {
				Utils.assertTrue(targetReg == registers.rax());
			}
			else {
				Utils.assertTrue(targetReg == registers.rdx());
			}
			Utils.assertTrue(rightReg != registers.rdx());
			final String rightRegName = registers.getRegName(rightReg);

			Utils.assertTrue("rdx".equals(registers.getRegName(registers.rdx())));
			if (size != 8) {
				writeMovx("rax", leftReg, leftType, signed);
				writeMovx(rightRegName, rightReg, rightType, signed);
			}
			writeIndented("cqo"); // rdx := signbit(rax)
			writeIndented("idiv " + rightRegName);
		}

		case ShiftLeft, ShiftRight -> {
			final String opName = op == IRBinary.Op.ShiftRight
					? signed ? "sar" : "shr"
					: signed ? "sal" : "shl";

			Utils.assertTrue(leftReg == targetReg);
			Utils.assertTrue(leftReg != registers.rcx());
			Utils.assertTrue(rightReg == registers.rcx());
			final String leftRegName = getRegName(leftReg, leftType);

			Utils.assertTrue("cl".equals(registers.getRegName(rightReg, 1)));
			writeIndented(opName + " " + leftRegName + ", cl");
		}

		case And -> writeBinary("and", targetReg, leftReg, leftType, rightReg, rightType);
		case Or -> writeBinary("or", targetReg, leftReg, leftType, rightReg, rightType);
		case Xor -> writeBinary("xor", targetReg, leftReg, leftType, rightReg, rightType);

		default -> throw new UnsupportedOperationException(String.valueOf(op));
		}
	}

	@Override
	protected void writeBinary(IRBinary.Op op, int targetReg, int leftReg, Type leftType, int value) throws IOException {
		final boolean signed = leftType != Type.U8;
		switch (op) {
		case Add -> writeBinary("add", targetReg, leftReg, leftType, value);
		case Sub -> writeBinary("sub", targetReg, leftReg, leftType, value);
		case Mul -> {
			final String leftRegName = registers.getRegName(leftReg);
			final String targetRegName = registers.getRegName(targetReg);
			if (getTypeSize(leftType) != 8) {
				writeMovx(leftRegName, leftReg, leftType, true);
			}

			if (targetReg == leftReg) {
				writeIndented("imul " + " " + leftRegName + ", " + value);
			}
			else {
				// maybe combine with movsx above
				writeIndented("mov rax, " + leftRegName);
				writeIndented("imul rax, " + value);
				writeIndented("mov " + targetRegName + ", rax");
			}
		}
		case Div, Mod -> {
			final Type type = leftType;
			final int size = getTypeSize(type);
			// https://www.felixcloutier.com/x86/idiv
			// (rdx rax) / %reg -> rax
			// (rdx rax) % %reg -> rdx
			Utils.assertTrue(leftReg == registers.rax());
			if (op == IRBinary.Op.Div) {
				Utils.assertTrue(targetReg == registers.rax());
			}
			else {
				Utils.assertTrue(targetReg == registers.rdx());
			}

			Utils.assertTrue("rdx".equals(registers.getRegName(registers.rdx())));
			if (size != 8) {
				writeMovx("rax", leftReg, leftType, signed);
			}
			writeIndented("cqo"); // rdx := signbit(rax)
			writeIndented("mov rcx, " + value);
			writeIndented("idiv rcx");
		}

		case ShiftLeft, ShiftRight -> {
			final String opName = op == IRBinary.Op.ShiftRight
					? signed ? "sar" : "shr"
					: signed ? "sal" : "shl";

			Utils.assertTrue(leftReg == targetReg);
			final String leftRegName = getRegName(leftReg, leftType);

			writeIndented(opName + " " + leftRegName + ", " + value);
		}

		case And -> writeBinary("and", targetReg, leftReg, leftType, value);
		case Or -> writeBinary("or", targetReg, leftReg, leftType, value);
		case Xor -> writeBinary("xor", targetReg, leftReg, leftType, value);

		default -> throw new UnsupportedOperationException(String.valueOf(op));
		}
	}

	@Override
	protected void writeBranch(int conditionReg, boolean jumpOnTrue, String targetLabel) throws IOException {
		final String conditionRegName = registers.getRegName(conditionReg, 1);
		writeIndented("or " + conditionRegName + ", " + conditionRegName);
		if (jumpOnTrue) {
			writeIndented("jnz " + targetLabel);
		}
		else {
			writeIndented("jz " + targetLabel);
		}
	}

	@Override
	protected void writeCall(String name) throws IOException {
		writeIndented("call @" + name);
	}

	@Override
	protected void writeCast(int targetReg, Type targetType, int sourceReg, Type sourceType) throws IOException {
		final int sourceSize = getTypeSize(sourceType);
		final int targetSize = getTypeSize(targetType);
		if (targetSize > sourceSize) {
			if (sourceType == Type.U8) {
				writeIndented("movzx " + registers.getRegName(targetReg, targetSize) + ", " + registers.getRegName(sourceReg, sourceSize));
			}
			else if (sourceSize == 4) {
				writeIndented("movsxd " + registers.getRegName(targetReg, targetSize) + ", " + registers.getRegName(sourceReg, sourceSize));
			}
			else {
				writeIndented("movsx " + registers.getRegName(targetReg, targetSize) + ", " + registers.getRegName(sourceReg, sourceSize));
			}
		}
		else if (sourceReg != targetReg) {
			writeIndented("mov " + registers.getRegName(targetReg, targetSize) + ", " + registers.getRegName(sourceReg, targetSize));
		}
	}

	@Override
	protected void writeCompare(IRCompare.Op op, int targetReg, int leftReg, int rightReg, Type leftRightType) throws IOException {
		final String command = getCompareCommand(op, leftRightType);
		final String leftRegName = getRegName(leftReg, leftRightType);
		final String rightRegName = getRegName(rightReg, leftRightType);
		writeIndented("cmp " + leftRegName + ", " + rightRegName);
		writeIndented(command + " " + registers.getRegName(targetReg, 1));
	}

	@Override
	protected void writeCompare(IRCompare.Op op, int targetReg, int leftReg, Type leftRightType, int rightValue) throws IOException {
		final String command = getCompareCommand(op, leftRightType);
		final String leftRegName = getRegName(leftReg, leftRightType);
		writeIndented("cmp " + leftRegName + ", " + rightValue);
		writeIndented(command + " " + registers.getRegName(targetReg, 1));
	}

	@Override
	protected void writeMove(int targetReg, int sourceReg, Type type) throws IOException {
		writeIndented("mov " + getRegName(targetReg, type) + ", " + getRegName(sourceReg, type));
	}

	@Override
	protected void writeLiteral(int targetReg, Type type, int value) throws IOException {
		writeIndented("mov " + getRegName(targetReg, type) + ", " + value);
	}

	@Override
	protected void writeMemLoad(int targetReg, Type type, int addrReg) throws IOException {
		writeIndented("mov " + getRegName(targetReg, type) + ", [" + registers.getRegName(addrReg) + "]");
	}

	@Override
	protected void writeMemStore(int addrReg, int valueReg, Type type) throws IOException {
		writeIndented("mov [" + registers.getRegName(addrReg) + "], " + getRegName(valueReg, type));
	}

	@Override
	protected void writeString(int targetReg, Type targetType, int stringLiteralIndex) throws IOException {
		writeIndented("lea " + getRegName(targetReg, targetType) + ", [" + getStringLiteralName(stringLiteralIndex) + "]");
	}

	@Override
	protected void writeUnary(IRUnary.Op op, int targetReg, Type targetType, int sourceReg, Type sourceType) throws IOException {
		switch (op) {
		case Neg, Not -> {
			final String targetRegName = registers.getRegName(targetReg);
			if (sourceReg != targetReg) {
				writeIndented("mov " + targetRegName + ", " + registers.getRegName(sourceReg));
			}

			if (op == IRUnary.Op.Neg) {
				writeIndented("neg " + targetRegName);
			}
			else {
				writeIndented("not " + targetRegName);
			}
		}
		case NotLog -> {
			final String regName = getRegName(sourceReg, sourceType);
			writeIndented("or " + regName + ", " + regName);
			writeIndented("sete " + getRegName(targetReg, targetType));
		}
		default -> throw new UnsupportedOperationException(String.valueOf(op));
		}
	}

	@Override
	protected void writeJump(String label) throws IOException {
		writeIndented("jmp " + label);
	}

	protected final void writeGlobalVariables(List<IRVarDef> globalVariables) throws IOException {
		for (IRVarDef variable : globalVariables) {
			writeComment("variable " + variable.getString());
			writeIndented(getGlobalVarName(variable.var().index()) + " rb " + variable.size());
		}
	}

	protected final void writeStringLiterals(List<IRStringLiteral> stringLiterals) throws IOException {
		for (IRStringLiteral literal : stringLiterals) {
			final String encoded = encode((literal.text()).getBytes(StandardCharsets.UTF_8));
			writeIndented(getStringLiteralName(literal.index()) + " db " + encoded);
		}
		writeNL();
	}

	@NotNull
	private String getCompareCommand(IRCompare.Op op, Type leftRightType) {
		final boolean signed = leftRightType != Type.U8;
		return switch (op) {
			case Lt -> signed ? "setl" : "setb"; // setb (below) = setc (carry)
			case LtEq -> signed ? "setle" : "setbe";
			case Equals -> "sete";
			case NotEquals -> "setne";
			case GtEq -> signed ? "setge" : "setae"; // setae (above or equal) = setnc (not carry)
			case Gt -> signed ? "setg" : "seta"; // seta (above)
		};
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
				writeIndented("push " + registers.getRegName(FIRST_NON_VOLATILE_REGISTER + i));
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
				writeIndented("pop " + registers.getRegName(FIRST_NON_VOLATILE_REGISTER + i));
			}
		}

		if (rspOffset > 0) {
			writeIndented("add rsp, " + rspOffset);
		}
		writeIndented("ret");
	}

	private void writeBinary(String op, int targetReg, int leftReg, Type leftType, int rightReg, Type rightType) throws IOException {
		final String leftRegName = getRegName(leftReg, leftType);
		final String rightRegName = getRegName(rightReg, rightType);
		final String targetRegName = getRegName(targetReg, leftType);
		if (targetReg == leftReg) {
			writeIndented(op + " " + targetRegName + ", " + rightRegName);
		}
		else {
			Utils.assertTrue(targetReg != rightReg);
			writeIndented("mov " + targetRegName + ", " + leftRegName);
			writeIndented(op + " " + targetRegName + ", " + rightRegName);
		}
	}

	private void writeBinary(String op, int targetReg, int leftReg, Type leftType, int value) throws IOException {
		final String leftRegName = getRegName(leftReg, leftType);
		final String targetRegName = getRegName(targetReg, leftType);
		if (targetReg == leftReg) {
			writeIndented(op + " " + targetRegName + ", " + value);
		}
		else {
			writeIndented("mov " + targetRegName + ", " + leftRegName);
			writeIndented(op + " " + targetRegName + ", " + value);
		}
	}

	private void writeMovx(String targetRegName, int sourceReg, Type sourceType, boolean signed) throws IOException {
		final String signedString = signed ? "s" : "z";
		final String op = getTypeSize(sourceType) == 4 ? "xd" : "x";
		writeIndented("mov" + signedString + op + " " + targetRegName + ", " + getRegName(sourceReg, sourceType));
	}

	private void addrOf(int register, IRVar var) throws IOException {
		final String addrReg = registers.getRegName(register);
		switch (var.scope()) {
		case global -> writeIndented("lea " + addrReg + ", [" + getGlobalVarName(var.index()) + "]");
		case function, parameter -> {
			final int offset = stackOffsets.getOffset(var);
			writeIndented("lea " + addrReg + ", [rsp+" + offset + "]");
		}
		default -> throw new UnsupportedOperationException(String.valueOf(var.scope()));
		}
	}

	@NotNull
	private String getRegName(int valueReg, Type type) {
		return registers.getRegName(valueReg, getTypeSize(type));
	}

	private static int getTypeSize(Type type) {
		return Type.getSize(type, Type.I64);
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
