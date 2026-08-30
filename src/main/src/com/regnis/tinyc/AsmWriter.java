package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.io.*;
import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
abstract class AsmWriter {

	protected abstract void writeFunction(IRFunction function) throws IOException;

	protected abstract void writeAddrOf(int addrReg, IRVar source) throws IOException;

	protected abstract void writeAddrOfArray(int addrReg, IRVar arrayOrPointer) throws IOException;

	protected abstract void writeBinary(IRBinary.Op op, int targetReg, int leftReg, Type leftType, int rightReg, Type rightType) throws IOException;

	protected abstract void writeBranch(int conditionReg, boolean jumpOnTrue, String targetLabel) throws IOException;

	protected abstract void writeCall(String name) throws IOException;

	protected abstract void writeCast(int targetReg, Type targetType, int sourceReg, Type sourceType) throws IOException;

	protected abstract void writeCompare(IRCompare.Op op, int targetReg, int leftReg, int rightReg, Type leftRightType) throws IOException;

	protected abstract void writeJump(String label) throws IOException;

	protected abstract void writeLiteral(int targetReg, Type type, int value) throws IOException;

	protected abstract void writeMemLoad(int targetReg, Type type, int addrReg) throws IOException;

	protected abstract void writeMemStore(int addrReg, int valueReg, Type valueType) throws IOException;

	protected abstract void writeMove(int targetReg, int sourceReg, Type type) throws IOException;

	protected abstract void writeString(int targetReg, Type targetType, int stringLiteralIndex) throws IOException;

	protected abstract void writeUnary(IRUnary.Op op, int targetReg, Type targetType, int sourceReg, Type sourceType) throws IOException;

	private static final String INDENTATION = "        ";

	private final BufferedWriter writer;
	@SuppressWarnings("unused") private boolean debug;

	protected AsmWriter(@NotNull BufferedWriter writer) {
		this.writer = writer;
	}

	public void write(@NotNull IRProgram program) throws IOException {
		for (IRFunction function : program.functions()) {
			writeNL();
			writeFunction(function);
		}

		for (IRAsmFunction function : program.asmFunctions()) {
			writeNL();
			writeAsmFunction(function);
		}
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
			writeComment(instruction.toString(true));
		}

		switch (instruction) {
		case IRAddrOf addrOf -> {
			final IRVar source = addrOf.source();
			final IRVar target = addrOf.target();
			Utils.assertTrue(source.scope() != VariableScope.register);
			Utils.assertTrue(target.scope() == VariableScope.register);
			writeAddrOf(target.index(), source);
		}
		case IRAddrOfArray addrOf -> {
			final IRVar arrayOrPointer = addrOf.array();
			final IRVar addr = addrOf.addr();
			Utils.assertTrue(arrayOrPointer.scope() != VariableScope.register);
			Utils.assertTrue(addr.scope() == VariableScope.register);
			writeAddrOfArray(addr.index(), arrayOrPointer);
		}
		case IRBinary binary -> {
			final IRVar target = binary.target();
			final IRVar left = binary.left();
			final IRVar right = binary.right();
			Utils.assertTrue(target.scope() == VariableScope.register);
			Utils.assertTrue(left.scope() == VariableScope.register);
			Utils.assertTrue(right.scope() == VariableScope.register);
			writeBinary(binary.op(), target.index(), left.index(), left.type(), right.index(), right.type());
		}
		case IRBranch branch -> {
			final IRVar conditionVar = branch.conditionVar();
			Utils.assertTrue(conditionVar.scope() == VariableScope.register);
			writeBranch(conditionVar.index(), branch.jumpOnTrue(), branch.target());
		}
		case IRCall call -> {
			final IRVar target = call.target();
			if (target != null) {
				Utils.assertTrue(target.scope() == VariableScope.register);
				Utils.assertTrue(target.index() == 0);
			}
			writeCall(call.name());
		}
		case IRCast cast -> {
			final IRVar source = cast.source();
			final IRVar target = cast.target();
			Utils.assertTrue(source.scope() == VariableScope.register);
			Utils.assertTrue(target.scope() == VariableScope.register);
			writeCast(target.index(), target.type(), source.index(), source.type());
		}
		case IRComment comment -> writeComment(comment.comment());
		case IRCompare compare -> {
			final IRVar target = compare.target();
			final IRVar left = compare.left();
			final IRVar right = compare.right();
			Utils.assertTrue(target.scope() == VariableScope.register);
			Utils.assertTrue(left.scope() == VariableScope.register);
			Utils.assertTrue(right.scope() == VariableScope.register);
			writeCompare(compare.op(), target.index(), left.index(), right.index(), left.type());
		}
		case IRJump jump -> writeJump(jump.label());
		case IRLabel label -> writeLabel(label.label());
		case IRMemLoad load -> {
			final IRVar target = load.target();
			final IRVar addr = load.addr();
			Utils.assertTrue(target.scope() == VariableScope.register);
			Utils.assertTrue(addr.scope() == VariableScope.register);
			writeMemLoad(target.index(), target.type(), addr.index());
		}
		case IRMemStore store -> {
			final IRVar addr = store.addr();
			final IRVar value = store.value();
			Utils.assertTrue(addr.scope() == VariableScope.register);
			Utils.assertTrue(value.scope() == VariableScope.register);
			writeMemStore(addr.index(), value.index(), value.type());
		}
		case IRMove move -> {
			final IRVar target = move.target();
			Utils.assertTrue(target.scope() == VariableScope.register);
			final IRValue source = move.source();
			final IRVar sourceVar = source.var();
			if (sourceVar != null) {
				Utils.assertTrue(sourceVar.scope() == VariableScope.register);
				Utils.assertTrue(source.type().equals(target.type()));
				writeMove(target.index(), sourceVar.index(), target.type());
			}
			else {
				writeLiteral(target.index(), target.type(), source.value());
			}
		}
		case IRRetValue ignored -> throw new UnsupportedOperationException("must not be possible");
		case IRString literal -> {
			final IRVar target = literal.target();
			Utils.assertTrue(target.scope() == VariableScope.register);
			writeString(target.index(), target.type(), literal.stringIndex());
		}
		case IRUnary unary -> {
			final IRVar source = unary.source();
			final IRVar target = unary.target();
			Utils.assertTrue(source.scope() == VariableScope.register);
			Utils.assertTrue(target.scope() == VariableScope.register);
			writeUnary(unary.op(), target.index(), target.type(), source.index(), source.type());
		}
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

	protected List<List<IRVar>> getCalls(List<IRInstruction> instructions) {
		final List<List<IRVar>> calls = new ArrayList<>();
		instructions.forEach(instruction -> {
			if (instruction instanceof IRCall call) {
				calls.add(call.args());
			}
		});
		return calls;
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
