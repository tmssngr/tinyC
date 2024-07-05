package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;

import java.io.*;
import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public class X86Win64 {

	private static final String INDENTATION = "        ";
	private static final String EMIT = "__emit";
	private static final String PRINT_STRING = "__printString";
	private static final String PRINT_UINT = "__printUint";

	private final Writer writer;

	private int labelIndex;
	private int freeRegs;

	public X86Win64(Writer writer) {
		this.writer = writer;
	}

	public void write(Program program) throws IOException {
		final Variables variables = Variables.detectFrom(program);

		writePreample(program.globalVars(), variables);

		for (Function function : program.functions()) {
			write(function, variables);
		}

		writePostample(variables);
	}

	private void writePreample(List<StmtDeclaration> declarations, Variables variables) throws IOException {
		write("""
				      format pe64 console
				      include 'win64ax.inc'

				      STD_IN_HANDLE = -10
				      STD_OUT_HANDLE = -11
				      STD_ERR_HANDLE = -12

				      entry start

				      section '.text' code readable executable

				      start:""");
		writeIndented("sub rsp, 8");
		writeIndented("  call init");

		for (StmtDeclaration declaration : declarations) {
			writeAssignment(declaration.varName(), declaration.expression(), variables);
		}

		writeIndented("add rsp, 8");
		writeIndented("  call main");
		writeIndented("mov rcx, 0");
		writeIndented("sub rsp, 0x20");
		writeIndented("  call [ExitProcess]");
		writeNL();
	}

	private void write(Function function, Variables variables) throws IOException {
		writeComment(function.toString());
		writeLabel(function.name());
		writeStatement(function.statement(), variables);
		writeIndented("ret");
	}

	private void writePostample(Variables variables) throws IOException {
		writeInit();
		writeEmit();
		writeStringPrint();
		writeUintPrint();
		writeNL();

		write("section '.data' data readable writeable");
		writeIndented("""
				              hStdIn  rb 8
				              hStdOut rb 8
				              hStdErr rb 8""");
		for (String varName : variables.getVarNames()) {
			final Pair<Type, Integer> pair = variables.get(varName);
			final int size = getTypeSize(pair.left());
			final String asmName = getVarName(pair.right());
			writeIndented(asmName + " rb " + size);
		}
		writeNL();
		write("""
				      section '.idata' import data readable writeable

				      library kernel32,'KERNEL32.DLL',\\
				              msvcrt,'MSVCRT.DLL'

				      import kernel32,\\
				             ExitProcess,'ExitProcess',\\
				             GetStdHandle,'GetStdHandle',\\
				             SetConsoleCursorPosition,'SetConsoleCursorPosition',\\
				             WriteFile,'WriteFile'

				      import msvcrt,\\
				             _getch,'_getch'
				      """);
	}

	private void writeStatements(List<Statement> statements, Variables variables) throws IOException {
		for (Statement statement : statements) {
			writeStatement(statement, variables);
		}
	}

	private void writeStatement(Statement statement, Variables variables) throws IOException {
		switch (statement) {
		case StmtDeclaration declaration -> writeAssignment(declaration.varName(), declaration.expression(), variables);
		case StmtAssign assign -> writeAssignment(assign.varName(), assign.expression(), variables);
		case StmtCompound compound -> writeStatements(compound.statements(), variables);
		case StmtIf ifStatement -> writeIfElse(ifStatement, variables);
		case StmtWhile whileStatement -> writeWhile(whileStatement, variables);
		case StmtFor forStatement -> writeFor(forStatement, variables);
		case StmtExpr stmt -> write(stmt.expression(), variables);
		case StmtReturn ret -> writeReturn(ret.expression(), variables);
		case null, default -> throw new UnsupportedOperationException(String.valueOf(statement));
		}
	}

	private int writeCall(ExprFuncCall call, Variables variables) throws IOException {
		final List<Expression> expressions = call.argExpressions();
		if (expressions.size() > 1) {
			throw new IllegalStateException("Unsupported arguments " + expressions);
		}
		if (expressions.size() == 1) {
			final int reg = write(expressions.getFirst(), variables);
			final String regName = getRegName(reg);
			freeReg(reg);
			if (!regName.equals("rcx")) {
				writeIndented("mov rcx, " + regName);
			}
		}
		final String name = call.name();
		writeComment("call " + name);
		writeIndented("sub rsp, 8");
		if (name.equals("print")) {
			writeIndented("  call " + PRINT_UINT);
			writeIndented("mov rcx, 0x0a");
			writeIndented("  call " + EMIT);
		}
		else {
			writeIndented("  call " + name);
		}
		writeIndented("add rsp, 8");
		return call.typeNotNull() == Type.VOID ? -1 : 1; // rax
	}

	private void writeReturn(@Nullable Expression expression, Variables variables) throws IOException {
		if (expression != null) {
			writeComment("return " + expression);
			final int reg = write(expression, variables);
			final String regName = getRegName(reg);
			freeReg(reg);
			if (!regName.equals("rax")) {
				writeIndented("mov rax, " + regName);
			}
		}
		else {
			writeComment("return");
		}
	}

	private void writeAssignment(String varName, Expression expression, Variables variables) throws IOException {
		final int expressionReg = write(expression, variables);
		final int varReg = getFreeReg();
		final Pair<Type, Integer> typeIndex = variables.get(varName);
		final int typeSize = getTypeSize(typeIndex.left());
		final String addrReg = getRegName(varReg);
		writeComment("assign " + varName);
		writeIndented("lea " + addrReg + ", [" + getVarName(typeIndex.right()) + "]");
		writeIndented("mov [" + addrReg + "], " + getRegName(expressionReg, typeSize));
		freeReg(expressionReg);
		freeReg(varReg);
	}

	private int write(Expression node, Variables variables) throws IOException {
		switch (node) {
		case ExprIntLiteral literal -> {
			final int value = literal.value();
			writeComment("int lit " + value);
			final int reg = getFreeReg();
			writeIndented("mov " + getRegName(reg) + ", " + value);
			return reg;
		}
		case ExprVarRead read -> {
			final int reg = getFreeReg();
			final Pair<Type, Integer> typeIndex = variables.get(read.varName());
			final int typeSize = getTypeSize(typeIndex.left());
			final String varName = getVarName(typeIndex.right());
			final String addrReg = getRegName(reg);
			final String valueReg = getRegName(reg, typeSize);
			writeComment("read var " + read.varName());
			writeIndented("lea " + addrReg + ", [" + varName + "]");
			writeIndented("mov " + valueReg + ", [" + addrReg + "]");
			if (typeSize != 8) {
				writeIndented("movzx " + getRegName(reg) + ", " + valueReg);
			}
			return reg;
		}
		case ExprBinary binary -> {
			return writeBinary(binary, variables);
		}
		case ExprCast extend -> {
			final int reg = write(extend.expression(), variables);
			final int exprSize = getTypeSize(extend.expressionType());
			final int size = getTypeSize(extend.type());
			if (size != exprSize) {
				writeIndented("movzx " + getRegName(reg, size) + ", " + getRegName(reg, exprSize));
			}
			return reg;
		}
		case ExprFuncCall call -> {
			return writeCall(call, variables);
		}
		case ExprAddrOf addrOf -> {
			final String name = addrOf.varName();
			final int reg = getFreeReg();
			final Pair<Type, Integer> typeIndex = variables.get(name);
			final String varName = getVarName(typeIndex.right());
			final String addrReg = getRegName(reg);
			writeComment("address of var " + name);
			writeIndented("lea " + addrReg + ", [" + varName + "]");
			return reg;
		}
		case ExprDeref deref -> {
			final String name = deref.varName();
			final int reg = getFreeReg();
			final Pair<Type, Integer> typeIndex = variables.get(name);
			final int typeSize = getTypeSize(Objects.requireNonNull(typeIndex.left().toType()));
			final String varName = getVarName(typeIndex.right());
			final String addrReg = getRegName(reg);
			final String valueReg = getRegName(reg, typeSize);
			writeComment("deref " + name);
			writeIndented("lea " + addrReg + ", [" + varName + "]");
			writeIndented("mov " + addrReg + ", [" + addrReg + "]");
			writeIndented("mov " + valueReg + ", [" + addrReg + "]");
			if (typeSize != 8) {
				writeIndented("movzx " + getRegName(reg) + ", " + valueReg);
			}
			return reg;
		}
		default -> throw new UnsupportedOperationException("unsupported expression " + node);
		}
	}

	private int writeBinary(ExprBinary node, Variables variables) throws IOException {
		switch (node.op()) {
		case Add -> {
			final int leftReg = write(node.left(), variables);
			final int rightReg = write(node.right(), variables);
			final int size = getTypeSize(node.typeNotNull());
			writeComment("add");
			writeIndented("add " + getRegName(leftReg, size) + ", " + getRegName(rightReg, size));
			freeReg(rightReg);
			return leftReg;
		}
		case Sub -> {
			final int leftReg = write(node.left(), variables);
			final int rightReg = write(node.right(), variables);
			final int size = getTypeSize(node.typeNotNull());
			writeComment("sub");
			writeIndented("sub " + getRegName(leftReg, size) + ", " + getRegName(rightReg, size));
			freeReg(rightReg);
			return leftReg;
		}
		case Multiply -> {
			final int leftReg = write(node.left(), variables);
			final int rightReg = write(node.right(), variables);
			writeComment("multiply");
			writeIndented("imul " + getRegName(leftReg) + ", " + getRegName(rightReg));
			freeReg(rightReg);
			return leftReg;
		}
		case Divide -> {
			throw new UnsupportedOperationException();
		}
		default -> {
			final int leftReg = write(node.left(), variables);
			final int rightReg = write(node.right(), variables);
			writeComment(node.op().toString());
			final String leftRegName = getRegName(leftReg);
			writeIndented("cmp " + leftRegName + ", " + getRegName(rightReg));
			writeIndented(switch (node.op()) {
				case Lt -> "setl";
				case LtEq -> "setle";
				case Equals -> "sete";
				case NotEquals -> "setne";
				case GtEq -> "setge";
				case Gt -> "setg";
				default -> throw new IllegalStateException();
			} + " " + getRegName(leftReg, 1));
			writeIndented("and " + leftRegName + ", 0xFF");
			freeReg(rightReg);
			return leftReg;
		}
		}
	}

	private void writeIfElse(StmtIf statement, Variables variables) throws IOException {
		final Expression condition = statement.condition();
		final Statement thenStatement = statement.thenStatement();
		final Statement elseStatement = statement.elseStatement();
		final int labelIndex = nextLabelIndex();
		final String elseLabel = "else_" + labelIndex;
		final String nextLabel = "endif_" + labelIndex;
		writeComment("if " + condition);
		final int conditionReg = write(condition, variables);
		final String conditionRegName = getRegName(conditionReg);
		writeComment("if-condition");
		writeIndented("or " + conditionRegName + ", " + conditionRegName);
		writeIndented("jz " + (elseStatement != null ? elseLabel : nextLabel));
		writeStatement(thenStatement, variables);
		if (elseStatement != null) {
			writeIndented("jmp " + nextLabel);
		}
		if (elseStatement != null) {
			writeLabel(elseLabel);
			writeStatement(elseStatement, variables);
		}
		writeLabel(nextLabel);
	}

	private void writeWhile(StmtWhile statement, Variables variables) throws IOException {
		final int labelIndex = nextLabelIndex();
		final String whileLabel = "while_" + labelIndex;
		final String nextLabel = "endwhile_" + labelIndex;
		final Expression condition = statement.condition();
		writeComment("while " + condition);
		writeLabel(whileLabel);
		final int conditionReg = write(condition, variables);
		final String conditionRegName = getRegName(conditionReg);
		writeComment("while-condition");
		writeIndented("or " + conditionRegName + ", " + conditionRegName);
		writeIndented("jz " + nextLabel);
		final Statement body = statement.bodyStatement();
		writeStatement(body, variables);
		writeIndented("jmp " + whileLabel);
		writeLabel(nextLabel);
	}

	private void writeFor(StmtFor statement, Variables variables) throws IOException {
		final int labelIndex = nextLabelIndex();
		final String forLabel = "for_" + labelIndex;
		final String nextLabel = "endFor_" + labelIndex;

		writeComment("for");
		writeStatements(statement.initialization(), variables);

		final Expression condition = statement.condition();
		writeComment("for condition " + condition);
		writeLabel(forLabel);
		final int conditionReg = write(condition, variables);
		final String conditionRegName = getRegName(conditionReg);
		writeIndented("or " + conditionRegName + ", " + conditionRegName);
		writeIndented("jz " + nextLabel);
		final Statement body = statement.bodyStatement();
		writeStatement(body, variables);

		writeComment("for iteration");
		writeStatements(statement.iteration(), variables);
		writeIndented("jmp " + forLabel);

		writeLabel(nextLabel);
	}

	private int getFreeReg() {
		int mask = 1;
		for (int i = 0; i < 3; i++, mask += mask) {
			if ((freeRegs & mask) == 0) {
				freeRegs |= mask;
				return i;
			}
		}
		throw new IllegalStateException("no free reg");
	}

	private void freeReg(int reg) {
		freeRegs &= ~(1 << reg);
	}

	private String getVarName(int i) {
		return "var" + i;
	}

	private void writeInit() throws IOException {
		writeLabel("init");
		writeIndented("""
				              sub rsp, 20h
				                mov rcx, STD_IN_HANDLE
				                call [GetStdHandle]
				                ; handle in rax, 0 if invalid
				                lea rcx, [hStdIn]
				                mov qword [rcx], rax

				                mov rcx, STD_OUT_HANDLE
				                call [GetStdHandle]
				                ; handle in rax, 0 if invalid
				                lea rcx, [hStdOut]
				                mov qword [rcx], rax

				                mov rcx, STD_ERR_HANDLE
				                call [GetStdHandle]
				                ; handle in rax, 0 if invalid
				                lea rcx, [hStdErr]
				                mov qword [rcx], rax
				              add rsp, 20h
				              ret""");
	}

	private void writeEmit() throws IOException {
		// rcx = char
		writeLabel(EMIT);
		// push char to stack
		// use that address as buffer to print
		// use length 1
		writeIndented("push rcx ; = sub rsp, 8");
		writeIndented("  mov rcx, rsp");
		writeIndented("  mov rdx, 1");
		writeIndented("  call " + PRINT_STRING);
		writeIndented("pop rcx");
		writeIndented("ret");
	}

	private void writeStringPrint() throws IOException {
		// rcx = pointer to text
		// rdx = length
		// BOOL WriteFile(
		//  [in]                HANDLE       hFile,                    rcx
		//  [in]                LPCVOID      lpBuffer,                 rdx
		//  [in]                DWORD        nNumberOfBytesToWrite,    r8
		//  [out, optional]     LPDWORD      lpNumberOfBytesWritten,   r9
		//  [in, out, optional] LPOVERLAPPED lpOverlapped              stack
		//);
		writeLabel(PRINT_STRING);
		writeIndented("""
				              mov     rdi, rsp
				              and     spl, 0xf0

				              mov     r8, rdx
				              mov     rdx, rcx
				              lea     rcx, [hStdOut]
				              mov     rcx, qword [rcx]
				              xor     r9, r9
				              push    0
				                sub     rsp, 20h
				                  call    [WriteFile]
				                add     rsp, 20h
				              ; add     rsp, 8
				              mov     rsp, rdi
				              ret
				              """);
	}

	private void writeUintPrint() throws IOException {
		// input: rcx
		// rsp+0   = buf (20h long)
		// rsp+20h = pos
		// rsp+24h = x
		writeLabel(PRINT_UINT);
		writeIndented("""
				              push   rbp
				              mov    rbp,rsp
				              sub    rsp, 50h
				              mov    qword [rsp+24h], rcx

				              ; int pos = sizeof(buf);
				              mov    ax, 20h
				              mov    word [rsp+20h], ax

				              ; do {
				              """);
		writeLabel(".print");
		writeIndented("""
				              ; pos--;
				              mov    ax, word [rsp+20h]
				              dec    ax
				              mov    word [rsp+20h], ax

				              ; int remainder = x mod 10;
				              ; x = x / 10;
				              mov    rax, qword [rsp+24h]
				              mov    ecx, 10
				              xor    edx, edx
				              div    ecx
				              mov    qword [rsp+24h], rax

				              ; int digit = remainder + '0';
				              add    dl, '0'

				              ; buf[pos] = digit;
				              mov    ax, word [rsp+20h]
				              movzx  rax, ax
				              lea    rcx, qword [rsp]
				              add    rcx, rax
				              mov    byte [rcx], dl

				              ; } while (x > 0);
				              mov    rax, qword [rsp+24h]
				              cmp    rax, 0
				              ja     .print

				              ; rcx = &buf[pos]

				              ; rdx = sizeof(buf) - pos
				              mov    ax, word [rsp+20h]
				              movzx  rax, ax
				              mov    rdx, 20h
				              sub    rdx, rax

				              ;sub    rsp, 8  not necessary because initial push rbp""");
		writeIndented("  call   " + PRINT_STRING);
		writeIndented("""
				              ;add    rsp, 8
				              leave ; Set SP to BP, then pop BP
				              ret
				              """);
	}

	private void writeLabel(String label) throws IOException {
		writer.write(label + ":");
		writeNL();
	}

	private void writeComment(String s) throws IOException {
		writeIndented("; " + s);
	}

	private void writeIndented(String text) throws IOException {
		writeLines(text, INDENTATION);
	}

	private void write(String text) throws IOException {
		writeLines(text, null);
	}

	private void writeLines(String text, @Nullable String leading) throws IOException {
		final String[] lines = text.split("\\r?\\n");
		for (String line : lines) {
			if (leading != null && line.length() > 0) {
				writer.write(leading);
			}
			writer.write(line);
			writeNL();
		}
	}

	private void writeNL() throws IOException {
		writer.write(System.lineSeparator());
	}

	private int nextLabelIndex() {
		labelIndex++;
		return labelIndex;
	}

	private static String getRegName(int reg) {
		return getRegName(reg, 0);
	}

	private static String getRegName(int reg, int size) {
		final char chr = switch (reg) {
			case 0 -> 'c';
			case 1 -> 'a';
			case 2 -> 'b';
			default -> throw new IllegalStateException();
		};
		return switch (size) {
			case 1 -> chr + "l";
			case 2 -> chr + "x";
			case 4 -> "e" + chr + "x";
			default -> "r" + chr + "x";
		};
	}

	private static int getTypeSize(Type type) {
		if (type.isPointer()) {
			return 8;
		}
		return Type.getSize(type);
	}
}
