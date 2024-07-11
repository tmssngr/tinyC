package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;

import java.io.*;
import java.nio.charset.*;
import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public class X86Win64 {

	private static final String INDENTATION = "        ";
	private static final String EMIT = "__emit";
	private static final String PRINT_STRING = "__printString";
	private static final String PRINT_STRING_ZERO = "__printStringZero";
	private static final String PRINT_UINT = "__printUint";
	private static final String STRING_PREFIX = "string_";

	private final Writer writer;

	private int labelIndex;
	private int freeRegs;
	@SuppressWarnings("unused") private boolean debug;

	public X86Win64(Writer writer) {
		this.writer = writer;
	}

	public void write(Program program) throws IOException {
		final Variables variables = Variables.detectFrom(program);

		writePreample();

		for (Function function : program.functions()) {
			write(function, variables);
		}

		writeInit(program.globalVars(), variables);
		writePostamble(variables);
	}

	private void writePreample() throws IOException {
		writeLines("""
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

	private void writeInit(List<StmtDeclaration> declarations, Variables variables) throws IOException {
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
				              """);

		for (StmtDeclaration declaration : declarations) {
			if (declaration instanceof StmtVarDeclaration varDeclaration) {
				writeAssignment(varDeclaration.varName(), varDeclaration.expression(), varDeclaration.location(), variables);
			}
		}

		writeIndented("ret");
	}

	private void writePostamble(Variables variables) throws IOException {
		writeEmit();
		writeStringPrint();
		writeUintPrint();
		writeNL();

		writeLines("section '.data' data readable writeable");
		writeIndented("""
				              hStdIn  rb 8
				              hStdOut rb 8
				              hStdErr rb 8""");
		for (String varName : variables.getVarNames()) {
			final Variables.Variable variable = variables.get(varName);
			final int size = getTypeSize(variable.type()) * variable.count();
			final String asmName = getVarName(variable.index());
			writeIndented(asmName + " rb " + size);
		}
		writeNL();

		final List<String> stringLiterals = variables.getStringLiterals();
		if (stringLiterals.size() > 0) {
			writeLines("section '.data' data readable");
			int i = 0;
			for (String literal : stringLiterals) {
				final String encoded = encode((literal + '\0').getBytes(StandardCharsets.UTF_8));
				writeIndented(STRING_PREFIX + i + " db " + encoded);
				i++;
			}
			writeNL();
		}

		writeLines("""
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
		case StmtVarDeclaration declaration -> writeAssignment(declaration.varName(), declaration.expression(), declaration.location(), variables);
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
		final String name = call.name();
		if (name.equals("printString")) {
			if (expressions.size() != 1) {
				throw new IllegalStateException("Unsupported arguments " + expressions);
			}
			final Expression expression = expressions.getFirst();
			final int reg = write(expression, variables);
			final String regName = getRegName(reg);
			freeReg(reg);
			final Type type = expression.typeNotNull();
			if (type.toType() != Type.U8) {
				throw new IllegalStateException("Unsupported type");
			}
			writeComment("print " + type, call.location());
			writeIndented("sub rsp, 8");
			final int size = getTypeSize(type);
			if (!regName.equals("rcx")) {
				writeIndented("  mov rcx, " + regName);
			}
			writeIndented("  call " + PRINT_STRING_ZERO);
			writeIndented("add rsp, 8");
		}
		else if (name.equals("print")) {
			if (expressions.size() != 1) {
				throw new IllegalStateException("Unsupported arguments " + expressions);
			}
			final Expression expression = expressions.getFirst();
			final int reg = write(expression, variables);
			final String regName = getRegName(reg);
			freeReg(reg);
			final Type type = expression.typeNotNull();
			writeComment("print " + type, call.location());
			writeIndented("sub rsp, 8");
			final int size = getTypeSize(type);
			if (size != 8) {
				writeIndented("  movzx rcx, " + getRegName(reg, size));
			}
			else if (!regName.equals("rcx")) {
				writeIndented("  mov rcx, " + regName);
			}
			writeIndented("  call " + PRINT_UINT);
			writeIndented("  mov rcx, 0x0a");
			writeIndented("  call " + EMIT);
			writeIndented("add rsp, 8");
		}
		else {
			if (expressions.size() > 1) {
				throw new IllegalStateException("Unsupported arguments " + expressions);
			}
			if (expressions.size() == 1) {
				final Expression first = expressions.getFirst();
				final int reg = write(first, variables);
				final String regName = getRegName(reg);
				freeReg(reg);
				final int size = getTypeSize(first.typeNotNull());
				if (size != 8) {
					writeIndented("movzx rcx, " + getRegName(reg, size));
				}
				else if (!regName.equals("rcx")) {
					writeIndented("mov rcx, " + regName);
				}
			}
			writeComment("call " + name, call.location());
			writeIndented("sub rsp, 8");
			writeIndented("  call " + name);
			writeIndented("add rsp, 8");
		}
		return call.typeNotNull() == Type.VOID ? -1 : 1; // rax
	}

	private void writeReturn(@Nullable Expression expression, Variables variables) throws IOException {
		if (expression != null) {
			writeComment("return " + expression, expression.location());
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

	private void writeAssignment(String varName, Expression expression, Location location, Variables variables) throws IOException {
		final int expressionReg = write(expression, variables);
		final int varReg = getFreeReg();
		final Variables.Variable variable = variables.get(varName);
		final int typeSize = getTypeSize(variable.type());
		final String addrReg = getRegName(varReg);
		writeComment("assign " + varName, location);
		writeIndented("lea " + addrReg + ", [" + getVarName(variable.index()) + "]");
		writeIndented("mov [" + addrReg + "], " + getRegName(expressionReg, typeSize));
		freeReg(expressionReg);
		freeReg(varReg);
	}

	private int write(Expression node, Variables variables) throws IOException {
		switch (node) {
		case ExprIntLiteral literal -> {
			final int value = literal.value();
			final int size = getTypeSize(literal.typeNotNull());
			writeComment("int lit " + value, node.location());
			final int reg = getFreeReg();
			writeIndented("mov " + getRegName(reg, size) + ", " + value);
			return reg;
		}
		case ExprStringLiteral literal -> {
			final int i = variables.getStringIndex(literal);
			final String stringLiteralName = STRING_PREFIX + i;
			writeComment("string literal " + stringLiteralName, node.location());
			final int reg = getFreeReg();
			writeIndented("lea " + getRegName(reg) + ", [" + stringLiteralName + "]");
			return reg;
		}
		case ExprVarAccess var -> {
			final String name = var.varName();
			final Expression arrayIndex = var.arrayIndex();
			final int addrReg;
			if (arrayIndex != null) {
				addrReg = writeArrayAccess(name, arrayIndex, var.typeNotNull(), node.location(), variables);
			}
			else {
				writeComment("read var " + name, node.location());
				addrReg = writeAddressOf(name, variables);
			}
			final int valueReg = writeRead(addrReg, var.typeNotNull());
			freeReg(addrReg);
			return valueReg;
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
			writeComment("address of var " + name, node.location());
			return writeAddressOf(name, variables);
		}
		case ExprDeref deref -> {
			final int addrReg = write(deref.expression(), variables);
			final int typeSize = getTypeSize(Objects.requireNonNull(deref.type()));
			writeComment("deref", node.location());
			final int valueReg = getFreeReg();
			final String addrRegName = getRegName(addrReg, 8);
			final String valueRegName = getRegName(valueReg, typeSize);
			writeIndented("mov " + valueRegName + ", [" + addrRegName + "]");
			freeReg(addrReg);
			return valueReg;
		}
		default -> throw new UnsupportedOperationException("unsupported expression " + node);
		}
	}

	private int writeAddressOf(String name, Variables variables) throws IOException {
		final int reg = getFreeReg();
		final Variables.Variable variable = variables.get(name);
		final String varName = getVarName(variable.index());
		final String addrReg = getRegName(reg);
		writeIndented("lea " + addrReg + ", [" + varName + "]");
		return reg;
	}

	private int writeRead(int addrReg, Type type) throws IOException {
		final int valueReg = getFreeReg();
		final String addrRegName = getRegName(addrReg);
		final int typeSize = getTypeSize(type);
		final String valueRegName = getRegName(valueReg, typeSize);
		writeIndented("mov " + valueRegName + ", [" + addrRegName + "]");
		freeReg(addrReg);
		return valueReg;
	}

	private int writeBinary(ExprBinary node, Variables variables) throws IOException {
		switch (node.op()) {
		case Assign -> {
			final int expressionReg = write(node.right(), variables);
			final int lValueReg = writeLValue(node.left(), variables);
			final String addrReg = getRegName(lValueReg);
			final int typeSize = getTypeSize(node.typeNotNull());
			writeComment("assign", node.location());
			writeIndented("mov [" + addrReg + "], " + getRegName(expressionReg, typeSize));
			freeReg(expressionReg);
			freeReg(lValueReg);
			return -1;
		}
		case Add -> {
			final int leftReg = write(node.left(), variables);
			final int rightReg = write(node.right(), variables);
			final int size = getTypeSize(node.typeNotNull());
			writeComment("add", node.location());
			writeIndented("add " + getRegName(leftReg, size) + ", " + getRegName(rightReg, size));
			freeReg(rightReg);
			return leftReg;
		}
		case Sub -> {
			final int leftReg = write(node.left(), variables);
			final int rightReg = write(node.right(), variables);
			final int size = getTypeSize(node.typeNotNull());
			writeComment("sub", node.location());
			writeIndented("sub " + getRegName(leftReg, size) + ", " + getRegName(rightReg, size));
			freeReg(rightReg);
			return leftReg;
		}
		case Multiply -> {
			final int leftReg = write(node.left(), variables);
			final int rightReg = write(node.right(), variables);
			final int size = getTypeSize(node.typeNotNull());
			writeComment("multiply", node.location());
			if (size != 8) {
				writeIndented("movsx " + getRegName(leftReg) + ", " + getRegName(leftReg, size));
				writeIndented("movsx " + getRegName(rightReg) + ", " + getRegName(rightReg, size));
			}
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
			final int size = getTypeSize(node.typeNotNull());
			writeComment(node.op().toString(), node.location());
			final String leftRegName = getRegName(leftReg, size);
			writeIndented("cmp " + leftRegName + ", " + getRegName(rightReg, size));
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

	/**
	 * @return register of the target address
	 */
	private int writeLValue(Expression lValue, Variables variables) throws IOException {
		return switch (lValue) {
			case ExprVarAccess var -> {
				final String varName = var.varName();
				final Expression arrayIndex = var.arrayIndex();
				if (arrayIndex != null) {
					yield writeArrayAccess(varName, arrayIndex, var.typeNotNull(), var.location(), variables);
				}
				else {
					final int varReg = getFreeReg();
					final Variables.Variable variable = variables.get(varName);
					final String addrReg = getRegName(varReg);
					writeComment("var " + varName, var.location());
					writeIndented("lea " + addrReg + ", [" + getVarName(variable.index()) + "]");
					yield varReg;
				}
			}
			case ExprDeref deref -> write(deref.expression(), variables);
			default -> throw new IllegalStateException(String.valueOf(lValue));
		};
	}

	private int writeArrayAccess(@NotNull String varName, @NotNull Expression index, @NotNull Type type, @NotNull Location location, @NotNull Variables variables) throws IOException {
		final Variables.Variable variable = variables.get(varName);
		writeComment("array " + varName, location);
		final int reg1 = write(index, variables);
		final String reg1Name = getRegName(reg1);
		final int reg2 = getFreeReg();
		final String reg2Name = getRegName(reg2);
		writeIndented("imul " + reg1Name + ", " + getTypeSize(type));
		writeIndented("lea " + reg2Name + ", [" + getVarName(variable.index()) + "]");
		writeIndented("add " + reg2Name + ", " + reg1Name);
		freeReg(reg1);
		return reg2;
	}

	private void writeIfElse(StmtIf statement, Variables variables) throws IOException {
		final Expression condition = statement.condition();
		final Statement thenStatement = statement.thenStatement();
		final Statement elseStatement = statement.elseStatement();
		final int labelIndex = nextLabelIndex();
		final String elseLabel = "else_" + labelIndex;
		final String nextLabel = "endif_" + labelIndex;
		writeComment("if " + condition, statement.location());
		final int conditionReg = write(condition, variables);
		final String conditionRegName = getRegName(conditionReg, getTypeSize(condition.typeNotNull()));
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
		writeComment("while " + condition, statement.location());
		writeLabel(whileLabel);
		final int conditionReg = write(condition, variables);
		final String conditionRegName = getRegName(conditionReg, getTypeSize(condition.typeNotNull()));
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

		writeComment("for", statement.location());
		writeStatements(statement.initialization(), variables);

		final Expression condition = statement.condition();
		writeComment("for condition " + condition);
		writeLabel(forLabel);
		final int conditionReg = write(condition, variables);
		final String conditionRegName = getRegName(conditionReg, getTypeSize(condition.typeNotNull()));
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
		writeLabel(PRINT_STRING_ZERO);
		writeIndented("mov rdx, rcx");
		writeLabel(PRINT_STRING_ZERO + "_1");
		writeIndented("mov r9l, [rdx]");
		writeIndented("or  r9l, r9l");
		writeIndented("jz " + PRINT_STRING_ZERO + "_2");
		writeIndented("add rdx, 1");
		writeIndented("jmp " + PRINT_STRING_ZERO + "_1");
		writeLabel(PRINT_STRING_ZERO + "_2");
		writeIndented("sub rdx, rcx");

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
		write(label + ":");
		writeNL();
	}

	private void writeComment(String s, Location location) throws IOException {
		writeComment(location + " " + s);
	}

	private void writeComment(String s) throws IOException {
		writeIndented("; " + s);
	}

	private void writeIndented(String text) throws IOException {
		writeLines(text, INDENTATION);
	}

	private void writeLines(String text) throws IOException {
		writeLines(text, null);
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

	private void writeNL() throws IOException {
		write(System.lineSeparator());
	}

	private void write(String text) throws IOException {
		writer.write(text);
		if (debug) {
			System.out.print(text);
		}
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
}
