package com.regnis.tinyc.ir;

import java.io.*;
import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class IRWriter {

	private final BufferedWriter writer;

	public IRWriter(@NotNull BufferedWriter writer) {
		this.writer = writer;
	}

	public void write(IRProgram program) throws IOException {
		writeFunctions(program);
		writeGlobalVars(program.globalVars());
		writeStringLiterals(program.stringLiterals());
	}

	private void writeFunctions(IRProgram program) throws IOException {
		for (IRFunction function : program.functions()) {
			writeFunction(function);
		}
	}

	private void writeFunction(IRFunction function) throws IOException {
		writeln(function.label() + ":");
		final List<IRLocalVar> localVars = function.localVars();
		if (localVars.size() > 0) {
			writeln(" Local variables");
			for (IRLocalVar var : localVars) {
				writeIndentation();
				write(var.isArg() ? "arg " : "var ");
				writeln(var.toString());
			}
		}

		writeInstructions(function.instructions());

		for (String asmLine : function.asmLines()) {
			writeIndentation();
			writeln(asmLine);
		}
		writeln();
	}

	private void writeInstructions(List<IRInstruction> instructions) throws IOException {
		for (IRInstruction instruction : instructions) {
			if (instruction instanceof IRLabel label) {
				writeln(label.label() + ":");
			}
			else {
				writeIndentation();
				if (instruction instanceof IRComment c) {
					writeln("; " + c.comment());
				}
				else {
					writeln(instruction.toString());
				}
			}
		}
	}

	private void writeGlobalVars(List<IRGlobalVar> globalVars) throws IOException {
		if (globalVars.isEmpty()) {
			return;
		}

		writeln("Global variables");
		for (IRGlobalVar var : globalVars) {
			writeIndentation();
			writeln(var.toString());
		}
		writeln();
	}

	private void writeStringLiterals(List<IRStringLiteral> stringLiterals) throws IOException {
		if (stringLiterals.isEmpty()) {
			return;
		}

		writeln("String literals");
		for (IRStringLiteral literal : stringLiterals) {
			writeIndentation();
			writeln(literal.toString());
		}
	}

	private void writeIndentation() throws IOException {
		write("\t");
	}

	private void writeln() throws IOException {
		writeln("");
	}

	private void writeln(String text) throws IOException {
		write(text);
		writer.newLine();
	}

	private void write(String str) throws IOException {
		writer.write(str);
	}
}
