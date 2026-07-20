package com.regnis.tinyc;

import com.regnis.tinyc.ir.*;

import java.io.*;
import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class Z8AsmWriter extends AsmWriter {

	public Z8AsmWriter(@NotNull BufferedWriter writer) {
		super(writer);
	}

	@Override
	public void write(@NotNull IRProgram program) throws IOException {
		writeLines("""
				                   .org %e000

				           start:  jp main
				           """);
		super.write(program);
	}

	@Override
	protected void writeFunction(IRFunction function) throws IOException {
		writeComment(function.toString());

		final List<IRInstruction> instructions = function.instructions();
/*
		final int nonvolatileRegistersToPushPop = getNonVolatileRegistersToPushPop(instructions);
		final List<IRVarDef> localVars = function.varInfos().vars();
		final List<List<IRVar>> callsArgs = getCallsWithStackArgs(instructions);
		stackOffsets = createX86StackOffsets(localVars, callsArgs, nonvolatileRegistersToPushPop);
		final int rspOffset = stackOffsets.getRspOffset();
		final int callArgSpace = stackOffsets.getCallArgSpace();
		writeVarOffsetAsComments(localVars);
*/
		writeLabel(function.label());
//		writeFunctionProlog(rspOffset, nonvolatileRegistersToPushPop, callArgSpace);
		writeFunctionProlog();

		writeInstructions(instructions);

//		writeFunctionEpilog(rspOffset, nonvolatileRegistersToPushPop, callArgSpace);
		writeFunctionEpilog();
//		stackOffsets = null;
	}

	@Override
	protected void writeAddrOf(IRAddrOf addrOf) throws IOException {

	}

	@Override
	protected void writeAddrOfArray(IRAddrOfArray addrOf) throws IOException {

	}

	@Override
	protected void writeBinary(IRBinary binary) throws IOException {

	}

	@Override
	protected void writeBranch(IRBranch branch) throws IOException {

	}

	@Override
	protected void writeCall(IRCall call) throws IOException {

	}

	@Override
	protected void writeCast(IRCast cast) throws IOException {

	}

	@Override
	protected void writeCompare(IRCompare compare) throws IOException {

	}

	@Override
	protected void writeJump(IRJump jump) throws IOException {

	}

	@Override
	protected void writeLiteral(IRLiteral literal) throws IOException {

	}

	@Override
	protected void writeMemLoad(IRMemLoad load) throws IOException {

	}

	@Override
	protected void writeMemStore(IRMemStore store) throws IOException {

	}

	@Override
	protected void writeMove(IRMove copy) throws IOException {

	}

	@Override
	protected void writeRetValue(IRRetValue retValue) throws IOException {

	}

	@Override
	protected void writeString(IRString literal) throws IOException {

	}

	@Override
	protected void writeUnary(IRUnary unary) throws IOException {

	}

	private void writeFunctionProlog() {
/*
		if (rspOffset > 0) {
			writeIndented("sub rsp, " + rspOffset);
		}

		if (pushedNonvolatileRegisterCount > 0) {
			writeComment("save clobbered non-volatile registers");
			for (int i = 0; i < pushedNonvolatileRegisterCount; i++) {
				writeIndented("push " + registers.getRegName(FIRST_NON_VOLATILE_REGISTER + i));
			}
		}

		if (callArgSpace > 0) {
			writeIndented("sub rsp, " + callArgSpace);
		}
*/
	}

	private void writeFunctionEpilog() throws IOException {
/*
		if (callArgSpace > 0) {
			writeIndented("add rsp, " + callArgSpace);
		}

		if (pushedNonvolatileRegisterCount > 0) {
			writeComment("restore clobbered non-volatile registers");
			for (int i = pushedNonvolatileRegisterCount; i-- > 0; ) {
				writeIndented("pop " + registers.getRegName(FIRST_NON_VOLATILE_REGISTER + i));
			}
		}

		if (rspOffset > 0) {
			writeIndented("add rsp, " + rspOffset);
		}
*/
		writeIndented("ret");
	}
}
