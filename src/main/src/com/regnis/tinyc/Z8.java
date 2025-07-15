package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;
import com.regnis.tinyc.linearscanregalloc.*;

import java.io.*;
import java.nio.charset.*;
import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class Z8 extends AsmWriter {

	private static final int TMP_REG = 99;
	private static final int FIRST_REG = 0x20;

	private final LSArchitecture.Z8 architecture;
	private final int registerCount;

	private int tempLabelIndex;

	private Z8StackOffsets stackOffsets;

	public Z8(@NotNull BufferedWriter writer, @NotNull LSArchitecture.Z8 architecture) {
		super(writer);
		registerCount = architecture.registerCount();
		this.architecture = architecture;
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

	@Override
	protected void writeAddConst(IRAddConst addConst) throws IOException {
		final IRVar var = addConst.var();
		final int index = getRegister(var);
		int offset = addConst.offset();
		final int typeSize = getRegisterCount(var);
		if (offset > 0) {
			if (offset == 1 && typeSize == 1) {
				writeIndented("inc " + getRegName(index));
			}
			else if (offset == 1 && typeSize == 2 && (index & 1) == 0) {
				writeIndented("incw " + getRegName(index));
			}
			else {
				final int[] bytes = toBytes(offset, typeSize);
				String op = "add";
				for (int i = typeSize; i-- > 0; ) {
					writeIndented(op + " " + getRegName(index + i) + ", #%" + Utils.toHex2(bytes[i]));
					op = "adc";
				}
			}
		}
		else {
			offset = -offset;
			if (offset == 1 && typeSize == 1) {
				writeIndented("dec " + getRegName(index));
			}
			else if (offset == 1 && typeSize == 2 && (index & 1) == 0) {
				writeIndented("decw " + getRegName(index));
			}
			else {
				final int[] bytes = toBytes(offset, typeSize);
				String op = "sub";
				for (int i = typeSize; i-- > 0; ) {
					writeIndented(op + " " + getRegName(index + i) + ", #%" + Utils.toHex2(bytes[i]));
					op = "sbc";
				}
			}
		}
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
		case Add -> writeBinary("add", "adc", binary);
		case Sub -> writeBinary("sub", "sbc", binary);
		case Mul -> {
			notYetImplemented();
		}
		case Div, Mod -> {
			notYetImplemented();
		}

		case ShiftLeft, ShiftRight -> {
			notYetImplemented();
		}

		case And -> writeBinary("and", "and", binary);
		case Or -> writeBinary("or", "or", binary);
		case Xor -> writeBinary("xor", "xor", binary);

		default -> throw new UnsupportedOperationException(String.valueOf(binary));
		}
	}

	protected void writeBranch(IRBranch branch) throws IOException {
		final IRVar var = branch.conditionVar();
		final String reg = getRegName(var.index());
		writeIndented("or " + reg + ", " + reg);
		if (branch.jumpOnTrue()) {
			writeIndented("jp nz, " + branch.target());
		}
		else {
			writeIndented("jp z, " + branch.target());
		}
	}

	protected void writeCall(IRCall call) throws IOException {
		final LSCallingConvention callingConvention = architecture.getCallingConvention(call.type(), call.getArgumentTypes());
		final Iterator<Integer> argRegisters = callingConvention.argRegisters().iterator();
		for (IRVar arg : call.args()) {
			if (argRegisters.hasNext()) {
				argRegisters.next();
				continue;
			}

			if (arg.scope() == VariableScope.register) {
				final int index = arg.index();
				final int typeSize = getRegisterCount(arg);
				for (int i = 0; i < typeSize; i++) {
					writeIndented("push " + getRegName(index + i));
				}
			}
			else {
				writeComment("need to push " + arg.name());
			}
		}
		writeIndented("call " + call.name());
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

	@Override
	protected void writeCompare(IRCompareConst compare) throws IOException {
		final int value = compare.value();

		switch (compare.op()) {
		case Lt -> writeCompare(compare.target(), compare.left(), "lt", "ult", value);
		case LtEq -> writeCompare(compare.target(), compare.left(), "le", "ule", value);
		case Equals, NotEquals -> {
			final IRVar left = compare.left();
			final int sourceRegister = getRegister(left);
			final int targetRegister = getRegister(compare.target());
			final String targetReg = getRegName(targetRegister);
			final String label1 = createTempLabel();
			if (value == 0 && registerCount == 1) {
				final String sourceReg = getRegName(sourceRegister);
				writeIndented("or  " + sourceReg + ", " + sourceReg);
				writeIndented("ld  " + targetReg + ", #%" + Utils.toHex2(compare.op() == IRCompareOp.Equals ? 0 : -1));
				writeIndented("jr  nz, " + label1);
				writeIndented("com " + targetReg);
				writeLabel(label1);
			}
			else {
				final int[] bytes = toBytes(value, registerCount);
				final String label2 = createTempLabel();
				for (int i = 0; i < registerCount; i++) {
					writeIndented("cp  " + getRegName(sourceRegister + i) + ", #%" + Utils.toHex2(bytes[i]));
					writeIndented("jr  nz, " + label1);
				}
				writeIndented("ld  " + targetReg + ", #%" + Utils.toHex2(compare.op() == IRCompareOp.Equals ? -1 : 0));
				writeIndented("jr  " + label2);
				writeLabel(label1);
				writeIndented("ld  " + targetReg + ", #%" + Utils.toHex2(compare.op() == IRCompareOp.Equals ? 0 : -1));
				writeLabel(label2);
			}
		}
		case GtEq -> writeCompare(compare.target(), compare.left(), "ge", "uge", value);
		case Gt -> writeCompare(compare.target(), compare.left(), "gt", "uge", value);
		default -> throw new UnsupportedOperationException(String.valueOf(compare));
		}
	}

	private void writeCompare(IRVar target, IRVar left, String signedTrue, String unsignedTrue, int value) throws IOException {
		final int registerCount = getRegisterCount(left);
		final int sourceRegister = getRegister(left);

		final int targetRegister = getRegister(target);
		final boolean signed = left.type() != Type.U8;
		final int[] bytes = toBytes(value, registerCount);
		final String targetReg = getRegName(targetRegister);
		final String labelTrue = createTempLabel();
		final String labelFalse = createTempLabel();
		final String labelEnd = createTempLabel();
		for (int i = 0; i < registerCount; i++) {
			if (i != 0) {
				writeIndented("jr  nz, " + labelFalse);
			}
			writeIndented("cp  " + getRegName(sourceRegister + i) + ", #%" + Utils.toHex2(bytes[i]));
			writeIndented("jr  " + (i == 0 && signed ? signedTrue : unsignedTrue) + ", " + labelTrue);
		}
		writeLabel(labelTrue);
		writeIndented("ld  " + targetReg + ", #%" + Utils.toHex2(-1));
		writeIndented("jr  " + labelEnd);
		writeLabel(labelFalse);
		writeIndented("ld  " + targetReg + ", #%" + Utils.toHex2(0));
		writeLabel(labelEnd);
	}

	protected void writeMove(IRMove copy) throws IOException {
		final IRVar source = copy.source();
		final IRVar target = copy.target();
		final int typeSize = getRegisterCount(source);
		if (source.scope() == VariableScope.register && target.scope() == VariableScope.register) {
			final int sourceReg = getRegister(source);
			final int targetReg = getRegister(target);
			for (int i = 0; i < typeSize; i++) {
				writeIndented("ld " + getRegName(targetReg + i) + ", " + getRegName(sourceReg + i));
			}
			return;
		}
		notYetImplemented();
	}

	protected void writeLiteral(IRLiteral literal) throws IOException {
		final IRVar target = literal.target();
		if (target.scope() != VariableScope.register) {
			notYetImplemented();
			return;
		}
		final int index = getRegister(target);
		final int typeSize = getRegisterCount(target);
		final int value = literal.value();
		final int[] bytes = toBytes(value, typeSize);

		for (int i = 0; i < typeSize; i++) {
			writeIndented("ld " + getRegName(index + i) + ", #%" + Utils.toHex2(bytes[i]));
		}
	}

	protected void writeMemLoad(IRMemLoad load) throws IOException {
		final IRVar target = load.target();
		final int targetIndex = getRegister(target);

		final IRVar addr = load.addr();
		final int addrIndex = getRegister(addr);
		Utils.assertTrue((addrIndex & 1) == 0);
		final String addrReg = getRegName(addrIndex);

		final int typeSize = getRegisterCount(target);
		for (int i = 0; i < typeSize; i++) {
			if (i > 0) {
				writeIndented("incw " + addrReg);
			}
			writeIndented("lde " + getRegName(targetIndex + i) + ", r" + addrReg);
		}
		for (int i = 1; i < typeSize; i++) {
			writeIndented("decw " + addrReg);
		}
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
		final IRVar source = unary.source();
		final IRVar target = unary.target();
		switch (unary.op()) {
		case Neg -> {
			final int sourceReg = getRegister(source);
			final int targetReg = getRegister(target);
			if (sourceReg == targetReg) {
				final int registerCount = getRegisterCount(target);
				for (int i = 0; i < registerCount; i++) {
					writeIndented("com " + getRegName(targetReg + i));
				}
				if (registerCount == 1) {
					writeIndented("inc " + getRegName(targetReg));
				}
				else if (registerCount == 2 && (targetReg & 1) == 0) {
					writeIndented("incw " + getRegName(targetReg));
				}
				else {
					boolean first = true;
					for (int i = registerCount; i-- > 0; first = false) {
						if (first) {
							writeIndented("add " + getRegName(targetReg + i) + ", #%01");
						}
						else {
							writeIndented("adc " + getRegName(targetReg + i) + ", #%00");
						}
					}
				}
			}
			else {
				final int registerCount = getRegisterCount(target);
				for (int i = 0; i < registerCount; i++) {
					writeIndented("ld " + getRegName(targetReg + i) + ", #%00");
				}
				boolean first = true;
				for (int i = registerCount; i-- > 0; first = false) {
					if (first) {
						writeIndented("sub " + getRegName(targetReg + i) + ", " + getRegName(sourceReg + i));
					}
					else {
						writeIndented("sbc " + getRegName(targetReg + i) + ", " + getRegName(sourceReg + i));
					}
				}
			}
		}
		case Not -> {
			final int sourceReg = getRegister(source);
			final int targetReg = getRegister(target);
			final int registerCount = getRegisterCount(target);
			if (sourceReg != targetReg) {
				for (int i = 0; i < registerCount; i++) {
					writeIndented("ld " + getRegName(targetReg + i) + ", " + getRegName(sourceReg + i));
				}
			}
			for (int i = 0; i < registerCount; i++) {
				writeIndented("com " + getRegName(targetReg + i));
			}
		}
		case NotLog -> {
			notYetImplemented();
		}
		default -> throw new UnsupportedOperationException(String.valueOf(unary));
		}
	}

	protected void writeJump(IRJump jump) throws IOException {
		writeIndented("jp " + jump.label());
	}

	private void writePreample() throws IOException {
		writeIndented(".const RP  = %FD");
		writeIndented(".const SPH = %FE");
		writeIndented(".const SPL = %FF");
		writeNL();
		writeIndented(".org %E000");
		writeNL();
		writeLabel("start");
		writeIndented("push RP");
		writeIndented("srp  #%20");
		writeIndented("call @main");
		writeIndented("pop  RP");
		writeIndented("ret");
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

		final LSCallingConvention callingConvention = architecture.getCallingConvention(function.returnType(), function.varInfos().getArgumentTypes());
		final List<Integer> nonvolatileRegistersToPushPop = getNonVolatileRegistersToPushPop(function, callingConvention);
		final List<IRVarDef> localVars = function.varInfos().vars();
		stackOffsets = new Z8StackOffsets(localVars, nonvolatileRegistersToPushPop.size(), architecture);
		final int size = stackOffsets.getLocalVarsSize();
		writeVarOffsetAsComments(localVars);
		writeLabel(function.label());
		writeFunctionProlog(size, nonvolatileRegistersToPushPop);

		writeInstructions(function.instructions());

		writeFunctionEpilog(size, nonvolatileRegistersToPushPop);
	}

	private List<Integer> getNonVolatileRegistersToPushPop(IRFunction function, LSCallingConvention callingConvention) {
		final int maxReg = IRUtils.getMaxReg(function.instructions());
		final List<Integer> nonVolatileRegistersToPushPop = new ArrayList<>();
		for (int i = callingConvention.volatileRegisterCount(); i <= maxReg; i++) {
			nonVolatileRegistersToPushPop.add(i);
		}
		return Collections.unmodifiableList(nonVolatileRegistersToPushPop);
	}

	private void writeVarOffsetAsComments(List<IRVarDef> localVars) throws IOException {
		for (IRVarDef varDef : localVars) {
			final IRVar var = varDef.var();
			if (var.scope() == VariableScope.argument) {
				writeComment("  sp+" + stackOffsets.getOffset(var) + ": arg " + var.name());
			}
			else {
				Utils.assertTrue(var.scope() == VariableScope.function);
				writeComment("  sp+" + stackOffsets.getOffset(var) + ": var " + var.name());
			}
		}
	}

	private void writeFunctionProlog(int size, List<Integer> pushedNonvolatileRegisters) throws IOException {
		if (pushedNonvolatileRegisters.size() > 0) {
			writeComment("save globbered non-volatile registers");
			for (int reg : pushedNonvolatileRegisters) {
				writeIndented("push " + getRegName(reg));
			}
		}
		if (size > 0) {
			writeComment("reserve space for local variables");
			while (size-- > 0) {
				writeIndented("decw SPH");
			}
		}
	}

	private void writeFunctionEpilog(int size, List<Integer> pushedNonvolatileRegisters) throws IOException {
		if (size > 0) {
			writeComment("free space for local variables");
			while (size-- > 0) {
				writeIndented("incw SPH");
			}
		}

		if (pushedNonvolatileRegisters.size() > 0) {
			writeComment("restore globbered non-volatile registers");
			for (int i = pushedNonvolatileRegisters.size(); i-- > 0; ) {
				final int reg = pushedNonvolatileRegisters.get(i);
				writeIndented("pop " + getRegName(reg));
			}
		}

		writeIndented("ret");
	}

	private void writeBinary(String opLSB, String opXSB, IRBinary binary) throws IOException {
		final IRVar target = binary.target();
		final int targetIndex = target.index();
		final IRVar right = binary.right();
		final int sourceIndex = right.index();
		final int typeSize = getRegisterCount(target);
		String op = opLSB;
		for (int i = typeSize; i-- > 0; ) {
			writeIndented(op + " " + getRegName(targetIndex + i) + ", " + getRegName(sourceIndex + i));
			op = opXSB;
		}
	}

	private void writeCompare(String command, IRCompare compare) throws IOException {
		notYetImplemented();
	}

	private void writeCompare(String command, IRCompareConst compare) throws IOException {
		notYetImplemented();
	}

	private void notYetImplemented() throws IOException {
		writeIndented("not implemented");
	}

	private int getRegister(IRVar var) {
		Utils.assertTrue(var.scope() == VariableScope.register);
		return var.index();
	}

	private int getRegisterCount(IRVar var) {
		return architecture.registerCount(var.type());
	}

	private String createTempLabel() {
		tempLabelIndex++;
		return "." + tempLabelIndex;
	}

	private static String getRegName(int reg) {
		if (reg < 16) {
			return "r" + reg;
		}
		return "%" + Integer.toHexString(reg + FIRST_REG);
	}

	private static String encode(byte[] bytes) {
		final StringBuilder buffer = new StringBuilder();
		boolean stringIsOpen = false;
		for (byte b : bytes) {
			if (b >= FIRST_REG && b < 0x7f && b != '\'') {
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

	private static int[] toBytes(int value, int byteCount) {
		final int[] bytes = new int[byteCount];
		for (int i = 0; i < byteCount; i++) {
			bytes[byteCount - i - 1] = value & 0xFF;
			value >>= 8;
		}
		return bytes;
	}
}
