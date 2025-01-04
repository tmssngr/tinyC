package com.regnis.tinyc;

import com.regnis.tinyc.ir.*;

import java.io.*;
import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
abstract class AsmWriter {

	public abstract void write(@NotNull IRProgram program) throws IOException;

	protected abstract void writeAddrOf(IRAddrOf addrOf) throws IOException;

	protected abstract void writeAddrOfArray(IRAddrOfArray addrOf) throws IOException;

	protected abstract void writeBinary(IRBinary binary) throws IOException;

	protected abstract void writeBranch(IRBranch branch) throws IOException;

	protected abstract void writeCall(IRCall call) throws IOException;

	protected abstract void writeCast(IRCast cast) throws IOException;

	protected abstract void writeCompare(IRCompare compare) throws IOException;

	protected abstract void writeJump(IRJump jump) throws IOException;

	protected abstract void writeLiteral(IRLiteral literal) throws IOException;

	protected abstract void writeMemLoad(IRMemLoad load) throws IOException;

	protected abstract void writeMemStore(IRMemStore store) throws IOException;

	protected abstract void writeMove(IRMove copy) throws IOException;

	protected abstract void writeRetValue(IRRetValue retValue) throws IOException;

	protected abstract void writeString(IRString literal) throws IOException;

	protected abstract void writeUnary(IRUnary unary) throws IOException;

	private static final String INDENTATION = "        ";

	private final BufferedWriter writer;
	@SuppressWarnings("unused") private boolean debug;

	protected AsmWriter(@NotNull BufferedWriter writer) {
		this.writer = writer;
	}

	protected void writeAsmFunction(IRAsmFunction function) throws IOException {
		writeComment(function.toString());

		writeLabel(function.label());
		for (String line : function.asmLines()) {
			writeLines(line, line.contains(":") ? "" : INDENTATION);
		}
	}

	protected void writeInstructions(List<IRInstruction> instructions) throws IOException {
		for (IRInstruction instruction : instructions) {
			writeInstruction(instruction);
		}
	}

	protected void writeInstruction(IRInstruction instruction) throws IOException {
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
		case IRMemLoad load -> writeMemLoad(load);
		case IRMemStore store -> writeMemStore(store);
		case IRMove copy -> writeMove(copy);
		case IRRetValue retValue -> writeRetValue(retValue);
		case IRString literal -> writeString(literal);
		case IRUnary unary -> writeUnary(unary);
		default -> throw new UnsupportedOperationException(instruction.getClass() + " " + instruction);
		}
	}

	protected void writeLabel(String label) throws IOException {
		write(label + ":");
		writeNL();
	}

	protected void writeComment(String s) throws IOException {
		writeIndented("; " + s);
	}

	protected void writeIndented(String text) throws IOException {
		writeLines(text, INDENTATION);
	}

	protected final void writeLines(String text) throws IOException {
		writeLines(text, null);
	}

	protected void writeNL() throws IOException {
		write(System.lineSeparator());
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

	private void write(String text) throws IOException {
		writer.write(text);
		if (debug) {
			System.out.print(text);
		}
	}
}
