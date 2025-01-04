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
public final class Z8 extends AsmWriter {

	private static final int TMP_REG = 99;

	public Z8(@NotNull BufferedWriter writer) {
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

		writePostamble(program.varInfos().vars(), program.stringLiterals());
	}

	protected void writeAddrOf(IRAddrOf addrOf) throws IOException {
		notYetImplemented();
	}

	protected void writeAddrOfArray(IRAddrOfArray addrOf) throws IOException {
		notYetImplemented();
	}

	protected void writeBinary(IRBinary binary) throws IOException {
		final boolean signed = binary.left().type() != Type.U8;
		switch (binary.op()) {
		case Add -> writeBinary("add", binary);
		case Sub -> writeBinary("sub", binary);
		case Mul -> {
			notYetImplemented();
		}
		case Div, Mod -> {
			notYetImplemented();
		}

		case ShiftLeft, ShiftRight -> {
			notYetImplemented();
		}

		case And -> writeBinary("and", binary);
		case Or -> writeBinary("or", binary);
		case Xor -> writeBinary("xor", binary);

		default -> throw new UnsupportedOperationException(String.valueOf(binary));
		}
	}

	protected void writeBranch(IRBranch branch) throws IOException {
		notYetImplemented();
	}

	protected void writeCall(IRCall call) throws IOException {
		notYetImplemented();
	}

	protected void writeCast(IRCast cast) throws IOException {
		notYetImplemented();
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
		notYetImplemented();
	}

	protected void writeLiteral(IRLiteral literal) throws IOException {
		notYetImplemented();
	}

	protected void writeMemLoad(IRMemLoad load) throws IOException {
		notYetImplemented();
	}

	protected void writeMemStore(IRMemStore store) throws IOException {
		notYetImplemented();
	}

	protected void writeRetValue(IRRetValue retValue) throws IOException {
		notYetImplemented();
	}

	protected void writeString(IRString literal) throws IOException {
		notYetImplemented();
	}

	protected void writeUnary(IRUnary unary) throws IOException {
		switch (unary.op()) {
		case Neg, Not -> {
			notYetImplemented();
		}
		case NotLog -> {
			notYetImplemented();
		}
		default -> throw new UnsupportedOperationException(String.valueOf(unary));
		}
	}

	protected void writeJump(IRJump jump) throws IOException {
		notYetImplemented();
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
	}

	private void writeFunction(IRFunction function) throws IOException {
		writeComment(function.toString());

		writeIndented("ret");
	}

	private void writeBinary(String op, IRBinary binary) throws IOException {
		notYetImplemented();
	}

	private void writeCompare(String command, IRCompare compare) throws IOException {
		notYetImplemented();
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

	private static void notYetImplemented() {
		throw new UnsupportedOperationException("Not implemented yet");
	}
}
