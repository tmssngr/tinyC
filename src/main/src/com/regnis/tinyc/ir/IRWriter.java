package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;

import java.io.*;
import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class IRWriter extends TextWriter {

	public IRWriter(@NotNull BufferedWriter writer) {
		super(writer);
	}

	public void write(@NotNull IRProgram program) throws IOException {
		writeFunctions(program);
		writeGlobalVars(program.globalVars());
		writeStringLiterals(program.stringLiterals());
	}

	private void writeFunctions(IRProgram program) throws IOException {
		for (IRFunction function : program.functions()) {
			writeFunction(function);
		}
		for (IRAsmFunction function : program.asmFunctions()) {
			writeAsmFunction(function);
		}
	}

	private void writeFunction(IRFunction function) throws IOException {
		writeln(function.label() + ":");
		final List<IRVarDef> localVars = function.localVars();
		if (localVars.size() > 0) {
			writeln(" Local variables");
			for (IRVarDef var : localVars) {
				writeIndentation();
				write(var.scope() == VariableScope.argument ? "arg " : "var ");
				writeln(var.toString());
			}
		}

		writeInstructions(function.instructions());
		writeln();
	}

	private void writeAsmFunction(IRAsmFunction function) throws IOException {
		writeln(function.label() + ":");
		for (String asmLine : function.asmLines()) {
			writeIndentation();
			writeln(asmLine);
		}
		writeln();
	}

	private void writeInstructions(List<IRInstruction> instructions) throws IOException {
		if (instructions.isEmpty()) {
			return;
		}

		final int instructionTime = getInstructionTime(instructions);
		writeIndentation();
		// processor cycles
		writeln("; " + instructionTime + " pc");

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

	private int getInstructionTime(List<IRInstruction> instructions) {
		int sum = 0;
		for (IRInstruction instruction : instructions) {
			switch (instruction) {
			case IRLabel ignored -> {}
			case IRComment ignored -> {}
			case IRAddrOf i -> {
				sum += getInstructionTime(i.source());
				sum += getInstructionTime(i.target());
				sum++;
			}
			case IRAddrOfArray i -> {
				sum += getInstructionTime(i.addr());
				sum++;
			}
			case IRBinary i -> {
				sum += getInstructionTime(i.left());
				sum += getInstructionTime(i.right());
				sum++;
				sum += getInstructionTime(i.target());
			}
			case IRBranch i -> {
				sum += getInstructionTime(i.conditionVar());
				sum++;
			}
			case IRCall i -> {
				for (IRVar arg : i.args()) {
					sum += getInstructionTime(arg);
				}
				sum++;
				if (i.target() != null) {
					sum += getInstructionTime(i.target());
				}
			}
			case IRCast i -> {
				sum += getInstructionTime(i.source());
				sum++;
				sum += getInstructionTime(i.target());
			}
			case IRMove i -> {
				sum += getInstructionTime(i.source());
				sum++;
				sum += getInstructionTime(i.target());
			}
			case IRJump i -> {
				sum++;
			}
			case IRLiteral i -> {
				sum += getInstructionTime(i.target());
			}
			case IRMemLoad i -> {
				sum += getInstructionTime(i.addr());
				sum += getInstructionTime(i.target());
				sum += 2;
			}
			case IRMemStore i -> {
				sum += getInstructionTime(i.addr());
				sum += getInstructionTime(i.value());
				sum += 2;
			}
			case IRRetValue i -> {
				sum += getInstructionTime(i.var());
				sum++;
			}
			case IRString i -> {
				sum++;
				sum += getInstructionTime(i.target());
			}
			case IRUnary i -> {
				sum += getInstructionTime(i.source());
				sum++;
				sum += getInstructionTime(i.target());
			}
			default -> throw new UnsupportedOperationException(String.valueOf(instruction));
			}
		}
		return sum;
	}

	private int getInstructionTime(IRVar var) {
		return 2;
	}

	private void writeGlobalVars(List<IRVarDef> globalVars) throws IOException {
		if (globalVars.isEmpty()) {
			return;
		}

		writeln("Global variables");
		for (IRVarDef var : globalVars) {
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
}
