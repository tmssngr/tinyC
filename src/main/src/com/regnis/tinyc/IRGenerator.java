package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public class IRGenerator {

	private static final int TRUE = 1;
	private static final int FALSE = 0;

	private final TrivialRegisterAllocator registerAllocator = new TrivialRegisterAllocator();
	private int labelIndex;
	@SuppressWarnings("unused") private boolean debug;
	private String functionRetLabel;
	private List<IRInstruction> instructions;

	public IRGenerator() {
	}

	@NotNull
	public IRProgram convert(Program program) {
		final Variables variables = new Variables(program.globalVariables());

		final List<IRFunction> functions = new ArrayList<>();

		for (Function function : program.functions()) {
			functions.add(convertFunction(function, program.globalVars(), variables));
		}

		final List<IRGlobalVar> globalVars = createGlobalVars(program.globalVariables());
		final List<IRStringLiteral> stringLiterals = createStringLiterals(program.stringLiterals());
		return new IRProgram(functions, globalVars, stringLiterals);
	}

	private IRFunction convertFunction(Function function, List<Statement> declarations, Variables variables) {
		final String name = function.name();
		instructions = new ArrayList<>();
		try {
			final String functionLabel = getFunctionLabel(name);
			functionRetLabel = functionLabel + "_ret";
			if (name.equals("main")) {
				writeInit(declarations, variables);
			}

			final List<IRLocalVar> localVars = new ArrayList<>();
			for (Variable variable : function.localVars()) {
				Utils.assertTrue(variable.scope() == VariableScope.function);
				localVars.add(new IRLocalVar(variable.name(), variable.index(), getTypeSize(variable.type())));
			}
			variables = new Variables(function.localVars(), variables);

			writeStatements(function.statements(), variables);
			writeLabel(functionRetLabel);
			return new IRFunction(name, functionLabel, Objects.requireNonNull(function.returnType()), instructions, localVars);
		}
		finally {
			instructions = List.of();
		}
	}

	private void writeInit(List<Statement> declarations, Variables variables) {
		boolean isFirst = true;
		for (Statement declaration : declarations) {
			if (isFirst) {
				isFirst = false;
				writeComment("begin initialize global variables");
			}
			writeStatement(declaration, variables);
		}

		if (!isFirst) {
			writeComment("end initialize global variables");
		}
	}

	private List<IRGlobalVar> createGlobalVars(List<Variable> globalVariables) {
		final List<IRGlobalVar> globalVars = new ArrayList<>();
		for (Variable variable : globalVariables) {
			Utils.assertTrue(variable.scope() == VariableScope.global);
			final int size = getVariableSize(variable);
			globalVars.add(new IRGlobalVar(variable.name(), variable.index(), size));
		}
		return globalVars;
	}

	private List<IRStringLiteral> createStringLiterals(List<StringLiteral> stringLiterals) {
		final List<IRStringLiteral> irStringLiterals = new ArrayList<>();
		for (StringLiteral literal : stringLiterals) {
			irStringLiterals.add(new IRStringLiteral(literal.index(), getStringLiteralName(literal.index()), literal.text() + '\0'));
		}
		return irStringLiterals;
	}

	private String getFunctionLabel(String name) {
		return "@" + name;
	}

	private void writeStatements(List<Statement> statements, Variables variables) {
		for (Statement statement : statements) {
			writeStatement(statement, variables);
		}
	}

	private void writeStatement(Statement statement, Variables variables) {
		Utils.assertTrue(registerAllocator.isNoneUsed());
		switch (statement) {
		case StmtVarDeclaration declaration -> writeAssignment(declaration.index(), declaration.scope(), declaration.expression(), declaration.location(), variables);
		case StmtCompound compound -> writeStatements(compound.statements(), variables);
		case StmtIf ifStatement -> writeIfElse(ifStatement, variables);
		case StmtLoop forStatement -> writeFor(forStatement, variables);
		case StmtExpr stmt -> write(stmt.expression(), variables);
		case StmtReturn ret -> writeReturn(ret.expression(), variables);
		case null, default -> throw new UnsupportedOperationException(String.valueOf(statement));
		}
		Utils.assertTrue(registerAllocator.isNoneUsed());
	}

	private int writeCall(ExprFuncCall call, Variables variables) {
		final List<Expression> expressions = call.argExpressions();
		final String name = call.name();
		if (name.equals("printString")) {
			if (expressions.size() != 1) {
				throw new IllegalStateException("Unsupported arguments " + expressions);
			}
			final Expression expression = expressions.getFirst();
			final int reg = write(expression, variables);
			final Type type = expression.typeNotNull();
			if (type.toType() != Type.U8) {
				throw new IllegalStateException("Unsupported type");
			}
			writeComment("print " + type, call.location());
			write(new IRPrintStringZero(reg));
			freeReg(reg);
		}
		else if (name.equals("print")) {
			if (expressions.size() != 1) {
				throw new IllegalStateException("Unsupported arguments " + expressions);
			}
			final Expression expression = expressions.getFirst();
			final int reg = write(expression, variables);
			final Type type = expression.typeNotNull();
			writeComment("print " + type, call.location());
			write(new IRPrintInt(reg));
			freeReg(reg);
		}
		else {
			if (expressions.size() > 1) {
				throw new IllegalStateException("Unsupported arguments " + expressions);
			}
			final List<IRCall.Arg> args = new ArrayList<>();
			for (Expression expression : expressions) {
				final int reg = write(expression, variables);
				args.add(new IRCall.Arg(reg, expression.typeNotNull()));
			}
			writeComment("call " + name, call.location());
			write(new IRCall(getFunctionLabel(name), args));
			for (IRCall.Arg arg : args) {
				freeReg(arg.reg());
			}
		}
		return call.typeNotNull() == Type.VOID ? -1 : getFreeReg();
	}

	private void writeReturn(@Nullable Expression expression, Variables variables) {
		if (expression != null) {
			writeComment("return " + expression.toUserString(), expression.location());
			final int reg = write(expression, variables);
			write(new IRReturnValue(reg, getTypeSize(expression.typeNotNull())));
			freeReg(reg);
		}
		else {
			writeComment("return");
		}
		write(new IRJump(Objects.requireNonNull(functionRetLabel)));
	}

	private void writeAssignment(int index, VariableScope scope, Expression expression, Location location, Variables variables) {
		final int expressionReg = write(expression, variables);
		final int varReg = getFreeReg();
		final VariableDetails variable = variables.get(index, scope);
		Utils.assertTrue(variable.isScalar());
		final int typeSize = getTypeSize(variable.type());
		writeComment("assign " + variable, location);
		writeAddrOfVar(varReg, variable);
		write(new IRStore(varReg, expressionReg, typeSize));
		freeReg(expressionReg);
		freeReg(varReg);
	}

	private int write(Expression node, Variables variables) {
		return switch (node) {
			case ExprIntLiteral literal -> {
				final int value = literal.value();
				final int size = getTypeSize(literal.typeNotNull());
				writeComment("int lit " + value, node.location());
				final int reg = getFreeReg();
				write(new IRLdIntLiteral(reg, value, size));
				yield reg;
			}
			case ExprBoolLiteral literal -> {
				final boolean value = literal.value();
				final int size = getTypeSize(literal.typeNotNull());
				writeComment("bool lit " + value, node.location());
				final int reg = getFreeReg();
				write(new IRLdIntLiteral(reg, value ? TRUE : FALSE, size));
				yield reg;
			}
			case ExprStringLiteral literal -> {
				final int i = literal.index();
				final String stringLiteralName = getStringLiteralName(i);
				writeComment("string literal " + stringLiteralName, node.location());
				final int reg = getFreeReg();
				write(new IRLdStringLiteral(reg, i));
				yield reg;
			}
			case ExprVarAccess var -> {
				final VariableDetails variable = variables.get(var.index(), var.scope());
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
				yield writeRead(addrReg, var.typeNotNull());
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
					write(new IRCast(targetReg, cast.typeNotNull(), reg, expression.typeNotNull()));
					freeReg(reg);
					yield targetReg;
				}
				yield reg;
			}
			case ExprAddrOf addrOf -> {
				final VariableDetails variable = variables.get(addrOf.index(), addrOf.scope());
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

	private int writeAddressOf(VariableDetails variable) {
		Utils.assertTrue(variable.isScalar());
		final int reg = getFreeReg();
		writeAddrOfVar(reg, variable);
		return reg;
	}

	private int writeRead(int addrReg, Type type) {
		final int valueReg = getFreeReg();
		final int typeSize = getTypeSize(type);
		write(new IRLoad(valueReg, addrReg, typeSize));
		freeReg(addrReg);
		return valueReg;
	}

	private int writeBinary(ExprBinary node, Variables variables) {
		switch (node.op()) {
		case Assign -> {
			final int expressionReg = write(node.right(), variables);
			final int lValueReg = writeLValue(node.left(), variables);
			final int typeSize = getTypeSize(node.typeNotNull());
			writeComment("assign", node.location());
			write(new IRStore(lValueReg, expressionReg, typeSize));
			freeReg(expressionReg);
			freeReg(lValueReg);
			return -1;
		}
		case Add, Sub, Multiply, Divide, And, Or, Xor -> {
			final int leftReg = write(node.left(), variables);
			final int rightReg = write(node.right(), variables);
			final int size = getTypeSize(node.typeNotNull());
			writeComment(node.op().name().toLowerCase(Locale.ROOT), node.location());
			write(new IRBinary(node.op(), leftReg, rightReg, size));
			freeReg(rightReg);
			return leftReg;
		}
		case AndLog -> {
			final int labelIndex = nextLabelIndex();
			final String nextLabel = "@and_next_" + labelIndex;
			writeComment("logic and", node.location());
			final int conditionReg = write(node.left(), variables);
			write(new IRBranch(conditionReg, false, nextLabel));
			final int conditionReg2 = write(node.right(), variables);
			if (conditionReg2 != conditionReg) {
				write(new IRCopy(conditionReg, conditionReg2, getTypeSize(node.typeNotNull())));
			}
			freeReg(conditionReg2);
			writeLabel(nextLabel);
			return conditionReg;
		}
		case OrLog -> {
			final int labelIndex = nextLabelIndex();
			final String nextLabel = "@or_next_" + labelIndex;
			writeComment("logic or", node.location());
			final int conditionReg = write(node.left(), variables);
			write(new IRBranch(conditionReg, true, nextLabel));
			final int conditionReg2 = write(node.right(), variables);
			if (conditionReg2 != conditionReg) {
				write(new IRCopy(conditionReg, conditionReg2, getTypeSize(node.typeNotNull())));
			}
			freeReg(conditionReg2);
			writeLabel(nextLabel);
			return conditionReg;
		}
		default -> {
			final int leftReg = write(node.left(), variables);
			final int rightReg = write(node.right(), variables);
			final int resultReg = getFreeReg();
			writeComment(node.op().toString(), node.location());
			write(new IRCompare(node.op(), resultReg, leftReg, rightReg, node.left().typeNotNull()));
			freeReg(leftReg);
			freeReg(rightReg);
			return resultReg;
		}
		}
	}

	private int processUnary(ExprUnary unary, Variables variables) {
		final ExprUnary.Op op = unary.op();
		return switch (op) {
			case Deref -> {
				final int addrReg = write(unary.expression(), variables);
				final int typeSize = getTypeSize(Objects.requireNonNull(unary.type()));
				writeComment("deref", unary.location());
				final int valueReg = getFreeReg();
				write(new IRLoad(valueReg, addrReg, typeSize));
				freeReg(addrReg);
				yield valueReg;
			}
			case Neg -> {
				final int reg = write(unary.expression(), variables);
				final int typeSize = getTypeSize(Objects.requireNonNull(unary.type()));
				writeComment("neg", unary.location());
				write(new IRUnary(IRUnary.Op.neg, reg, typeSize));
				yield reg;
			}
			case Com -> {
				final int reg = write(unary.expression(), variables);
				final int typeSize = getTypeSize(Objects.requireNonNull(unary.type()));
				writeComment("com", unary.location());
				write(new IRUnary(IRUnary.Op.not, reg, typeSize));
				yield reg;
			}
			case NotLog -> {
				final int reg = write(unary.expression(), variables);
				final int typeSize = getTypeSize(Objects.requireNonNull(unary.type()));
				writeComment("not", unary.location());
				write(new IRUnary(IRUnary.Op.notLog, reg, typeSize));
				yield reg;
			}
			default -> throw new UnsupportedOperationException("unsupported operation " + op);
		};
	}

	/**
	 * @return register of the target address
	 */
	private int writeLValue(Expression lValue, Variables variables) {
		return switch (lValue) {
			case ExprVarAccess var -> {
				final VariableDetails variable = variables.get(var.index(), var.scope());
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

	private int writeArrayAccess(@NotNull VariableDetails variable, @NotNull Expression index, @NotNull Type type, @NotNull Variables variables) {
		final int offsetReg = write(index, variables);
		write(new IRMul(offsetReg, getTypeSize(type)));

		final int addrReg = getFreeReg();
		if (variable.isScalar()) {
			final int varReg = getFreeReg();
			writeAddrOfVar(varReg, variable);
			write(new IRLoad(addrReg, varReg));
			freeReg(varReg);
		}
		else {
			writeAddrOfVar(addrReg, variable);
		}
		write(new IRBinary(ExprBinary.Op.Add, addrReg, offsetReg));
		freeReg(offsetReg);
		return addrReg;
	}

	private void writeIfElse(StmtIf statement, Variables variables) {
		final Expression condition = statement.condition();
		final List<Statement> thenStatements = statement.thenStatements();
		final List<Statement> elseStatements = statement.elseStatements();
		final int labelIndex = nextLabelIndex();
		final String elseLabel = "@else_" + labelIndex;
		final String nextLabel = "@endif_" + labelIndex;
		writeComment("if " + condition.toUserString(), statement.location());
		final int conditionReg = write(condition, variables);
		Utils.assertTrue(condition.typeNotNull() == Type.BOOL);
		write(new IRBranch(conditionReg, false, elseLabel));
		freeReg(conditionReg);
		writeComment("then");
		writeStatements(thenStatements, variables);
		write(new IRJump(nextLabel));
		writeComment("else");
		writeLabel(elseLabel);
		writeStatements(elseStatements, variables);
		writeLabel(nextLabel);
	}

	private void writeFor(StmtLoop statement, Variables variables) {
		final List<Statement> iteration = statement.iteration();
		final String loopName = iteration.isEmpty() ? "while" : "for";
		final int labelIndex = nextLabelIndex();
		final String label = "@" + loopName + "_" + labelIndex;
		final String nextLabel = "@" + loopName + "_" + labelIndex + "_end";

		final Expression condition = statement.condition();
		writeComment(loopName + " " + condition.toUserString(), statement.location());
		writeLabel(label);
		final int conditionReg = write(condition, variables);
		Utils.assertTrue(condition.typeNotNull() == Type.BOOL);
		write(new IRBranch(conditionReg, false, nextLabel));
		freeReg(conditionReg);
		writeComment(loopName + " body");
		final List<Statement> body = statement.bodyStatements();
		writeStatements(body, variables);

		if (iteration.size() > 0) {
			writeComment("for iteration");
			writeStatements(iteration, variables);
		}
		write(new IRJump(label));

		writeLabel(nextLabel);
	}

	private int getFreeReg() {
		final int allocate = registerAllocator.allocate();
		if (debug) {
			writeComment("got " + allocate + ", " + registerAllocator);
		}
		return allocate;
	}

	private void freeReg(int reg) {
		registerAllocator.free(reg);
		if (debug) {
			writeComment("freed " + reg + ", " + registerAllocator);
		}
	}

	private void writeLabel(String label) {
		write(new IRLabel(label));
	}

	private void writeComment(String s, Location location) {
		writeComment(location + " " + s);
	}

	private void writeComment(String s) {
		write(new IRComment(s));
	}

	private void write(@NotNull IRInstruction instruction) {
		instructions.add(instruction);
	}

	private int nextLabelIndex() {
		labelIndex++;
		return labelIndex;
	}

	private void writeAddrOfVar(int reg, VariableDetails variable) {
		write(new IRAddrOfVar(reg, variable.scope(), variable.index()));
	}

	@NotNull
	private static String getStringLiteralName(int i) {
		return "string_" + i;
	}

	private static int getTypeSize(Type type) {
		if (type.isPointer()) {
			return 8;
		}
		return Type.getSize(type);
	}

	private static int getVariableSize(Variable variable) {
		return getTypeSize(variable.type()) * Math.max(1, variable.arraySize());
	}

	private static class Variables {
		private final Map<Integer, VariableDetails> indexToVar = new HashMap<>();
		private final Variables parent;

		public Variables(@NotNull List<Variable> globalVariables) {
			this(globalVariables, null);
		}

		public Variables(@NotNull List<Variable> variables, @Nullable Variables parent) {
			this.parent = parent;
			int offset = 0;
			for (Variable variable : variables) {
				Utils.assertTrue(!indexToVar.containsKey(variable.index()));
				indexToVar.put(variable.index(), new VariableDetails(variable.name(), variable.scope(), variable.index(), offset, variable.isScalar(), variable.type()));
				offset += getVariableSize(variable);
			}
		}

		@NotNull
		public VariableDetails get(int index, @NotNull VariableScope scope) {
			if (parent == null) {
				Utils.assertTrue(scope == VariableScope.global);
				return indexToVar.get(index);
			}

			if (scope == VariableScope.function) {
				return indexToVar.get(index);
			}

			return parent.get(index, scope);
		}
	}

	private record VariableDetails(String name, VariableScope scope, int index, int offset, boolean isScalar, Type type) {
		@Override
		public String toString() {
			final StringBuilder buffer = new StringBuilder();
			buffer.append(name);
			buffer.append("(");
			buffer.append(scope == VariableScope.global ? "$" : "%");
			buffer.append(index);
			buffer.append(")");
			return buffer.toString();
		}
	}

	private static class TrivialRegisterAllocator {

		private static final int MAX_REGISTERS = 4;

		private int freeRegs;

		@Override
		public String toString() {
			final StringBuilder buffer = new StringBuilder();
			buffer.append("used: ");
			int mask = 1;
			boolean first = true;
			for (int i = 0; i < MAX_REGISTERS; i++, mask += mask) {
				if ((freeRegs & mask) != 0) {
					if (first) {
						first = false;
					}
					else {
						buffer.append(", ");
					}
					buffer.append(i);
				}
			}
			if (first) {
				buffer.append("none");
			}
			return buffer.toString();
		}

		public int allocate() {
			int mask = 1;
			for (int i = 0; i < MAX_REGISTERS; i++, mask += mask) {
				if ((freeRegs & mask) == 0) {
					freeRegs |= mask;
					return i;
				}
			}
			throw new IllegalStateException("no free reg");
		}

		public void free(int reg) {
			final int mask = 1 << reg;
			Utils.assertTrue((freeRegs & mask) != 0);
			freeRegs ^= mask;
		}

		public boolean isNoneUsed() {
			return freeRegs == 0;
		}
	}
}
