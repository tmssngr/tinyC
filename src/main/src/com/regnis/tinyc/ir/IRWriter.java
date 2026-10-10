package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.cfg.*;

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
		writeGlobalVars(program.varInfos().vars());
		writeStringLiterals(program.stringLiterals());
	}

	public void write(ControlFlowGraph cfg, VarLiveness liveness) throws IOException {
		write("; CFG for function ");
		writeln(cfg.name());
		for (BasicBlock block : cfg.blocks()) {
			writeBlock(block, liveness.get(block.name));
			writeln();
		}
		writeln();
	}

	private void writeBlock(BasicBlock block, VarLiveness.Block liveness) throws IOException {
		write("; block ");
		writeln(block.name);

		writeIndentation();
		write("; predecessors=");
		writeln(block.predecessors().toString());

		write(liveness.getLiveBefore());

		writeInstructions(block.instructions(), liveness);

		writeIndentation();
		write("; successors=");
		writeln(block.successors().toString());
	}

	private void write(Set<IRVar> live) throws IOException {
//		write("; live: ");
		if (!live.isEmpty()) {
			writeIndentation();
			writeIndentation();
			write(String.valueOf(live.size()));
			write(": ");
			final List<IRVar> vars = new ArrayList<>(live);
			vars.sort(Comparator.comparing(IRVar::name));
			boolean addComma = false;
			for (IRVar var : vars) {
				if (addComma) {
					write(", ");
				}
				write(var.name());
				addComma = true;
			}
			writeln();
		}
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
		writeln(function.name() + ":");
		final List<IRVarDef> localVars = function.varInfos().vars();
		final List<IRInstruction> instructions = function.instructions();
		if (localVars.size() > 0) {
			writeln(" Local variables");
			for (IRVarDef varDef : localVars) {
				writeIndentation();
				write(varDef.var().scope() == VariableScope.parameter ? "arg " : "var ");
				writeln(varDef.getString());
			}
			if (instructions.size() > 0) {
				writeln();
			}
		}

		writeInstructions(instructions, null);
		writeln();
	}

	private void writeAsmFunction(IRAsmFunction function) throws IOException {
		writeln(function.name() + ":");
		for (String asmLine : function.asmLines()) {
			writeIndentation();
			writeln(asmLine);
		}
		writeln();
	}

	private void writeInstructions(List<IRInstruction> instructions, VarLiveness.Block liveness) throws IOException {
		if (instructions.isEmpty()) {
			return;
		}

		for (int i = 0; i < instructions.size(); i++) {
			final IRInstruction instruction = instructions.get(i);
			if (instruction instanceof IRLabel label) {
				writeln(label.label() + ":");
			}
			else {
				writeIndentation();
				if (instruction instanceof IRComment c) {
					writeln("; " + c.comment());
				}
				else {
					writeln(instruction.toString(true));
					if (liveness != null) {
						write(liveness.getLiveAfter(i));
					}
				}
			}
		}
	}

	private void writeGlobalVars(List<IRVarDef> globalVars) throws IOException {
		if (globalVars.isEmpty()) {
			return;
		}

		writeln("Global variables");
		for (IRVarDef def : globalVars) {
			writeIndentation();
			writeln(def.getString());
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
