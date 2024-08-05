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
				writer.write("   ");
				writer.write(var.isArg() ? "arg " : "var ");
				writeln(var.toString());
			}
		}

		for (IRInstruction instruction : function.instructions()) {
			if (instruction instanceof IRLabel label) {
				writeln(label.label() + ":");
			}
			else {
				writer.write("        ");
				if (instruction instanceof IRComment c) {
					writeln("; " + c.comment());
				}
				else {
					writeln(instruction.toString());
				}
			}
		}
		writeln("");
	}

	private void writeGlobalVars(List<IRGlobalVar> globalVars) throws IOException {
		if (globalVars.isEmpty()) {
			return;
		}

		writeln("Global variables");
		for (IRGlobalVar var : globalVars) {
			writeln("  " + var.toString());
		}
		writeln("");
	}

	private void writeStringLiterals(List<IRStringLiteral> stringLiterals) throws IOException {
		if (stringLiterals.isEmpty()) {
			return;
		}

		writeln("String literals");
		for (IRStringLiteral literal : stringLiterals) {
			writeln("  " + literal.toString());
		}
	}

	private void writeln(String text) throws IOException {
		writer.write(text);
		writer.newLine();
	}
}
