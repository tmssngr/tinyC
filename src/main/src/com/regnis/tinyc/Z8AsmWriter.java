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
final class Z8AsmWriter extends AsmWriter {

	private static final int FIRST_NON_VOLATILE_REGISTER = 8;
	private final LSCallingConventionProvider callingConventionProvider;

	private int localJumpIndex;
	private Z8StackOffsets stackOffsets;

	public Z8AsmWriter(@NotNull BufferedWriter writer, @NotNull LSCallingConventionProvider callingConventionProvider) {
		super(writer);
		this.callingConventionProvider = callingConventionProvider;
	}

	@Override
	public void write(@NotNull IRProgram program) throws IOException {
		writeLines("""
				                   .const  RP    = %FD
				                   .const  SPH   = %FE
				                   .const  SPL   = %FF

				                   .org %e000

				           start:
				                   srp  #%20
				                   jr   main
				           """);
		super.write(program);

		writePostamble(program.varInfos().vars(), program.stringLiterals());
	}

	@Override
	protected void writeFunction(IRFunction function) throws IOException {
		writeComment(function.toString());

		final List<IRInstruction> instructions = function.instructions();

		final List<IRVarDef> localVars = function.varInfos().vars();

		final Pair<Integer, Integer> nonVolatileRegisterToPushPopResult = getNonVolatileRegistersToPushPop(localVars, instructions);
		final int firstGlobberedNonVolatileRegister = nonVolatileRegisterToPushPopResult.first();
		final int globberedNonVolatileRegisterCount = nonVolatileRegisterToPushPopResult.second();

		final List<List<IRVar>> callsArgs = getCalls(instructions);
		stackOffsets = Z8StackOffsets.createInstance(localVars, callsArgs, globberedNonVolatileRegisterCount, callingConventionProvider);

		final int rspOffset = stackOffsets.getRspOffset();
		final int callArgSpace = stackOffsets.getCallArgSpace();
		writeVarOffsetAsComments(localVars);

		writeLabel(function.label());
//		writeFunctionProlog(rspOffset, nonvolatileRegistersToPushPop, callArgSpace);
		writeFunctionProlog(firstGlobberedNonVolatileRegister, globberedNonVolatileRegisterCount);

		writeInstructions(instructions);

//		writeFunctionEpilog(rspOffset, nonvolatileRegistersToPushPop, callArgSpace);
		writeFunctionEpilog(firstGlobberedNonVolatileRegister, globberedNonVolatileRegisterCount);
		stackOffsets = null;
	}

	@Override
	protected void writeAddrOf(int addrReg, IRVar source) throws IOException {
		Utils.assertTrue((addrReg & 1) == 0);
		final VariableScope scope = source.scope();
		if (scope == VariableScope.global) {
			final String globalVarLabel = escapeLabel(getGlobalVarName(source.index()));
			writeIndented("ld   " + regName(addrReg) + ", #hi(" + globalVarLabel + ")");
			writeIndented("ld   " + regName(addrReg + 1) + ", #lo(" + globalVarLabel + ")");
			return;
		}

		Utils.assertTrue(scope == VariableScope.function
		                 || scope == VariableScope.parameter);

		int offset = stackOffsets.getOffset(source);
		Utils.assertTrue(offset >= 0, "impossible writing to register arg");

		writeIndented("ld   " + regName(addrReg) + ", SPH");
		writeIndented("ld   " + regName(addrReg + 1) + ", SPL");
		if (offset > 0) {
			writeIndented("add  " + regName(addrReg + 1) + ", #%" + Utils.toHex(offset & 0xFF, 2));
			offset >>= 8;
			writeIndented("adc  " + regName(addrReg) + ", #%" + Utils.toHex(offset & 0xFF, 2));
		}
	}

	@Override
	protected void writeAddrOfArray(int addrReg, IRVar arrayOrPointer) throws IOException {
		if (arrayOrPointer.scope() == VariableScope.global) {
			final String globalVarLabel = escapeLabel(getGlobalVarName(arrayOrPointer.index()));
			writeIndented("ld   " + regName(addrReg) + ", #hi(" + globalVarLabel + ")");
			writeIndented("ld   " + regName(addrReg + 1) + ", #lo(" + globalVarLabel + ")");
			return;
		}
		notSupportedYet("addrofarray");
	}

	@Override
	protected void writeBinary(IRBinary.Op op, int targetReg, int leftReg, Type leftType, int rightReg, Type rightType) throws IOException {
		Utils.assertTrue(targetReg == leftReg);
		switch (op) {
		case Add -> {
			final int byteCount = getByteCount(leftType);
			Utils.assertTrue(byteCount == getByteCount(rightType));
			Utils.assertTrue(!isRegisterOverlap(targetReg, rightReg, byteCount));
			targetReg += byteCount - 1;
			rightReg += byteCount - 1;
			for (int i = 0; i < byteCount; i++, targetReg--, rightReg--) {
				writeIndented((i == 0 ? "add" : "adc")
				              + "  "
				              + regName(targetReg)
				              + ", "
				              + regName(rightReg));
			}
		}
		case Sub -> {
			final int byteCount = getByteCount(leftType);
			Utils.assertTrue(byteCount == getByteCount(rightType));
			Utils.assertTrue(!isRegisterOverlap(targetReg, rightReg, byteCount));
			targetReg += byteCount - 1;
			rightReg += byteCount - 1;
			for (int i = 0; i < byteCount; i++, targetReg--, rightReg--) {
				writeIndented((i == 0 ? "sub" : "sbc")
				              + "  "
				              + regName(targetReg)
				              + ", "
				              + regName(rightReg));
			}
		}
		case And -> logic("and", targetReg, leftReg, rightReg, leftType, rightType);
		case Or -> logic("or ", targetReg, leftReg, rightReg, leftType, rightType);
		case Xor -> logic("xor", targetReg, leftReg, rightReg, leftType, rightType);
		case ShiftLeft -> {
			final int localJumpIndex = ++this.localJumpIndex;
			final String nextLabel = ".next" + localJumpIndex;
			final String shiftLabel = ".shift" + localJumpIndex;
			rightReg += getByteCount(rightType) - 1;
			final String rightRegName = regName(rightReg);
			final int byteCount = getByteCount(leftType);
			writeIndented("or   " + rightRegName + ", " + rightRegName);
			writeIndented("jr   z, " + nextLabel);
			writeIndented("push " + rightRegName);
			writeLabel(shiftLabel);
			writeIndented("rcf");
			for (int i = targetReg + byteCount; i-- > targetReg; ) {
				writeIndented("rlc  " + regName(i));
			}
			writeIndented("djnz " + rightRegName + ", " + shiftLabel);
			writeIndented("pop  " + rightRegName);
			writeLabel(nextLabel);
		}
		case ShiftRight -> {
			final boolean signed = leftType != Type.U8;
			final int localJumpIndex = ++this.localJumpIndex;
			final String nextLabel = ".next" + localJumpIndex;
			final String shiftLabel = ".shift" + localJumpIndex;
			rightReg += getByteCount(rightType) - 1;
			final String rightRegName = regName(rightReg);
			final int byteCount = getByteCount(leftType);
			writeIndented("or   " + rightRegName + ", " + rightRegName);
			writeIndented("jr   z, " + nextLabel);
			writeIndented("push " + rightRegName);
			writeLabel(shiftLabel);
			if (!signed) {
				writeIndented("rcf");
			}
			for (int i = 0; i < byteCount; i++) {
				if (signed && i == 0) {
					writeIndented("sra  " + regName(targetReg + i));
				}
				else {
					writeIndented("rrc  " + regName(targetReg + i));
				}
			}
			writeIndented("djnz " + rightRegName + ", " + shiftLabel);
			writeIndented("pop  " + rightRegName);
			writeLabel(nextLabel);
		}
		case Mul -> mulDivMod("call %00BA ; mul", leftReg, leftType, rightReg, rightType);
		case Div -> mulDivMod("call %00E0 ; div", leftReg, leftType, rightReg, rightType);
		case Mod -> mulDivMod("call %011F ; mod", leftReg, leftType, rightReg, rightType);
		}
	}

	private void mulDivMod(String call, int leftReg, Type leftType, int rightReg, Type rightType) throws IOException {
		Utils.assertTrue(leftType == rightType);
		if (leftType == Type.I16) {
			writeIndented("ld   %12, " + regName(leftReg));
			writeIndented("ld   %13, " + regName(leftReg + 1));
			writeIndented("ld   %14, " + regName(rightReg));
			writeIndented("ld   %15, " + regName(rightReg + 1));
			writeIndented("srp  #%10");
			writeIndented(call);
			writeIndented("srp  #%20");
			writeIndented("ld   " + regName(leftReg) + ", %12");
			writeIndented("ld   " + regName(leftReg + 1) + ", %13");
		}
		else {
			notSupportedYet("mul/div/mod for " + leftType);
		}
	}

	@Override
	protected void writeBranch(int conditionReg, boolean jumpOnTrue, String targetLabel) throws IOException {
		writeIndented("or   " + regName(conditionReg) + ", " + regName(conditionReg));
		if (jumpOnTrue) {
			writeIndented("jr   nz, " + escapeLabel(targetLabel));
		}
		else {
			writeIndented("jr   z, " + escapeLabel(targetLabel));
		}
	}

	@Override
	protected void writeCall(String name) throws IOException {
		writeIndented("call " + escapeLabel(name));
	}

	@Override
	protected void writeCast(int targetReg, Type targetType, int sourceReg, Type sourceType) throws IOException {
		int targetByteCount = getByteCount(targetType);
		int sourceByteCount = getByteCount(sourceType);
		if (targetByteCount < sourceByteCount) {
			sourceReg += sourceByteCount - targetByteCount;
			for (int i = 0; i < targetByteCount; i++, targetReg++, sourceReg++) {
				writeIndented("ld   " + regName(targetReg) + ", " + regName(sourceReg));
			}
		}
		else if (targetByteCount > sourceByteCount) {
			final boolean signed = sourceType != Type.U8;
			if (signed) {
				int targetReg1 = targetReg + targetByteCount - 1;
				int sourceReg1 = sourceReg + sourceByteCount - 1;
				if (targetReg1 > sourceReg1) {
					int zeroCount = targetByteCount - sourceByteCount;
					for (; sourceByteCount > 0; targetByteCount--, sourceByteCount--, targetReg1--, sourceReg1--) {
						if (targetReg1 != sourceReg1) {
							writeIndented("ld   " + regName(targetReg1) + ", " + regName(sourceReg1));
						}
					}
					writeIndented("ld   " + regName(targetReg) + ", " + regName(sourceReg));
					writeIndented("rl   " + regName(targetReg));
					for (; zeroCount-- > 0; targetReg++) {
						writeIndented("sbc  " + regName(targetReg) + ", " + regName(targetReg));
					}
				}
				else {
					throw new UnsupportedOperationException("not implemented");
				}
			}
			else {
				targetReg += targetByteCount - 1;
				sourceReg += sourceByteCount - 1;
				for (; targetByteCount > 0; targetByteCount--, sourceByteCount--, targetReg--, sourceReg--) {
					if (sourceByteCount <= 0) {
						writeIndented("ld   " + regName(targetReg) + ", #0");
					}
					else if (targetReg != sourceReg) {
						writeIndented("ld   " + regName(targetReg) + ", " + regName(sourceReg));
					}
				}
			}
		}
		else {
			throw new UnsupportedOperationException("not implemented");
		}
	}

	@Override
	protected void writeCompare(IRCompare.Op op, int targetReg, int leftReg, int rightReg, Type leftRightType) throws IOException {
		final int byteCount = getByteCount(leftRightType);
		Utils.assertTrue(!isRegisterOverlap(leftReg, rightReg, byteCount));
		final boolean signed = leftRightType != Type.U8;
		switch (op) {
		case Lt -> writeCompare(signed ? "lt" : "ult", "ult",
		                        signed ? "ge" : "uge", "uge", targetReg, leftReg, rightReg, byteCount);
		case LtEq -> writeCompare(signed ? "le" : "ule", "ule",
		                          signed ? "gt" : "ugt", "ugt", targetReg, leftReg, rightReg, byteCount);
		case GtEq -> writeCompare(signed ? "ge" : "uge", "uge",
		                          signed ? "lt" : "ult", "ult", targetReg, leftReg, rightReg, byteCount);
		case Gt -> writeCompare(signed ? "gt" : "ugt", "ugt",
		                        signed ? "le" : "ule", "ule", targetReg, leftReg, rightReg, byteCount);
		case Equals -> {
			final int localJumpIndex = ++this.localJumpIndex;
			final String falseLabel = ".ne" + localJumpIndex;
			final String nextLabel = "." + localJumpIndex;
			for (int i = 0; i < byteCount; i++, leftReg++, rightReg++) {
				writeIndented("cp   " + regName(leftReg) + ", " + regName(rightReg));
				writeIndented("jr   ne, " + falseLabel);
			}

			writeIndented("ld   " + regName(targetReg) + ", #1  ; true");
			writeIndented("jr   " + nextLabel);

			writeLabel(falseLabel);
			writeIndented("ld   " + regName(targetReg) + ", #0");

			writeLabel(nextLabel);
		}
		case NotEquals -> {
			final int localJumpIndex = ++this.localJumpIndex;
			final String trueLabel = ".ne" + localJumpIndex;
			final String nextLabel = "." + localJumpIndex;
			for (int i = 0; i < byteCount; i++, leftReg++, rightReg++) {
				writeIndented("cp   " + regName(leftReg) + ", " + regName(rightReg));
				writeIndented("jr   ne, " + trueLabel);
			}

			writeIndented("ld   " + regName(targetReg) + ", #0  ; false");
			writeIndented("jr   " + nextLabel);

			writeLabel(trueLabel);
			writeIndented("ld   " + regName(targetReg) + ", #1");

			writeLabel(nextLabel);
		}
		}
	}

	@Override
	protected void writeJump(String label) throws IOException {
		writeIndented("jr   " + escapeLabel(label));
		writeNL();
	}

	@Override
	protected void writeLiteral(int targetReg, Type type, int value) throws IOException {
		final List<String> commands = new ArrayList<>();
		for (int i = getByteCount(type); i-- > 0; ) {
			commands.addFirst("ld   " + regName(targetReg + i) + ", #%" + Utils.toHex(value & 0xFF, 2));
			value >>= 8;
		}

		for (String command : commands) {
			writeIndented(command);
		}
	}

	@Override
	protected void writeMemLoad(int targetReg, Type type, int addrReg) throws IOException {
		Utils.assertTrue((addrReg & 1) == 0);
		final int byteCount = getByteCount(type);
		for (int i = 0; i < byteCount; i++, targetReg++) {
			if (i > 0) {
				final StringBuilder buffer = new StringBuilder();
				buffer.append("incw ");
				getRegisterName(addrReg, buffer);
				writeIndented(buffer.toString());
			}
			final StringBuilder buffer = new StringBuilder();
			buffer.append("lde  ");
			getRegisterName(targetReg, buffer);
			buffer.append(", @r");
			getRegisterName(addrReg, buffer);
			writeIndented(buffer.toString());
		}
	}

	@Override
	protected void writeMemStore(int addrReg, int valueReg, Type type) throws IOException {
		Utils.assertTrue((addrReg & 1) == 0);
		final int byteCount = getByteCount(type);
		for (int i = 0; i < byteCount; i++, valueReg++) {
			if (i > 0) {
				final StringBuilder buffer = new StringBuilder();
				buffer.append("incw ");
				getRegisterName(addrReg, buffer);
				writeIndented(buffer.toString());
			}
			final StringBuilder buffer = new StringBuilder();
			buffer.append("lde  @r");
			getRegisterName(addrReg, buffer);
			buffer.append(", ");
			getRegisterName(valueReg, buffer);
			writeIndented(buffer.toString());
		}
	}

	@Override
	protected void writeMove(int targetReg, int sourceReg, Type type) throws IOException {
		final int byteCount = getByteCount(type);
		if (isRegisterOverlap(targetReg, sourceReg, byteCount)) {
			targetReg += byteCount - 1;
			sourceReg += byteCount - 1;
			for (int i = 0; i < byteCount; i++, targetReg--, sourceReg--) {
				writeMove(targetReg, sourceReg);
			}
		}
		else {
			for (int i = 0; i < byteCount; i++, targetReg++, sourceReg++) {
				writeMove(targetReg, sourceReg);
			}
		}
	}

	@Override
	protected void writeString(int targetReg, Type targetType, int stringLiteralIndex) throws IOException {
		final String stringLabel = escapeLabel(getStringLiteralName(stringLiteralIndex));
		writeIndented("ld   " + regName(targetReg) + ", #hi(" + stringLabel + ")");
		writeIndented("ld   " + regName(targetReg + 1) + ", #lo(" + stringLabel + ")");
	}

	@Override
	protected void writeUnary(IRUnary.Op op, int targetReg, Type targetType, int sourceReg, Type sourceType) throws IOException {
		Utils.assertTrue(Objects.equals(targetType, sourceType));
		final int byteCount = getByteCount(targetType);
		switch (op) {
		case Neg -> {
			if (sourceReg == targetReg) {
				for (int i = 0; i < byteCount; i++, targetReg++) {
					writeIndented("com  " + regName(targetReg));
				}

				if (byteCount == 1) {
					writeIndented("inc  " + regName(sourceReg));
				}
				else if (byteCount == 2 && (sourceReg & 1) == 0) {
					writeIndented("incw " + regName(sourceReg));
				}
				else {
					targetReg--;
					writeIndented("sub  " + regName(targetReg) + ", #1");
					targetReg--;
					for (int i = 1; i < byteCount; i++, targetReg--) {
						writeIndented("sbc  " + regName(targetReg) + ", #0");
					}
				}
				return;
			}
			Utils.assertTrue(!isRegisterOverlap(targetReg, sourceReg, byteCount));
			writeLiteral(targetReg, targetType, 0);
			writeBinary(IRBinary.Op.Sub, targetReg, targetReg, targetType, sourceReg, sourceType);
		}
		case Not -> {
			if (sourceReg != targetReg) {
				writeMove(targetReg, sourceReg, targetType);
			}
			for (int i = 0; i < byteCount; i++, targetReg++) {
				writeIndented("com  " + regName(targetReg));
			}
		}
		case NotLog -> {
			Utils.assertTrue(targetType.equals(Type.BOOL));

			final int jumpIndex = ++this.localJumpIndex;
			final String nextLabel = "." + jumpIndex;

			final String sourceRegName = regName(sourceReg);
			final String targetRegName = regName(targetReg);

			writeIndented("or   " + sourceRegName + ", " + sourceRegName);
			writeIndented("ld   " + targetRegName + ", #0  ; false");
			writeIndented("jr   nz, " + nextLabel);
			writeIndented("ld   " + targetRegName + ", #1  ; true");
			writeLabel(nextLabel);
		}
		default -> throw new UnsupportedOperationException(String.valueOf(op));
		}
	}

	@Override
	protected void writeLabel(String label) throws IOException {
		label = escapeLabel(label);
		super.writeLabel(label);
	}

	private String escapeLabel(String label) {
		final StringBuilder buffer = new StringBuilder();
		for (int i = 0, len = label.length(); i < len; i++) {
			final char chr = label.charAt(i);
			if (Utils.isInInterval(chr, '0', '9')
			    || Utils.isInInterval(chr, 'A', 'Z')
			    || Utils.isInInterval(chr, 'a', 'z')) {
				buffer.append(chr);
				continue;
			}
			if (i == 0) {
				if (chr == '.') {
					buffer.append(chr);
					continue;
				}
				if (chr == '@') {
					continue;
				}
			}
			if (chr == '_') {
				buffer.append("__");
				continue;
			}
			if (chr == '@') {
				buffer.append("_P");
				continue;
			}
			if (chr < 0x80) {
				buffer.append("_");
				buffer.append(Utils.toHex(chr, 2));
				continue;
			}

			buffer.append("_u");
			buffer.append(Utils.toHex(chr, 4));
		}
		return buffer.toString();
	}

	private Pair<Integer, Integer> getNonVolatileRegistersToPushPop(List<IRVarDef> varDefs, List<IRInstruction> instructions) {
		int firstNonVolatileRegister = FIRST_NON_VOLATILE_REGISTER;
		for (IRVarDef def : varDefs) {
			final IRVar var = def.var();
			if (var.scope() != VariableScope.parameter) {
				break;
			}

			final int index = var.index();
			firstNonVolatileRegister = Math.max(firstNonVolatileRegister, index + def.size() - 1);
		}

		final int maxReg = IRUtils.getMaxReg(instructions, Type.I16);
		return new Pair<>(firstNonVolatileRegister, Math.max(0, maxReg - firstNonVolatileRegister));
	}

	private void writePostamble(List<IRVarDef> globalVariables, List<IRStringLiteral> stringLiterals) throws IOException {
		if (globalVariables.size() > 0) {
			writeNL();
			writeGlobalVariables(globalVariables);
		}

		if (stringLiterals.size() > 0) {
			writeNL();
			writeStringLiterals(stringLiterals);
		}
	}

	private void writeGlobalVariables(List<IRVarDef> globalVariables) throws IOException {
		for (IRVarDef variable : globalVariables) {
			writeComment("variable " + variable.getString());
			writeLabel(getGlobalVarName(variable.var().index()));

			final StringBuilder buffer = new StringBuilder();
			int count = variable.size();
			while (count > 0) {
				buffer.append(".data");
				final int countPerRow = Math.min(32, count);
				buffer.repeat(" %00", countPerRow);
				writeIndented(buffer.toString());
				buffer.setLength(0);
				count -= countPerRow;
			}
		}
	}

	private void writeStringLiterals(List<IRStringLiteral> stringLiterals) throws IOException {
		for (IRStringLiteral literal : stringLiterals) {
			writeLabel(getStringLiteralName(literal.index()));

			final String encoded = encode(literal.text().getBytes(StandardCharsets.UTF_8));
			writeIndented(".data " + encoded);
		}
		writeNL();
	}

	private void logic(String op, int targetReg, int leftReg, int rightReg, Type leftType, Type rightType) throws IOException {
		Utils.assertTrue(targetReg == leftReg);
		final int byteCount = getByteCount(leftType);
		Utils.assertTrue(byteCount == getByteCount(rightType));
		Utils.assertTrue(!isRegisterOverlap(targetReg, rightReg, byteCount));
		for (int i = 0; i < byteCount; i++, targetReg++, rightReg++) {
			writeIndented(op + "  " + regName(targetReg) + ", " + regName(rightReg));
		}
	}

	private void writeCompare(String msbTrueOp, String lsbTrueOp,
	                          String msbFalseOp, String lsbFalseOp, int targetReg, int leftReg, int rightReg, int byteCount) throws IOException {
		final int localJumpIndex = ++this.localJumpIndex;
		final String trueLabel = ".true" + localJumpIndex;
		final String falseLabel = ".false" + localJumpIndex;
		final String nextLabel = "." + localJumpIndex;
		for (int i = 0; i < byteCount; i++, leftReg++, rightReg++) {
			writeIndented("cp   " + regName(leftReg) + ", " + regName(rightReg));
			if (i < byteCount - 1) {
				writeIndented("jr   " + (i == 0 ? msbTrueOp : lsbTrueOp) + ", " + trueLabel);
				writeIndented("jr   ne, " + falseLabel);
			}
			else {
				writeIndented("jr   " + (i == 0 ? msbFalseOp : lsbFalseOp) + ", " + falseLabel);
			}
		}

		writeLabel(trueLabel);
		writeIndented("ld   " + regName(targetReg) + ", #1");
		writeIndented("jr   " + nextLabel);

		writeLabel(falseLabel);
		writeIndented("ld   " + regName(targetReg) + ", #0");

		writeLabel(nextLabel);
	}

	private void writeMove(int targetReg, int sourceReg) throws IOException {
		final StringBuilder buffer = new StringBuilder();
		buffer.append("ld   ");
		getRegisterName(targetReg, buffer);
		buffer.append(", ");
		getRegisterName(sourceReg, buffer);
		writeIndented(buffer.toString());
	}

	private void writeVarOffsetAsComments(List<IRVarDef> localVars) throws IOException {
		final StringBuilder buffer = new StringBuilder();
		for (IRVarDef varDef : localVars) {
			final IRVar var = varDef.var();
			final int offset = stackOffsets.getOffset(var);
			buffer.setLength(0);
			if (var.scope() == VariableScope.parameter) {
				buffer.append("arg");
			}
			else {
				Utils.assertTrue(var.scope() == VariableScope.function);
				if (offset < 0) {
					continue;
				}
				buffer.append("var");
			}
			buffer.append(" ");
			buffer.append(var.name());
			buffer.append(" (");
			buffer.append(var.type());
			buffer.append("): ");
			if (offset < 0) {
				buffer.append("r");
				buffer.append(-1 - offset);
			}
			else {
				buffer.append("SP+");
				buffer.append(offset);
			}
			writeComment(buffer.toString());
		}
	}

	private void writeFunctionProlog(int firstNonVolatileRegister, int count) throws IOException {
/*
		if (rspOffset > 0) {
			writeIndented("sub rsp, " + rspOffset);
		}
*/
		if (count > 0) {
			writeComment("save clobbered non-volatile registers");
			for (int reg = firstNonVolatileRegister; count-- > 0; reg++) {
				writeIndented("push " + regName(reg));
			}
		}
/*
		if (callArgSpace > 0) {
			writeIndented("sub rsp, " + callArgSpace);
		}
*/
	}

	private void writeFunctionEpilog(int firstNonvolatileRegistersToPop, int count) throws IOException {
/*
		if (callArgSpace > 0) {
			writeIndented("add rsp, " + callArgSpace);
		}
*/
		if (count > 0) {
			writeComment("restore clobbered non-volatile registers");
			for (int reg = firstNonvolatileRegistersToPop + count - 1; count-- > 0; reg--) {
				writeIndented("pop  " + regName(reg));
			}
		}
/*
		if (rspOffset > 0) {
			writeIndented("add rsp, " + rspOffset);
		}
*/
		writeIndented("ret");
	}

	private void getRegisterName(int reg, StringBuilder buffer) {
		buffer.append("r");
		buffer.append(reg);
	}

	private String regName(int reg) {
		return "r" + reg;
	}

	private int getByteCount(Type type) {
		return Type.getSize(type, Type.I16);
	}

	private boolean isRegisterOverlap(int reg1, int reg2, int byteCount) {
		if (reg2 < reg1) {
			final int tmp = reg1;
			reg1 = reg2;
			reg2 = tmp;
		}

		return reg1 + byteCount > reg2;
	}

	private void notSupportedYet(String text) throws IOException {
		writeIndented("Not supported yet: " + text);
	}

	private static String encode(byte[] bytes) {
		final StringBuilder buffer = new StringBuilder();
		boolean stringIsOpen = false;
		for (byte b : bytes) {
			if (b >= 0x20 && b < 0x7f && b != '\"') {
				if (!stringIsOpen) {
					if (buffer.length() > 0) {
						buffer.append(" ");
					}
					buffer.append('"');
					stringIsOpen = true;
				}
				buffer.append((char)b);
			}
			else {
				if (stringIsOpen) {
					buffer.append('"');
					stringIsOpen = false;
				}
				if (buffer.length() > 0) {
					buffer.append(" ");
				}
				buffer.append("%");
				Utils.toHex(b, 2, buffer);
			}
		}
		if (stringIsOpen) {
			buffer.append('"');
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
