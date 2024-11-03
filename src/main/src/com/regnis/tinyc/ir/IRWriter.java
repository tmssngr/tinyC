package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.cfg.*;

import java.io.*;
import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class IRWriter extends TextWriter {

	private int loopLevel;

	public IRWriter(@NotNull BufferedWriter writer) {
		super(writer);
	}

	@Override
	protected void writeIndentation() throws IOException {
		super.writeIndentation();
		for (int i = loopLevel; i-- > 0; ) {
			super.writeIndentation();
		}
	}

	public void write(@NotNull IRProgram program) throws IOException {
		writeFunctions(program);
		writeGlobalVars(program.varInfos().vars());
		writeStringLiterals(program.stringLiterals());
	}

	public void write(ControlFlowGraph cfg) throws IOException {
		write("; CFG for function ");
		writeln(cfg.name());
		for (BasicBlock block : cfg.blocks()) {
			writeBlock(block);
			writeln();
		}
		writeln();
	}

	private void writeBlock(BasicBlock block) throws IOException {
		write("; block ");
		writeln(block.name);

		writeIndentation();
		write("; predecessors=");
		writeln(block.predecessors().toString());

		write(block.getLiveBefore());

		writeInstructions(block.instructions(), block);

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
		writeln(function.label() + ":");
		final List<IRVarDef> localVars = function.varInfos().vars();
		if (localVars.size() > 0) {
			writeln(" Local variables");
			for (IRVarDef varDef : localVars) {
				writeIndentation();
				write(varDef.var().scope() == VariableScope.argument ? "arg " : "var ");
				writeln(varDef.getString());
			}
		}

		loopLevel = 0;

		writeInstructions(function.instructions(), null);
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

	private void writeInstructions(List<IRInstruction> instructions, @Nullable BasicBlock block) throws IOException {
		if (instructions.isEmpty()) {
			return;
		}

		final int instructionTime = getInstructionTime(instructions);
		writeIndentation();
		// processor cycles
		writeln("; " + instructionTime + " pc");

		for (int i = 0; i < instructions.size(); i++) {
			final IRInstruction instruction = instructions.get(i);
			if (instruction instanceof IRLabel label) {
				writeln(label.label() + ":");
				loopLevel = label.loopLevel();
			}
			else {
				writeIndentation();
				if (instruction instanceof IRComment c) {
					writeln("; " + c.comment());
				}
				else {
					writeln(instruction.toString());
					if (block != null) {
						try {
							write(block.getLiveAfter(i));
						}
						catch (NullPointerException e) {
							writeln("##########################");
						}
					}
				}
			}
		}
	}

	private int getInstructionTime(List<IRInstruction> instructions) {
		int sum = 0;
		for (IRInstruction instruction : instructions) {
			switch (instruction) {
			case IRLabel ignored -> {
			}
			case IRComment ignored -> {
			}
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
			case IRCompare i -> {
				sum += getInstructionTime(i.left());
				sum += getInstructionTime(i.right());
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
		return var.scope() != VariableScope.register ? 2 : 0;
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
