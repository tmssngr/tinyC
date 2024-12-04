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
public final class Z8 extends AsmOut {
	private int[] localVarOffsets = new int[0];

	public Z8(@NotNull BufferedWriter writer) {
		super(writer);
	}

	@Override
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

		writePostamble(program.varInfos(), program.stringLiterals());
	}

	private void writePreample() throws IOException {
		writeIndented("""
				              .const SPH = %FE
				              .const SPL = %FF

				              .org %C000""");
		writeNL();
		writeIndented("""
				              srp %20
				              jp @main""");
		writeNL();
	}

	private void writePostamble(IRVarInfos varInfos, List<IRStringLiteral> stringLiterals) throws IOException {
		writeNL();

		for (IRVarDef variable : varInfos.vars()) {
			writeComment("variable " + variable.getString());
			writeLabel(getGlobalVarName(variable.var().index()));
			final int size = variable.size();
			if (size > 1) {
				writeIndented(".repeat " + size);
			}
			writeIndented(".data 0");
			if (size > 1) {
				writeIndented(".end");
			}
		}
		writeNL();

		if (stringLiterals.size() > 0) {
			for (IRStringLiteral literal : stringLiterals) {
				writeLabel(getStringLiteralName(literal.index()));
				final String encoded = encode((literal.text()).getBytes(StandardCharsets.UTF_8));
				writeIndented(encoded);
			}
			writeNL();
		}
	}

	private void writeFunction(IRFunction function) throws IOException {
		writeComment(function.toString());

		final List<IRVarDef> localVars = function.varInfos().vars();
		final int size = prepareLocalVarsOffsets(localVars);
		writeVarOffsets(localVars);
		writeLabel(function.label());
		writeFunctionProlog(size);

		writeInstructions(function.instructions());

		writeFunctionEpilog(size);
		localVarOffsets = new int[0];
	}

	private void writeAsmFunction(IRAsmFunction function) throws IOException {
		writeComment(function.toString());

		writeLabel(function.label());
		writeAsm(function.asmLines());
	}

	private int prepareLocalVarsOffsets(List<IRVarDef> localVars) {
		localVarOffsets = new int[localVars.size()];
		int offset = 0;
		int i = 0;
		for (IRVarDef var : localVars) {
			if (var.var().scope() != VariableScope.argument) {
				final int varSize = var.size();
				localVarOffsets[i] = offset;
				offset += varSize;
			}
			i++;
		}
		final int localVarSize = offset;
		// first arg x bytes
		// second arg y bytes
		// ...
		// return address 2 bytes ----------------------
		// local vars <localVarSize> bytes              v
		int argOffset = localVarSize + 2;
		i = 0;
		for (IRVarDef var : localVars.reversed()) {
			if (var.var().scope() != VariableScope.argument) {
				continue;
			}

			final int varSize = var.size();
			argOffset += varSize;
			localVarOffsets[i] = argOffset;
			i++;
		}

		return localVarSize;
	}

	private void writeVarOffsets(List<IRVarDef> localVars) throws IOException {
		for (IRVarDef def : localVars) {
			final IRVar var = def.var();
			if (var.scope() == VariableScope.argument) {
				writeComment("  rsp+" + localVarOffsets[var.index()] + ": arg " + var.name());
			}
			else {
				writeComment("  rsp+" + localVarOffsets[var.index()] + ": var " + var.name());
			}
		}
	}

	private void writeFunctionProlog(int size) throws IOException {
		if (size > 0) {
			writeComment("reserve space for local variables");
			writeIndented("sub rsp, " + size);
		}
	}

	private void writeFunctionEpilog(int size) throws IOException {
		if (size > 0) {
			writeComment("release space for local variables");
			writeIndented("add rsp, " + size);
		}
		writeIndented("ret");
	}

	private void writeInstructions(List<IRInstruction> instructions) throws IOException {
		for (IRInstruction instruction : instructions) {
			writeInstruction(instruction);
		}
	}

	private void writeInstruction(IRInstruction instruction) throws IOException {
		if (!(instruction instanceof IRComment)
		    && !(instruction instanceof IRLabel)) {
			writeComment(String.valueOf(instruction));
		}

		switch (instruction) {
		case IRLabel label -> writeLabel(label.label());
		case IRComment comment -> writeComment(comment.comment());
		case IRAddrOf addrOf -> writeAddrOf(addrOf);
		case IRAddrOfArray addrOf -> writeAddrOfArray(addrOf);
		case IRLiteral literal -> writeLiteral(literal);
		case IRString literal -> writeString(literal);
		case IRMove copy -> writeCopy(copy);
		case IRBinary binary -> writeBinary(binary);
		case IRCompare compare -> writeCompare(compare);
		case IRUnary unary -> writeUnary(unary);
		case IRCast cast -> writeCast(cast);
		case IRMemLoad load -> writeLoad(load);
		case IRMemStore store -> writeStore(store);
		case IRBranch branch -> writeBranch(branch);
		case IRJump jump -> writeJump(jump);
		case IRCall call -> writeCall(call);
		case IRRetValue retValue -> writeRetValue(retValue);
		default -> throw new UnsupportedOperationException(instruction.getClass() + " " + instruction);
		}
	}

	private void writeAddrOf(IRAddrOf addrOf) throws IOException {
		final int addrReg = 0;
		addrOf(addrReg, addrOf.source());
		storeInReg(addrOf.target(), addrReg);
	}

	private void writeAddrOfArray(IRAddrOfArray addrOf) throws IOException {
/*
		final IRVar arrayOrPointer = addrOf.array();
		final IRVar index = addrOf.index();
		final IRVar target = addrOf.addr();

		final int indexReg = getRegisterVarRegisterIndex(index);
		final int targetReg = getRegisterVarRegisterIndex(target);

		final int size = getTypeSize(Objects.requireNonNull(arrayOrPointer.type().toType()));
		if (size != 1) {
			writeIndented("imul " + getRegName(indexReg) + ", " + size);
		}

		final String targetRegName = getRegName(targetReg);
		if (arrayOrPointer.scope() == VariableScope.register) {
			Utils.assertTrue(!addrOf.varIsArray());
			final String pointerRegName = getRegName(arrayOrPointer);
			if (targetReg == indexReg) {
				final int tmpReg = 0;
				final String tmpRegName = getRegName(tmpReg);
				writeIndented("mov " + tmpRegName + ", " + pointerRegName);
				writeIndented("add " + targetRegName + ", " + tmpRegName);
			}
			else {
				writeIndented("mov " + targetRegName + ", " + pointerRegName);
				writeIndented("add " + targetRegName + ", " + getRegName(indexReg));
			}
		}
		else {
			Utils.assertTrue(addrOf.varIsArray());
			if (targetReg == indexReg) {
				final int addrReg = 0;
				addrOf(addrReg, arrayOrPointer);
				writeIndented("add " + targetRegName + ", " + getRegName(addrReg));
			}
			else {
				addrOf(targetReg, arrayOrPointer);
				writeIndented("add " + targetRegName + ", " + getRegName(indexReg));
			}
		}
*/
	}

	private void writeLiteral(IRLiteral literal) throws IOException {
		final IRVar target = literal.target();
		int value = literal.value();
		if (target.scope() == VariableScope.register) {
			final int reg = target.index();
			final int size = getTypeSize(target.type());
			for (int i = size - 1; i >= 0; i--, value >>= 8) {
				writeIndented("ld r" + (reg * 4 + i) + ", " + (value & 0xFF));
			}
		}
		else {
			throw new UnsupportedOperationException();
/*
			final int register = 1;
			addrOf(register, target);
			final int typeSize = getTypeSize(target.type());
			writeIndented("mov " + getSizeWord(typeSize) + " [" + getRegName(register) + "], " + value);
*/
		}
	}

	private void writeString(IRString literal) throws IOException {
//		writeIndented("lea " + getRegName(literal.target()) + ", [" + getStringLiteralName(literal.stringIndex()) + "]");
	}

	private void writeCopy(IRMove copy) throws IOException {
/*
		final IRVar source = copy.source();
		final IRVar target = copy.target();
		final int addrReg = 1;
		if (source.scope() == VariableScope.register) {
			if (target.scope() == VariableScope.register) {
				writeIndented("mov " + getRegName(target) + ", " + getRegName(copy.source()));
				return;
			}

			addrOf(addrReg, target);
			writeIndented("mov [" + getRegName(addrReg) + "], " + getRegName(source));
			return;
		}

		Utils.assertTrue(target.scope() == VariableScope.register);
		addrOf(addrReg, source);
		writeIndented("mov " + getRegName(target) + ", [" + getRegName(addrReg) + "]");
*/
	}

	private void writeBinary(IRBinary binary) throws IOException {
		final boolean signed = binary.left().type() != Type.U8;
		switch (binary.op()) {
		case Add -> writeBinary("add", binary);
		case Sub -> writeBinary("sub", binary);
		case Mul -> {
/*
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
*/
		}
		case Div, Mod -> {
/*
			final Type type = binary.left().type();
			Utils.assertTrue(Objects.equals(type, binary.right().type()));
			final int size = getTypeSize(type);
			// https://www.felixcloutier.com/x86/idiv
			// (rdx rax) / %reg -> rax
			// (rdx rax) % %reg -> rdx
			final int leftReg = getRegisterVarRegisterIndex(binary.left());
			final String leftRegName = getRegName(leftReg);
			final int rightReg = getRegisterVarRegisterIndex(binary.right());
			final String rightRegName = getRegName(rightReg);
			final int targetReg = getRegisterVarRegisterIndex(binary.target());
			final String targetRegName = getRegName(targetReg);

			final int rdx = 3;
			Utils.assertTrue("rdx".equals(getRegName(rdx)));
			final boolean pushPopRdx = targetReg != rdx;
			if (pushPopRdx) {
				writeIndented("push rdx");
			}

			if (size == 8) {
				writeIndented("mov rax, " + leftRegName);
				writeIndented("mov rbx, " + rightRegName);
			}
			else {
				writeMovx("rax", leftReg, binary.left(), signed);
				writeMovx("rbx", rightReg, binary.right(), signed);
			}
			writeIndented("cqo"); // rdx := signbit(rax)
			writeIndented("idiv rbx");
			if (pushPopRdx) {
				writeIndented("mov " + targetRegName + ", " + (binary.op() == IRBinary.Op.Mod ? "rdx" : "rax"));
				writeIndented("pop rdx");
			}
			else if (binary.op() == IRBinary.Op.Div) {
				writeIndented("mov " + targetRegName + ", rax");
			}
*/
		}

		case ShiftLeft, ShiftRight -> {
/*
			final String op = binary.op() == IRBinary.Op.ShiftRight
					? signed ? "sar" : "shr"
					: signed ? "sal" : "shl";

			final int leftReg = getRegisterVarRegisterIndex(binary.left());
			final String leftRegName = getRegName(leftReg, binary.left());
			final int rightReg = getRegisterVarRegisterIndex(binary.right());
			final int targetReg = getRegisterVarRegisterIndex(binary.target());
			final String targetRegName = getRegName(targetReg, binary.target());

			final int cl = 2;
			Utils.assertTrue("cl".equals(getRegName(cl, 1)));
			final int tmpReg = 0;
			final String tmpRegName = getRegName(tmpReg, binary.left());
			if (targetReg == cl) {
				writeIndented("mov " + tmpRegName + ", " + leftRegName);
				if (targetReg != rightReg) {
					writeIndented("mov " + targetRegName + ", " + getRegName(rightReg, binary.right()));
				}
				writeIndented(op + " " + tmpRegName + ", cl");
				writeIndented("mov " + targetRegName + ", " + tmpRegName);
			}
			else {
				writeIndented("mov rbx, rcx");
				writeIndented("mov " + tmpRegName + ", " + leftRegName);
				if (rightReg != cl) {
					writeIndented("mov cl, " + getRegName(rightReg, 1));
				}
				writeIndented(op + " " + tmpRegName + ", cl");
				writeIndented("mov " + targetRegName + ", " + tmpRegName);
				writeIndented("mov rcx, rbx");
			}
*/
		}

		case And -> writeBinary("and", binary);
		case Or -> writeBinary("or", binary);
		case Xor -> writeBinary("xor", binary);

		default -> throw new UnsupportedOperationException(String.valueOf(binary));
		}
	}

	private void writeBinary(String op, IRBinary binary) throws IOException {
/*
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
			final int tmpReg = 0;
			final String tmpRegName = getRegName(tmpReg, target);
			writeIndented("mov " + tmpRegName + ", " + leftRegName);
			writeIndented(op + " " + tmpRegName + ", " + rightRegName);
			writeIndented("mov " + targetRegName + ", " + tmpRegName);
		}
		else {
			writeIndented("mov " + targetRegName + ", " + leftRegName);
			writeIndented(op + " " + targetRegName + ", " + rightRegName);
		}
*/
	}

	private void writeCompare(IRCompare binary) throws IOException {
		final boolean signed = binary.left().type() != Type.U8;
		switch (binary.op()) {
		case Lt -> writeCompare(signed ? "setl" : "setb", binary); // setb (below) = setc (carry)
		case LtEq -> writeCompare(signed ? "setle" : "setbe", binary);
		case Equals -> writeCompare("sete", binary);
		case NotEquals -> writeCompare("setne", binary);
		case GtEq -> writeCompare(signed ? "setge" : "setae", binary); // setae (above or equal) = setnc (not carry)
		case Gt -> writeCompare(signed ? "setg" : "seta", binary); // seta (above)

		default -> throw new UnsupportedOperationException(String.valueOf(binary));
		}
	}

	private void writeCompare(String command, IRCompare compare) throws IOException {
/*
		final int leftReg = getRegisterVarRegisterIndex(binary.left());
		final String leftRegName = getRegName(leftReg, binary.left());
		final int rightReg = getRegisterVarRegisterIndex(binary.right());
		final String rightRegName = getRegName(rightReg, binary.right());
		final int targetReg = getRegisterVarRegisterIndex(binary.target());
		writeIndented("cmp " + leftRegName + ", " + rightRegName);
		writeIndented(command + " " + getRegName(targetReg, 1));
*/
	}

	private void writeUnary(IRUnary unary) throws IOException {
		switch (unary.op()) {
		case Neg, Not -> {
/*
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
*/
		}
		case NotLog -> {
/*
			final int valueReg = getRegisterVarRegisterIndex(unary.source());
			final String regName = getRegName(valueReg, unary.source());
			writeIndented("or " + regName + ", " + regName);
			writeIndented("sete " + getRegName(unary.target()));
*/
		}
		default -> throw new UnsupportedOperationException(String.valueOf(unary));
		}
	}

	private void writeCast(IRCast cast) throws IOException {
/*
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
			writeIndented("mov " + getRegName(targetReg, targetSize) + ", " + getRegName(sourceReg, sourceSize));
		}
*/
	}

	private void writeLoad(IRMemLoad load) throws IOException {
/*
		final int addrReg = getRegisterVarRegisterIndex(load.addr());
		writeIndented("mov " + getRegName(load.target()) + ", [" + getRegName(addrReg) + "]");
*/
	}

	private void writeStore(IRMemStore store) throws IOException {
/*
		final int addrReg = getRegisterVarRegisterIndex(store.addr());
		writeIndented("mov [" + getRegName(addrReg) + "], " + getRegName(store.value()));
*/
	}

	private void writeBranch(IRBranch branch) throws IOException {
/*
		final int conditionReg = getRegisterVarRegisterIndex(branch.conditionVar());
		final String conditionRegName = getRegName(conditionReg, 1);
		writeIndented("or " + conditionRegName + ", " + conditionRegName);
*/
		if (branch.jumpOnTrue()) {
			writeIndented("jnz " + branch.target());
		}
		else {
			writeIndented("jz " + branch.target());
		}
		writeComment(branch.nextLabel());
	}

	private void writeCall(IRCall call) throws IOException {
/*
		final List<IRVar> args = call.args();
		final int argsSize = args.size() * 8;
		final int offset = (args.size() + 1) % 2 * 8;
		for (IRVar arg : args) {
			final int argValue = loadVar(arg);
			writeIndented("push " + getRegName(argValue));
			this.rspOffset += 8;
		}
		this.rspOffset = 0;

		if (offset != 0) {
			writeIndented("sub rsp, " + offset);
		}
		writeIndented("  call @" + call.name());
		writeIndented("add rsp, " + (offset + argsSize));

		final IRVar target = call.target();
		if (target != null) {
			Utils.assertTrue("rax".equals(getRegName(0)));
			final String valueRegName = getRegName(0, target);
			if (target.scope() == VariableScope.register) {
				writeIndented("mov " + getRegName(target) + ", " + valueRegName);
			}
			else {
				addrOf(1, target);
				writeIndented("mov [" + getRegName(1) + "], " + valueRegName);
			}
		}
*/
	}

	private void writeRetValue(IRRetValue retValue) throws IOException {
/*
		final int valueReg = getRegisterVarRegisterIndex(retValue.var());
		writeIndented("mov rax, " + getRegName(valueReg));
*/
	}

	private void storeInReg(IRVar var, int valueReg) throws IOException {
/*
		final String targetName = getRegName(var);
		final String valueRegName = getRegName(valueReg, var);
		writeIndented("mov " + targetName + ", " + valueRegName);
*/
	}

	private int loadVar(IRVar var) throws IOException {
/*
		if (var.scope() == VariableScope.register) {
			return getRegisterVarRegisterIndex(var);
		}

		final int reg = 0;
		addrOf(reg, var);
		final String addRegName = getRegName(reg);
		final String valueRegName = getRegName(reg, var);
		writeIndented("mov " + valueRegName + ", [" + addRegName + "]");
		return reg;
*/
		return 0;
	}

	private void addrOf(int register, IRVar var) throws IOException {
/*
		final String addrReg = getRegName(register);
		switch (var.scope()) {
		case global -> writeIndented("lea " + addrReg + ", [" + getGlobalVarName(var.index()) + "]");
		case function, argument -> {
			final int offset = localVarOffsets[var.index()] + rspOffset;
			writeIndented("lea " + addrReg + ", [rsp+" + offset + "]");
		}
		default -> throw new UnsupportedOperationException(String.valueOf(var.scope()));
		}
*/
	}

	private void writeJump(IRJump jump) throws IOException {
		writeIndented("jmp " + jump.label());
	}

	private static int getTypeSize(Type type) {
		if (type.isPointer()) {
			return 2;
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
