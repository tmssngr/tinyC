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
	private static final int TRUE = 1;
	private static final int FALSE = 0;

	private final Writer writer;

	private int labelIndex;
	private int freeRegs;
	@SuppressWarnings("unused") private boolean debug;
	private String functionRetLabel;

	public X86Win64(Writer writer) {
		this.writer = writer;
	}

	public void write(Program program) throws IOException {
		final Variables variables = new Variables(program.globalVariables());

		writePreample();

		for (Function function : program.functions()) {
			write(function, variables);
		}

		writeInit(program.globalVars(), variables);
		writePostamble(program.globalVariables(), program.stringLiterals(), variables);
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
		writeComment("alignment");
		writeIndented("and rsp, -16");

		writeIndented("sub rsp, 8");
		writeIndented("  call init");
		writeIndented("add rsp, 8");
		writeIndented("  call " + getFunctionLabel("main"));
		writeIndented("mov rcx, 0");
		writeIndented("sub rsp, 0x20");
		writeIndented("  call [ExitProcess]");
		writeNL();
	}

	private void write(Function function, Variables variables) throws IOException {
		final String functionLabel = getFunctionLabel(function.name());
		functionRetLabel = functionLabel + "_ret";
		writeComment(function.toString());
		writeLabel(functionLabel);

		writeStatement(function.statement(), variables);
		writeLabel(functionRetLabel);
		writeIndented("ret");
	}

	private String getFunctionLabel(String name) {
		return "@" + name;
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
				writeAssignment(varDeclaration.index(), varDeclaration.expression(), varDeclaration.location(), variables);
			}
		}

		writeIndented("ret");
	}

	private void writePostamble(List<Variable> globalVariables, List<StringLiteral> stringLiterals, Variables variables) throws IOException {
		writeEmit();
		writeStringPrint();
		writeUintPrint();
		writeNL();

		writeLines("section '.data' data readable writeable");
		writeIndented("""
				              hStdIn  rb 8
				              hStdOut rb 8
				              hStdErr rb 8""");
		for (Variable variable : globalVariables) {
			final int size = getVariableSize(variable);
			final VariableDetails details = variables.get(variable.index());
			writeComment("variable " + details);
			writeIndented(getGlobalVarName(details) + " rb " + size);
		}
		writeNL();

		if (stringLiterals.size() > 0) {
			writeLines("section '.data' data readable");
			for (StringLiteral literal : stringLiterals) {
				final String encoded = encode((literal.text() + '\0').getBytes(StandardCharsets.UTF_8));
				writeIndented(getStringLiteralName(literal.index()) + " db " + encoded);
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
		case StmtVarDeclaration declaration -> writeAssignment(declaration.index(), declaration.expression(), declaration.location(), variables);
		case StmtCompound compound -> writeStatements(compound.statements(), variables);
		case StmtIf ifStatement -> writeIfElse(ifStatement, variables);
		case StmtLoop forStatement -> writeFor(forStatement, variables);
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
			if (!regName.equals("rcx")) {
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
			writeIndented("  call " + getFunctionLabel(name));
			writeIndented("add rsp, 8");
		}
		return call.typeNotNull() == Type.VOID ? -1 : 1; // rax
	}

	private void writeReturn(@Nullable Expression expression, Variables variables) throws IOException {
		if (expression != null) {
			writeComment("return " + expression.toUserString(), expression.location());
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
		writeIndented("jmp " + Objects.requireNonNull(functionRetLabel));
	}

	private void writeAssignment(int index, Expression expression, Location location, Variables variables) throws IOException {
		final int expressionReg = write(expression, variables);
		final int varReg = getFreeReg();
		final VariableDetails variable = variables.get(index);
		Utils.assertTrue(variable.isScalar());
		final int typeSize = getTypeSize(variable.type());
		writeComment("assign " + variable, location);
		writeAddrOfVar(varReg, variable);
		writeIndented("mov [" + getRegName(varReg) + "], " + getRegName(expressionReg, typeSize));
		freeReg(expressionReg);
		freeReg(varReg);
	}

	private int write(Expression node, Variables variables) throws IOException {
		return switch (node) {
			case ExprIntLiteral literal -> {
				final int value = literal.value();
				final int size = getTypeSize(literal.typeNotNull());
				writeComment("int lit " + value, node.location());
				final int reg = getFreeReg();
				writeIndented("mov " + getRegName(reg, size) + ", " + value);
				yield reg;
			}
			case ExprBoolLiteral literal -> {
				final boolean value = literal.value();
				final int size = getTypeSize(literal.typeNotNull());
				writeComment("bool lit " + value, node.location());
				final int reg = getFreeReg();
				writeIndented("mov " + getRegName(reg, size) + ", " + (value ? TRUE : FALSE));
				yield reg;
			}
			case ExprStringLiteral literal -> {
				final int i = literal.index();
				final String stringLiteralName = getStringLiteralName(i);
				writeComment("string literal " + stringLiteralName, node.location());
				final int reg = getFreeReg();
				writeIndented("lea " + getRegName(reg) + ", [" + stringLiteralName + "]");
				yield reg;
			}
			case ExprVarAccess var -> {
				final VariableDetails variable = variables.get(var.index());
				final Expression arrayIndex = var.arrayIndex();
				final int addrReg;
				if (arrayIndex != null) {
					writeComment("array " + variable, node.location());
					addrReg = writeArrayAccess(variable, arrayIndex, var.typeNotNull(), variables);
				}
				else {
					writeComment("read var " + variable, node.location());
					addrReg = writeAddressOf(variable);
				}
				final int valueReg = writeRead(addrReg, var.typeNotNull());
				freeReg(addrReg);
				yield valueReg;
			}
			case ExprBinary binary -> writeBinary(binary, variables);
			case ExprUnary unary -> processUnary(unary, variables);
			case ExprFuncCall call -> writeCall(call, variables);
			case ExprCast cast -> {
				final Expression expression = cast.expression();
				final int reg = write(expression, variables);
				final int exprSize = getTypeSize(expression.typeNotNull());
				final int size = getTypeSize(cast.typeNotNull());
				if (size > exprSize) {
					final int targetReg = getFreeReg();
					writeIndented("movzx " + getRegName(targetReg, size) + ", " + getRegName(reg, exprSize));
					freeReg(reg);
					yield targetReg;
				}
				yield reg;
			}
			case ExprAddrOf addrOf -> {
				final VariableDetails variable = variables.get(addrOf.index());
				final Expression arrayIndex = addrOf.arrayIndex();
				if (arrayIndex != null) {
					writeComment("address of array " + variable + "[...]", node.location());
					yield writeArrayAccess(variable, arrayIndex, Objects.requireNonNull(addrOf.typeNotNull().toType()), variables);
				}

				writeComment("address of var " + variable, node.location());
				yield writeAddressOf(variable);
			}
			default -> throw new UnsupportedOperationException("unsupported expression " + node);
		};
	}

	private int writeAddressOf(VariableDetails variable) throws IOException {
		final int reg = getFreeReg();
		Utils.assertTrue(variable.isScalar());
		writeAddrOfVar(reg, variable);
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
			return writeSimpleArithmetic("add", node, variables);
		}
		case Sub -> {
			return writeSimpleArithmetic("sub", node, variables);
		}
		case And -> {
			return writeSimpleArithmetic("and", node, variables);
		}
		case Or -> {
			return writeSimpleArithmetic("or", node, variables);
		}
		case Xor -> {
			return writeSimpleArithmetic("xor", node, variables);
		}
		case AndLog -> {
			final int labelIndex = nextLabelIndex();
			final String nextLabel = "@next_" + labelIndex;
			writeComment("logic and", node.location());
			final int conditionReg = write(node.left(), variables);
			final String conditionRegName = getRegName(conditionReg, getTypeSize(node.typeNotNull()));
			writeIndented("or " + conditionRegName + ", " + conditionRegName);
			writeIndented("jz " + nextLabel);
			final int conditionReg2 = write(node.right(), variables);
			if (conditionReg2 != conditionReg) {
				writeIndented("mov " + conditionRegName + ", " + getRegName(conditionReg2, getTypeSize(node.typeNotNull())));
			}
			freeReg(conditionReg2);
			writeLabel(nextLabel);
			return conditionReg;
		}
		case OrLog -> {
			final int labelIndex = nextLabelIndex();
			final String nextLabel = "@next_" + labelIndex;
			writeComment("logic or", node.location());
			final int conditionReg = write(node.left(), variables);
			final String conditionRegName = getRegName(conditionReg, getTypeSize(node.typeNotNull()));
			writeIndented("or " + conditionRegName + ", " + conditionRegName);
			writeIndented("jnz " + nextLabel);
			final int conditionReg2 = write(node.right(), variables);
			if (conditionReg2 != conditionReg) {
				writeIndented("mov " + conditionRegName + ", " + getRegName(conditionReg2, getTypeSize(node.typeNotNull())));
			}
			freeReg(conditionReg2);
			writeLabel(nextLabel);
			return conditionReg;
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
			final int resultReg = getFreeReg();
			final String resultRegName = getRegName(resultReg, 1);
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
				default -> throw new UnsupportedOperationException("Unsupported operand " + node.op());
			} + " " + resultRegName);
			writeIndented("and " + resultRegName + ", 0xFF");
			freeReg(leftReg);
			freeReg(rightReg);
			return resultReg;
		}
		}
	}

	private int processUnary(ExprUnary unary, Variables variables) throws IOException {
		final ExprUnary.Op op = unary.op();
		return switch (op) {
			case Deref -> {
				final int addrReg = write(unary.expression(), variables);
				final int typeSize = getTypeSize(Objects.requireNonNull(unary.type()));
				writeComment("deref", unary.location());
				final int valueReg = getFreeReg();
				final String addrRegName = getRegName(addrReg, 8);
				final String valueRegName = getRegName(valueReg, typeSize);
				writeIndented("mov " + valueRegName + ", [" + addrRegName + "]");
				freeReg(addrReg);
				yield valueReg;
			}
			case Neg -> {
				final int reg = write(unary.expression(), variables);
				final int typeSize = getTypeSize(Objects.requireNonNull(unary.type()));
				writeComment("neg", unary.location());
				writeIndented("neg " + getRegName(reg, typeSize));
				yield reg;
			}
			case Com -> {
				final int reg = write(unary.expression(), variables);
				final int typeSize = getTypeSize(Objects.requireNonNull(unary.type()));
				writeComment("com", unary.location());
				writeIndented("not " + getRegName(reg, typeSize));
				yield reg;
			}
			case NotLog -> {
				final int reg = write(unary.expression(), variables);
				final int typeSize = getTypeSize(Objects.requireNonNull(unary.type()));
				final String regName = getRegName(reg, typeSize);
				writeComment("not", unary.location());
				writeIndented("or " + regName + ", " + regName);
				writeIndented("sete " + regName);
				yield reg;
			}
			default -> throw new UnsupportedOperationException("unsupported operation " + op);
		};
	}

	private int writeSimpleArithmetic(String mnemonic, ExprBinary node, Variables variables) throws IOException {
		final int leftReg = write(node.left(), variables);
		final int rightReg = write(node.right(), variables);
		final int size = getTypeSize(node.typeNotNull());
		writeComment(mnemonic, node.location());
		writeIndented(mnemonic + " " + getRegName(leftReg, size) + ", " + getRegName(rightReg, size));
		freeReg(rightReg);
		return leftReg;
	}

	/**
	 * @return register of the target address
	 */
	private int writeLValue(Expression lValue, Variables variables) throws IOException {
		return switch (lValue) {
			case ExprVarAccess var -> {
				final VariableDetails variable = variables.get(var.index());
				final Location location = var.location();
				final Expression arrayIndex = var.arrayIndex();
				if (arrayIndex != null) {
					Utils.assertTrue(!variable.isScalar());
					writeComment("array " + variable, location);
					yield writeArrayAccess(variable, arrayIndex, var.typeNotNull(), variables);
				}
				else {
					Utils.assertTrue(variable.isScalar());
					final int varReg = getFreeReg();
					writeComment("var " + variable, location);
					writeAddrOfVar(varReg, variable);
					yield varReg;
				}
			}
			case ExprUnary deref -> write(deref.expression(), variables);
			default -> throw new IllegalStateException(String.valueOf(lValue));
		};
	}

	private int writeArrayAccess(@NotNull VariableDetails variable, @NotNull Expression index, @NotNull Type type, @NotNull Variables variables) throws IOException {
		final int offsetReg = write(index, variables);
		final String offsetRegName = getRegName(offsetReg);
		writeIndented("imul " + offsetRegName + ", " + getTypeSize(type));

		final int addrReg = getFreeReg();
		final String addrRegName = getRegName(addrReg);
		if (variable.isScalar()) {
			final int varReg = getFreeReg();
			final String varRegName = getRegName(varReg);
			writeAddrOfVar(varReg, variable);
			writeIndented("mov " + addrRegName + ", [" + varRegName + "]");
			freeReg(varReg);
		}
		else {
			writeAddrOfVar(addrReg, variable);
		}
		writeIndented("add " + addrRegName + ", " + offsetRegName);
		freeReg(offsetReg);
		return addrReg;
	}

	private void writeIfElse(StmtIf statement, Variables variables) throws IOException {
		final Expression condition = statement.condition();
		final Statement thenStatement = statement.thenStatement();
		final Statement elseStatement = statement.elseStatement();
		final int labelIndex = nextLabelIndex();
		final String elseLabel = "@else_" + labelIndex;
		final String nextLabel = "@endif_" + labelIndex;
		writeComment("if " + condition.toUserString(), statement.location());
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

	private void writeFor(StmtLoop statement, Variables variables) throws IOException {
		final List<Statement> iteration = statement.iteration();
		final String loopName = iteration.isEmpty() ? "while" : "for";
		final int labelIndex = nextLabelIndex();
		final String label = "@" + loopName + "_" + labelIndex;
		final String nextLabel = "@" + loopName + "_" + labelIndex + "_end";

		final Expression condition = statement.condition();
		writeComment(loopName + " " + condition.toUserString(), statement.location());
		writeLabel(label);
		final int conditionReg = write(condition, variables);
		final String conditionRegName = getRegName(conditionReg, getTypeSize(condition.typeNotNull()));
		writeComment(loopName + "-condition");
		writeIndented("or " + conditionRegName + ", " + conditionRegName);
		writeIndented("jz " + nextLabel);
		final Statement body = statement.bodyStatement();
		writeStatement(body, variables);

		if (iteration.size() > 0) {
			writeComment("for iteration");
			writeStatements(iteration, variables);
		}
		writeIndented("jmp " + label);

		writeLabel(nextLabel);
	}

	private int getFreeReg() {
		int mask = 1;
		for (int i = 0; i < 4; i++, mask += mask) {
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

	@NotNull
	private static String getStringLiteralName(int i) {
		return "string_" + i;
	}

	private static String getRegName(int reg) {
		return getRegName(reg, 0);
	}

	private static String getRegName(int reg, int size) {
		return switch (reg) {
			case 0 -> getXRegName('c', size);
			case 1 -> getXRegName('a', size);
			case 2 -> getXRegName('b', size);
			case 3 -> getXRegName('d', size);
			case 4 -> switch (size) {
				case 1 -> "r9b";
				case 2 -> "r9w";
				case 4 -> "r9d";
				default -> "r9";
			};
			default -> throw new IllegalStateException();
		};
	}

	@NotNull
	private static String getXRegName(char chr, int size) {
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

	private void writeAddrOfVar(int reg, VariableDetails variable) throws IOException {
		final String addrReg = getRegName(reg);
		writeIndented("lea " + addrReg + ", [" + getGlobalVarName(variable) + "]");
	}

	private static String getGlobalVarName(VariableDetails details) {
		return "var" + details.index();
	}

	private static int getVariableSize(Variable variable) {
		return getTypeSize(variable.type()) * Math.max(1, variable.arraySize());
	}

	private static class Variables {
		private final Map<Integer, VariableDetails> indexToVar = new HashMap<>();

		public Variables(@NotNull List<Variable> globalVariables) {
			int offset = 0;
			for (Variable variable : globalVariables) {
				Utils.assertTrue(!indexToVar.containsKey(variable.index()));
				indexToVar.put(variable.index(), new VariableDetails(variable.name(), variable.index(), offset, variable.isScalar(), variable.type()));
				offset += getVariableSize(variable);
			}
		}

		@NotNull
		public VariableDetails get(int index) {
			return indexToVar.get(index);
		}
	}

	private record VariableDetails(String name, int index, int offset, boolean isScalar, Type type) {
		@Override
		public String toString() {
			final StringBuilder buffer = new StringBuilder();
			buffer.append(name);
			buffer.append("(");
			buffer.append(index);
			buffer.append(")");
			return buffer.toString();
		}
	}
}
