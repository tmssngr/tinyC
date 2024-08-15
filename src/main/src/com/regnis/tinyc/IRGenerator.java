package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class IRGenerator {

	private static final int TRUE = 1;
	private static final int FALSE = 0;

	@NotNull
	public static IRProgram convert(Program program) {
		final IRGenerator generator = new IRGenerator();
		return generator.convertProgram(program);
	}

	private final TrivialRegisterAllocator registerAllocator = new TrivialRegisterAllocator();
	private final Map<Type, TypeInfo> types = new HashMap<>();

	private int labelIndex;
	@SuppressWarnings("unused") private boolean debug;
	private String functionRetLabel;
	private List<IRInstruction> instructions;
	private BreakContinueLabels breakContinueLabels;

	private IRGenerator() {
	}

	@NotNull
	private IRProgram convertProgram(Program program) {
		initializeTypes(program.typeDefs());

		final Variables variables = new Variables(program.globalVariables());

		final List<IRFunction> functions = new ArrayList<>();

		for (Function function : program.functions()) {
			functions.add(convertFunction(function, program.globalVars(), variables));
		}

		final List<IRGlobalVar> globalVars = createGlobalVars(program.globalVariables());
		final List<IRStringLiteral> stringLiterals = createStringLiterals(program.stringLiterals());
		return new IRProgram(functions, globalVars, stringLiterals);
	}

	private void initializeTypes(List<TypeDef> typeDefs) {
		for (TypeDef typeDef : typeDefs) {
			types.put(typeDef.typeNotNull(), createTypeInfo(typeDef.parts()));
		}
	}

	private TypeInfo createTypeInfo(List<TypeDef.Part> parts) {
		final Map<String, Integer> memberToOffset = new HashMap<>();
		int offset = 0;
		for (TypeDef.Part part : parts) {
			memberToOffset.put(part.name(), offset);
			offset += getTypeSize(part.typeNotNull());
		}
		return new TypeInfo(offset, memberToOffset);
	}

	private IRFunction convertFunction(Function function, List<Statement> declarations, Variables variables) {
		final String name = function.name();
		final String functionLabel = getFunctionLabel(name);
		if (function.asmLines().size() > 0) {
			Utils.assertTrue(function.localVars().isEmpty());
			Utils.assertTrue(function.statements().isEmpty());
			return new IRFunction(name, functionLabel, function.returnTypeNotNull(), List.of(), List.of(), function.asmLines());
		}

		instructions = new ArrayList<>();
		try {
			functionRetLabel = functionLabel + "_ret";
			if (name.equals("main")) {
				writeInit(declarations, variables);
			}

			final List<IRLocalVar> localVars = new ArrayList<>();
			for (Variable variable : function.localVars()) {
				final Type type = variable.type();
				final int size = variable.isArray()
						? getTypeSize(Objects.requireNonNull(type.toType())) * variable.arraySize()
						: getTypeSize(type);
				localVars.add(new IRLocalVar(variable.name(), variable.index(), variable.scope() == VariableScope.argument, size));
			}
			variables = new Variables(function.localVars(), variables);

			writeStatements(function.statements(), variables);
			writeLabel(functionRetLabel);
			return new IRFunction(name, functionLabel, Objects.requireNonNull(function.returnType()), localVars, instructions, List.of());
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
		case StmtVarDeclaration declaration -> writeAssignment(declaration.index(), declaration.scope(), Objects.requireNonNull(declaration.expression()), declaration.location(), variables);
		case StmtCompound compound -> writeStatements(compound.statements(), variables);
		case StmtIf ifStatement -> writeIfElse(ifStatement, variables);
		case StmtLoop forStatement -> writeFor(forStatement, variables);
		case StmtBreakContinue breakContinue -> writeBreakContinue(breakContinue);
		case StmtExpr stmt -> write(stmt.expression(), variables, true);
		case StmtReturn ret -> writeReturn(ret.expression(), variables);
		case null, default -> throw new UnsupportedOperationException(String.valueOf(statement));
		}
		Utils.assertTrue(registerAllocator.isNoneUsed());
	}

	private int writeCall(ExprFuncCall call) {
		// ensure no register is currently used, so we can pass the arguments in whatever register we need for the calling convention
		Utils.assertTrue(registerAllocator.isNoneUsed());

		final String name = call.name();
		final List<Expression> expressions = call.argExpressions();
		final List<IRCall.Arg> args = new ArrayList<>();
		for (Expression expression : expressions) {
			if (expression instanceof ExprVarAccess varAccess) {
				args.add(new IRCall.Arg(varAccess.index(), expression.typeNotNull()));
			}
			else {
				throw new IllegalStateException();
			}
		}
		final int resultReg;
		if (call.typeNotNull() == Type.VOID) {
			resultReg = -1;
		}
		else {
			resultReg = getFreeReg();
			Utils.assertTrue(resultReg == 0);
		}
		writeComment("call " + name, call.location());
		write(new IRCall(getFunctionLabel(name), args, resultReg));
		return resultReg;
	}

	private void writeReturn(@Nullable Expression expression, Variables variables) {
		if (expression != null) {
			writeComment("return " + expression.toUserString(), expression.location());
			final int reg = write(expression, variables, true);
			write(new IRReturnValue(reg, getTypeSize(expression.typeNotNull())));
			freeReg(reg);
		}
		else {
			writeComment("return");
		}
		write(new IRJump(Objects.requireNonNull(functionRetLabel)));
	}

	private void writeAssignment(int index, VariableScope scope, Expression expression, Location location, Variables variables) {
		final int expressionReg = write(expression, variables, true);
		final int varReg = getFreeReg();
		final VariableDetails variable = variables.get(index, scope);
		Utils.assertTrue(variable.isScalar());
		final int typeSize = getTypeSize(variable.type());
		writeComment("assign " + variable, location);
		writeAddrOfVar(varReg, variable);
		write(new IRMemStore(varReg, expressionReg, typeSize));
		freeReg(expressionReg);
		freeReg(varReg);
	}

	private int write(Expression node, Variables variables, boolean readVar) {
		return switch (node) {
			case ExprIntLiteral literal -> {
				final int value = literal.value();
				final int size = getTypeSize(literal.typeNotNull());
				writeComment("int lit " + value, node.location());
				final int reg = getFreeReg();
				write(new IRLoadInt(reg, value, size));
				yield reg;
			}
			case ExprBoolLiteral literal -> {
				final boolean value = literal.value();
				final int size = getTypeSize(literal.typeNotNull());
				writeComment("bool lit " + value, node.location());
				final int reg = getFreeReg();
				write(new IRLoadInt(reg, value ? TRUE : FALSE, size));
				yield reg;
			}
			case ExprStringLiteral literal -> {
				final int i = literal.index();
				final String stringLiteralName = getStringLiteralName(i);
				writeComment("string literal " + stringLiteralName, node.location());
				final int reg = getFreeReg();
				write(new IRLoadString(reg, i));
				yield reg;
			}
			case ExprVarAccess var -> writeVarAccess(var, variables, readVar);
			case ExprArrayAccess access -> writeArrayAccess(access, variables, readVar);
			case ExprMemberAccess access -> writeMemberAccess(access, variables, readVar);
			case ExprBinary binary -> writeBinary(binary, variables);
			case ExprUnary unary -> processUnary(unary, variables, readVar);
			case ExprFuncCall call -> writeCall(call);
			case ExprCast cast -> {
				final Expression expression = cast.expression();
				final int reg = write(expression, variables, true);
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
			default -> throw new UnsupportedOperationException("unsupported expression " + node);
		};
	}

	private int writeVarAccess(ExprVarAccess access, Variables variables, boolean readVar) {
		final VariableDetails variable = variables.get(access.index(), access.scope());
		writeComment((readVar ? "read " : "") + "var " + variable, access.location());
		Utils.assertTrue(variable.isScalar());
		final int addrReg = getFreeReg();
		writeAddrOfVar(addrReg, variable);
		return readVar
				? writeRead(addrReg, access.typeNotNull())
				: addrReg;
	}

	private int writeArrayAccess(ExprArrayAccess access, Variables variables, boolean readVar) {
		final ExprVarAccess var = access.varAccess();
		final VariableDetails variable = variables.get(var.index(), var.scope());
		final Expression arrayIndex = access.index();
		final Type type = access.typeNotNull();

		writeComment("array " + variable, access.location());
		final int offsetReg = write(arrayIndex, variables, true);
		write(new IRMul(offsetReg, getTypeSize(type)));

		final int addrReg = getFreeReg();
		if (variable.isScalar()) {
			final int varReg = getFreeReg();
			writeAddrOfVar(varReg, variable);
			write(new IRMemLoad(addrReg, varReg));
			freeReg(varReg);
		}
		else {
			writeAddrOfVar(addrReg, variable);
		}
		write(new IRBinary(IRBinary.Op.Add, addrReg, offsetReg, Type.POINTER_U8));
		freeReg(offsetReg);

		return readVar
				? writeRead(addrReg, type)
				: addrReg;
	}

	private int writeMemberAccess(ExprMemberAccess access, Variables variables, boolean readVar) {
		final Expression expression = access.expression();
		final TypeInfo typeInfo = types.get(expression.typeNotNull());
		if (typeInfo == null) {
			throw new IllegalStateException();
		}
		final int offset = typeInfo.get(access.member());
		final int addrReg = write(expression, variables, false);
		writeComment(expression.typeNotNull() + "." + access.member(), access.location());
		if (offset != 0) {
			final int offsetReg = getFreeReg();
			write(new IRLoadInt(offsetReg, offset, 8));
			write(new IRBinary(IRBinary.Op.Add, addrReg, offsetReg, Type.POINTER_U8));
			freeReg(offsetReg);
		}

		return readVar
				? writeRead(addrReg, access.typeNotNull())
				: addrReg;
	}

	private int writeRead(int addrReg, Type type) {
		final int valueReg = getFreeReg();
		final int typeSize = getTypeSize(type);
		write(new IRMemLoad(valueReg, addrReg, typeSize));
		freeReg(addrReg);
		return valueReg;
	}

	private int writeBinary(ExprBinary node, Variables variables) {
		switch (node.op()) {
		case Assign -> {
			final int expressionReg = write(node.right(), variables, true);
			final int lValueReg = write(node.left(), variables, false);
			final int typeSize = getTypeSize(node.typeNotNull());
			writeComment("assign", node.location());
			write(new IRMemStore(lValueReg, expressionReg, typeSize));
			freeReg(expressionReg);
			freeReg(lValueReg);
			return -1;
		}
		case Add -> {
			return writeBinaryArithmetic(IRBinary.Op.Add, node, variables);
		}
		case Sub -> {
			return writeBinaryArithmetic(IRBinary.Op.Sub, node, variables);
		}
		case Multiply -> {
			return writeBinaryArithmetic(IRBinary.Op.Mul, node, variables);
		}
		case Divide -> {
			return writeBinaryArithmetic(IRBinary.Op.Div, node, variables);
		}
		case Mod -> {
			return writeBinaryArithmetic(IRBinary.Op.Mod, node, variables);
		}
		case ShiftLeft -> {
			return writeBinaryArithmetic(IRBinary.Op.ShiftL, node, variables);
		}
		case ShiftRight -> {
			return writeBinaryArithmetic(IRBinary.Op.ShiftR, node, variables);
		}
		case And -> {
			return writeBinaryArithmetic(IRBinary.Op.And, node, variables);
		}
		case Or -> {
			return writeBinaryArithmetic(IRBinary.Op.Or, node, variables);
		}
		case Xor -> {
			return writeBinaryArithmetic(IRBinary.Op.Xor, node, variables);
		}
		case AndLog -> {
			final int labelIndex = nextLabelIndex();
			final String nextLabel = "@and_next_" + labelIndex;
			writeComment("logic and", node.location());
			final int conditionReg = write(node.left(), variables, true);
			write(new IRBranch(conditionReg, false, nextLabel));
			final int conditionReg2 = write(node.right(), variables, true);
			if (conditionReg2 != conditionReg) {
				write(new IRLoadReg(conditionReg, conditionReg2, getTypeSize(node.typeNotNull())));
			}
			freeReg(conditionReg2);
			writeLabel(nextLabel);
			return conditionReg;
		}
		case OrLog -> {
			final int labelIndex = nextLabelIndex();
			final String nextLabel = "@or_next_" + labelIndex;
			writeComment("logic or", node.location());
			final int conditionReg = write(node.left(), variables, true);
			write(new IRBranch(conditionReg, true, nextLabel));
			final int conditionReg2 = write(node.right(), variables, true);
			if (conditionReg2 != conditionReg) {
				write(new IRLoadReg(conditionReg, conditionReg2, getTypeSize(node.typeNotNull())));
			}
			freeReg(conditionReg2);
			writeLabel(nextLabel);
			return conditionReg;
		}
		case Lt -> {
			return writeBinaryCompare(IRCompare.Op.Lt, node, variables);
		}
		case LtEq -> {
			return writeBinaryCompare(IRCompare.Op.LtEq, node, variables);
		}
		case Equals -> {
			return writeBinaryCompare(IRCompare.Op.Equals, node, variables);
		}
		case NotEquals -> {
			return writeBinaryCompare(IRCompare.Op.NotEquals, node, variables);
		}
		case GtEq -> {
			return writeBinaryCompare(IRCompare.Op.GtEq, node, variables);
		}
		case Gt -> {
			return writeBinaryCompare(IRCompare.Op.Gt, node, variables);
		}
		default -> throw new UnsupportedOperationException(String.valueOf(node.op()));
		}
	}

	private int writeBinaryArithmetic(IRBinary.Op op, ExprBinary node, Variables variables) {
		final int leftReg = write(node.left(), variables, true);
		final int rightReg = write(node.right(), variables, true);
		writeComment(node.op().name().toLowerCase(Locale.ROOT), node.location());
		write(new IRBinary(op, leftReg, rightReg, node.typeNotNull()));
		freeReg(rightReg);
		return leftReg;
	}

	private int writeBinaryCompare(IRCompare.Op op, ExprBinary node, Variables variables) {
		final int leftReg = write(node.left(), variables, true);
		final int rightReg = write(node.right(), variables, true);
		final int resultReg = getFreeReg();
		writeComment(node.op().toString(), node.location());
		write(new IRCompare(op, resultReg, leftReg, rightReg, node.left().typeNotNull()));
		freeReg(leftReg);
		freeReg(rightReg);
		return resultReg;
	}

	private int processUnary(ExprUnary unary, Variables variables, boolean readVar) {
		final Expression expression = unary.expression();
		final ExprUnary.Op op = unary.op();
		return switch (op) {
			case AddrOf -> write(expression, variables, false);
			case Deref -> {
				Utils.assertTrue(expression.typeNotNull().isPointer());
				final int addrReg = write(expression, variables, true);
				if (!readVar) {
					yield addrReg;
				}

				final int typeSize = getTypeSize(unary.typeNotNull());
				writeComment("deref", unary.location());
				final int valueReg = getFreeReg();
				write(new IRMemLoad(valueReg, addrReg, typeSize));
				freeReg(addrReg);
				yield valueReg;
			}
			case Neg -> {
				final int reg = write(expression, variables, true);
				final int typeSize = getTypeSize(unary.typeNotNull());
				writeComment("neg", unary.location());
				write(new IRUnary(IRUnary.Op.neg, reg, typeSize));
				yield reg;
			}
			case Com -> {
				final int reg = write(expression, variables, true);
				final int typeSize = getTypeSize(unary.typeNotNull());
				writeComment("com", unary.location());
				write(new IRUnary(IRUnary.Op.not, reg, typeSize));
				yield reg;
			}
			case NotLog -> {
				final int reg = write(expression, variables, true);
				final int typeSize = getTypeSize(unary.typeNotNull());
				writeComment("not", unary.location());
				write(new IRUnary(IRUnary.Op.notLog, reg, typeSize));
				yield reg;
			}
			//noinspection UnnecessaryDefault
			default -> throw new UnsupportedOperationException("unsupported operation " + op);
		};
	}

	private void writeIfElse(StmtIf statement, Variables variables) {
		final Expression condition = statement.condition();
		final List<Statement> thenStatements = statement.thenStatements();
		final List<Statement> elseStatements = statement.elseStatements();
		final int labelIndex = nextLabelIndex();
		final String elseLabel = "@if_" + labelIndex + "_else";
		final String nextLabel = "@if_" + labelIndex + "_end";
		writeComment("if " + condition.toUserString(), statement.location());
		final int conditionReg = write(condition, variables, true);
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
		final String continueLabel = iteration.isEmpty() ? label : "@" + loopName + "_" + labelIndex + "_continue";
		final String breakLabel = "@" + loopName + "_" + labelIndex + "_break";

		final Expression condition = statement.condition();
		writeComment(loopName + " " + condition.toUserString(), statement.location());
		writeLabel(label);
		final int conditionReg = write(condition, variables, true);
		Utils.assertTrue(condition.typeNotNull() == Type.BOOL);
		write(new IRBranch(conditionReg, false, breakLabel));
		freeReg(conditionReg);
		writeComment(loopName + " body");
		final List<Statement> body = statement.bodyStatements();

		final BreakContinueLabels prevBreakContinueLabels = this.breakContinueLabels;
		try {
			breakContinueLabels = new BreakContinueLabels(breakLabel, continueLabel);
			writeStatements(body, variables);
		}
		finally {
			breakContinueLabels = prevBreakContinueLabels;
		}

		if (iteration.size() > 0) {
			writeLabel(continueLabel);
			writeStatements(iteration, variables);
		}
		write(new IRJump(label));

		writeLabel(breakLabel);
	}

	private void writeBreakContinue(StmtBreakContinue breakContinue) {
		if (breakContinueLabels == null) {
			throw new SyntaxException(Messages.breakContinueOnlyAllowedWithinWhileOrFor(), breakContinue.location());
		}

		write(new IRJump(breakContinue.isBreak() ? breakContinueLabels.breakLabel() : breakContinueLabels.continueLabel()));
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

	private int getTypeSize(Type type) {
		final TypeInfo typeInfo = types.get(type);
		if (typeInfo != null) {
			return typeInfo.size;
		}
		if (type.isPointer()) {
			return 8;
		}
		return Type.getSize(type);
	}

	private int getVariableSize(Variable variable) {
		return getTypeSize(variable.type()) * Math.max(1, variable.arraySize());
	}

	@NotNull
	private static String getStringLiteralName(int i) {
		return "string_" + i;
	}

	private class Variables {
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

			if (scope == VariableScope.function || scope == VariableScope.argument) {
				return indexToVar.get(index);
			}

			return parent.get(index, scope);
		}
	}

	private record BreakContinueLabels(String breakLabel, String continueLabel) {
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

	private record TypeInfo(int size, Map<String, Integer> memberToOffset) {
		public int get(String member) {
			return memberToOffset.get(member);
		}
	}
}
