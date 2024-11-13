package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class IRGenerator {

	@NotNull
	public static IRProgram convert(Program program) {
		final IRGenerator generator = new IRGenerator();
		return generator.convertProgram(program);
	}

	private final Map<Type, TypeInfo> types = new HashMap<>();
	private final List<Integer> globalVarsCantBeRegister = new ArrayList<>();

	private int labelIndex;

	private List<IRInstruction> instructions = List.of();
	private List<IRVarDef> localVars = List.of();
	private List<Integer> localVarsCantBeRegister = List.of();
	private String functionRetLabel;
	private BreakContinueLabels breakContinueLabels;

	private IRGenerator() {
	}

	@NotNull
	private IRProgram convertProgram(Program program) {
		initializeTypes(program.typeDefs());

		final List<IRVarDef> globalVars = processGlobalVars(program.globalVariables());

		final List<IRFunction> functions = new ArrayList<>();

		for (Function function : program.functions()) {
			functions.add(convertFunction(function, program.globalVars()));
		}

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

	private IRFunction convertFunction(Function function, List<Statement> declarations) {
		final String name = function.name();
		final String functionLabel = getFunctionLabel(name);
		if (function.asmLines().size() > 0) {
			Utils.assertTrue(function.localVars().isEmpty());
			Utils.assertTrue(function.statements().isEmpty());
			return new IRFunction(name, functionLabel, function.returnTypeNotNull(), List.of(), List.of(), function.asmLines());
		}

		processLocalVars(function);
		instructions = new ArrayList<>();
		try {
			functionRetLabel = functionLabel + "_ret";
			if (name.equals("main")) {
				writeInit(declarations);
			}

			writeStatements(function.statements());
			writeLabel(functionRetLabel);

			return new IRFunction(name, functionLabel, Objects.requireNonNull(function.returnType()), localVars, instructions, List.of());
		}
		finally {
			localVars = List.of();
			localVarsCantBeRegister = List.of();
			instructions = List.of();
		}
	}

	private void processLocalVars(Function function) {
		localVars = new ArrayList<>();
		localVarsCantBeRegister = new ArrayList<>();
		for (Variable variable : function.localVars()) {
			final Type type = variable.type();
			final int size = variable.isArray()
					? getTypeSize(Objects.requireNonNull(type.toType())) * variable.arraySize()
					: getTypeSize(type);
			localVars.add(new IRVarDef(variable.name(), variable.index(), variable.scope(), type, size));
			if (!variable.canBeRegister()) {
				localVarsCantBeRegister.add(variable.index());
			}
		}
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

	private void writeInit(List<Statement> declarations) {
		boolean isFirst = true;
		for (Statement declaration : declarations) {
			if (isFirst) {
				isFirst = false;
				writeComment("begin initialize global variables");
			}
			writeStatement(declaration);
		}

		if (!isFirst) {
			writeComment("end initialize global variables");
		}
	}

	private List<IRVarDef> processGlobalVars(List<Variable> globalVariables) {
		final List<IRVarDef> globalVars = new ArrayList<>();
		for (Variable variable : globalVariables) {
			Utils.assertTrue(variable.scope() == VariableScope.global);
			final int size = getVariableSize(variable);
			globalVars.add(new IRVarDef(variable.name(), variable.index(), VariableScope.global, variable.type(), size));
			if (!variable.canBeRegister()) {
				globalVarsCantBeRegister.add(variable.index());
			}
		}
		return globalVars;
	}

	private int getVariableSize(Variable variable) {
		return getTypeSize(variable.type()) * Math.max(1, variable.arraySize());
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

	private void writeStatements(List<Statement> statements) {
		for (Statement statement : statements) {
			writeStatement(statement);
		}
	}

	private void writeStatement(Statement statement) {
		switch (statement) {
		case StmtCompound compound -> writeStatements(compound.statements());
		case StmtExpr stmt -> writeExpressionStatement(stmt);
		case StmtIf ifStatement -> writeIfElse(ifStatement);
		case StmtLoop forStatement -> writeFor(forStatement);
		case StmtBreakContinue breakContinue -> writeBreakContinue(breakContinue);
		case StmtReturn ret -> writeReturn(ret);
		case null, default -> throw new UnsupportedOperationException(String.valueOf(statement));
		}
	}

	private void writeReturn(StmtReturn stmtReturn) {
		final Expression expression = stmtReturn.expression();
		if (expression != null) {
			writeComment("return " + expression.toUserString(), expression.location());
			final IRVar var = writeExpression(expression);
			write(new IRRetValue(var, stmtReturn.location()));
		}
		else {
			writeComment("return", stmtReturn.location());
		}
		write(new IRJump(functionRetLabel));
	}

	private void writeIfElse(StmtIf statement) {
		final Expression condition = statement.condition();
		Utils.assertTrue(condition.typeNotNull() == Type.BOOL);
		final List<Statement> thenStatements = statement.thenStatements();
		final List<Statement> elseStatements = statement.elseStatements();
		final int labelIndex = nextLabelIndex();
		final String labelThen = "@if_" + labelIndex + "_then";
		final String labelElse = "@if_" + labelIndex + "_else";
		final String labelEnd = "@if_" + labelIndex + "_end";
		writeComment("if " + condition.toUserString(), statement.location());
		final IRVar conditionVar = writeExpression(condition);
		if (elseStatements.isEmpty()) {
			write(new IRBranch(conditionVar, false, labelEnd,
			                   labelThen));
			writeStatements(thenStatements);
		}
		else {
			write(new IRBranch(conditionVar, false, labelElse,
			                   labelThen));
			writeStatements(thenStatements);
			write(new IRJump(labelEnd));

			writeLabel(labelElse);
			writeStatements(elseStatements);
		}
		writeLabel(labelEnd);
	}

	private void writeBreakContinue(StmtBreakContinue breakContinue) {
		if (breakContinueLabels == null) {
			throw new SyntaxException(Messages.breakContinueOnlyAllowedWithinWhileOrFor(), breakContinue.location());
		}

		write(new IRJump(breakContinue.isBreak() ? breakContinueLabels.breakLabel() : breakContinueLabels.continueLabel()));
	}

	private void writeFor(StmtLoop loop) {
		final List<Statement> iteration = loop.iteration();
		final String loopName = iteration.isEmpty() ? "while" : "for";
		final int labelIndex = nextLabelIndex();
		final String label = "@" + loopName + "_" + labelIndex;
		final String bodyLabel = "@" + loopName + "_" + labelIndex + "_body";
		final String continueLabel = iteration.isEmpty() ? label : "@" + loopName + "_" + labelIndex + "_continue";
		final String breakLabel = "@" + loopName + "_" + labelIndex + "_break";

		final Expression condition = loop.condition();
		Utils.assertTrue(condition.typeNotNull() == Type.BOOL);
		final boolean endlessLoop = condition instanceof ExprBoolLiteral literal && literal.value();
		writeComment(loopName + " " + condition.toUserString(), loop.location());
		writeLabel(label);
		if (!endlessLoop) {
			final IRVar conditionVar = writeExpression(condition);
			write(new IRBranch(conditionVar, false, breakLabel,
			                   bodyLabel));
		}

		final BreakContinueLabels prevBreakContinueLabels = this.breakContinueLabels;
		try {
			breakContinueLabels = new BreakContinueLabels(breakLabel, continueLabel);
			writeStatements(loop.bodyStatements());
		}
		finally {
			breakContinueLabels = prevBreakContinueLabels;
		}

		if (iteration.size() > 0) {
			writeLabel(continueLabel);
			writeStatements(iteration);
		}
		write(new IRJump(label));

		writeLabel(breakLabel);
	}

	private void writeExpressionStatement(StmtExpr stmt) {
		final Expression expression = stmt.expression();
		switch (expression) {
		case ExprFuncCall call -> writeCall(null, call);
		case ExprBinary binary -> {
			Utils.assertTrue(binary.op() == ExprBinary.Op.Assign);
			writeAssign(binary);
		}
		default -> throw new UnsupportedOperationException(String.valueOf(stmt));
		}
	}

	private IRVar writeExpression(Expression expression) {
		return switch (expression) {
			case ExprVarAccess access -> varAccessToVar(access);
			case ExprArrayAccess access -> writeArrayAccess(access);
			case ExprBinary binary -> writeBinary(binary);
			default -> {
				final IRVar tmp = createTempVar(expression.typeNotNull());
				writeExpression(tmp, expression);
				yield tmp;
			}
		};
	}

	private void writeExpression(IRVar var, Expression expression) {
		switch (expression) {
		case ExprIntLiteral literal -> write(new IRLiteral(var, literal.value(), literal.location()));
		case ExprBoolLiteral literal -> write(new IRLiteral(var, literal.value() ? 1 : 0, literal.location()));
		case ExprStringLiteral literal -> write(new IRString(var, literal.index(), literal.location()));
		case ExprVarAccess access -> write(new IRMove(var, varAccessToVar(access), access.location()));
		case ExprArrayAccess access -> writeArrayAccess(var, access);
		case ExprMemberAccess access -> writeMemberAccess(var, access);
		case ExprBinary binary -> writeBinary(var, binary);
		case ExprUnary unary -> writeUnary(var, unary);
		case ExprFuncCall call -> writeCall(var, call);
		case ExprCast cast -> writeCast(var, cast);
		default -> throw new UnsupportedOperationException(String.valueOf(expression));
		}
	}

	private void writeMemberAccess(IRVar var, ExprMemberAccess access) {
		final IRVar addr = writeMemberAddress(access);
		write(new IRMemLoad(var, addr, access.location()));
	}

	private IRVar writeMemberAddress(ExprMemberAccess access) {
		final IRVar addr = createTempVar(Type.pointer(access.typeNotNull()));
		writeMemberAddress(addr, access);
		return addr;
	}

	private void writeMemberAddress(IRVar addr, ExprMemberAccess access) {
		writeComment(access.expression() + "." + access.member(), access.location());
		writeAddrOf(addr, access.expression(), access.location());
		final int offset = getMemberOffset(access);
		if (offset != 0) {
			final IRVar offsetVar = createTempVar(addr.type());
			write(new IRLiteral(offsetVar, offset, access.location()));
			write(new IRBinary(addr, IRBinary.Op.Add, addr, offsetVar, access.location()));
		}
	}

	private int getMemberOffset(ExprMemberAccess access) {
		final TypeInfo typeInfo = types.get(access.expression().typeNotNull());
		if (typeInfo == null) {
			throw new IllegalStateException();
		}
		return typeInfo.get(access.member());
	}

	private IRVar writeArrayAccess(ExprArrayAccess access) {
		final IRVar tmp = createTempVar(access.typeNotNull());
		writeArrayAccess(tmp, access);
		return tmp;
	}

	private void writeCast(IRVar tmp, ExprCast cast) {
		final IRVar value = writeExpression(cast.expression());
		write(new IRCast(tmp, value, cast.location()));
	}

	private IRVar writeBinary(ExprBinary binary) {
		final ExprBinary.Op op = binary.op();
		switch (op) {
		case Assign -> {
			return writeAssign(binary);
		}
		default -> {
			final IRVar tmp = createTempVar(binary.typeNotNull());
			writeBinary(tmp, binary);
			return tmp;
		}
		}
	}

	@NotNull
	private IRVar writeAssign(ExprBinary binary) {
		final Expression left = binary.left();
		final Expression right = binary.right();
		switch (left) {
		case ExprVarAccess access -> {
			final IRVar var = varAccessToVar(access);
			writeExpression(var, right);
			return var;
		}
		case ExprArrayAccess access -> {
			final IRVar valueVar = writeExpression(right);
			final IRVar addr = arrayAddr(access);
			write(new IRMemStore(addr, valueVar, access.location()));
			return valueVar;
		}
		case ExprUnary unary -> {
			if (unary.op() == ExprUnary.Op.Deref) {
				final IRVar valueVar = writeExpression(right);
				final IRVar pointer = writeExpression(unary.expression());
				write(new IRMemStore(pointer, valueVar, unary.location()));
				return valueVar;
			}
		}
		case ExprMemberAccess access -> {
			final IRVar valueVar = writeExpression(right);
			final IRVar addr = writeMemberAddress(access);
			write(new IRMemStore(addr, valueVar, access.location()));
			return valueVar;
		}
		default -> {
		}
		}

		throw new UnsupportedOperationException(String.valueOf(left));
	}

	private void writeArrayAccess(IRVar var, ExprArrayAccess access) {
		final IRVar addr = arrayAddr(access);
		write(new IRMemLoad(var, addr, access.location()));
	}

	@NotNull
	private IRVar arrayAddr(ExprArrayAccess access) {
		final IRVar addr = createTempVar(access.varAccess().typeNotNull());
		writeAddrOf(addr, access, access.location());
		return addr;
	}

	private void arrayAddr(IRVar var, ExprArrayAccess access, Location location) {
		final IRVar index = writeExpression(access.index());
		final int typeSize = getTypeSize(access.typeNotNull());
		final IRVar offset;
		if (typeSize > 1) {
			offset = createTempVar(index.type());
			write(new IRLiteral(offset, typeSize, location));
			write(new IRBinary(offset, IRBinary.Op.Mul, offset, index, location));
		}
		else {
			offset = index;
		}

		final IRVar pointerOffset = createTempVar(var.type());
		write(new IRCast(pointerOffset, offset, location));

		final ExprVarAccess varAccess = access.varAccess();
		if (varAccess.varIsArray()) {
			write(new IRAddrOfArray(var, varAccessToVar(varAccess), location));
		}
		else {
			write(new IRMove(var, varAccessToVar(varAccess), location));
		}
		write(new IRBinary(var, IRBinary.Op.Add, var, pointerOffset, location));
	}

	private void writeBinary(IRVar var, ExprBinary binary) {
		switch (binary.op()) {
		case Assign -> {
			final IRVar binaryVar = writeAssign(binary);
			write(new IRMove(var, binaryVar, binary.location()));
		}
		case Add -> writeBinary(IRBinary.Op.Add, var, binary);
		case Sub -> writeBinary(IRBinary.Op.Sub, var, binary);
		case Multiply -> writeBinary(IRBinary.Op.Mul, var, binary);
		case Divide -> writeBinary(IRBinary.Op.Div, var, binary);
		case Mod -> writeBinary(IRBinary.Op.Mod, var, binary);

		case And -> writeBinary(IRBinary.Op.And, var, binary);
		case Or -> writeBinary(IRBinary.Op.Or, var, binary);
		case Xor -> writeBinary(IRBinary.Op.Xor, var, binary);

		case ShiftLeft -> writeBinary(IRBinary.Op.ShiftLeft, var, binary);
		case ShiftRight -> writeBinary(IRBinary.Op.ShiftRight, var, binary);

		case AndLog -> {
			final int labelIndex = nextLabelIndex();
			final String secondLabel = "@and_2nd_" + labelIndex;
			final String nextLabel = "@and_next_" + labelIndex;
			writeComment("logic and", binary.location());
			writeExpression(var, binary.left());
			write(new IRBranch(var, false, nextLabel,
			                   secondLabel));
			writeExpression(var, binary.right());
			writeLabel(nextLabel);
		}

		case OrLog -> {
			final int labelIndex = nextLabelIndex();
			final String secondLabel = "@or_2nd_" + labelIndex;
			final String nextLabel = "@or_next_" + labelIndex;
			writeComment("logic or", binary.location());
			writeExpression(var, binary.left());
			write(new IRBranch(var, true, nextLabel,
			                   secondLabel));
			writeExpression(var, binary.right());
			writeLabel(nextLabel);
		}

		case Lt -> writeBinary(IRBinary.Op.Lt, var, binary);
		case LtEq -> writeBinary(IRBinary.Op.LtEq, var, binary);
		case Equals -> writeBinary(IRBinary.Op.Equals, var, binary);
		case NotEquals -> writeBinary(IRBinary.Op.NotEquals, var, binary);
		case GtEq -> writeBinary(IRBinary.Op.GtEq, var, binary);
		case Gt -> writeBinary(IRBinary.Op.Gt, var, binary);
		default -> throw new UnsupportedOperationException(String.valueOf(binary));
		}
	}

	private void writeBinary(IRBinary.Op op, IRVar var, ExprBinary binary) {
		final IRVar left = writeExpression(binary.left());
		final IRVar right = writeExpression(binary.right());
		write(new IRBinary(var, op, left, right, binary.location()));
	}

	private void writeUnary(IRVar var, ExprUnary unary) {
		switch (unary.op()) {
		case AddrOf -> writeAddrOf(var, unary.expression(), unary.location());
		case Deref -> writeDeref(var, unary);
		case Com -> writeUnary(IRUnary.Op.Not, var, unary);
		case Neg -> writeUnary(IRUnary.Op.Neg, var, unary);
		case NotLog -> writeUnary(IRUnary.Op.NotLog, var, unary);
		default -> throw new UnsupportedOperationException(String.valueOf(unary));
		}
	}

	private void writeAddrOf(IRVar var, Expression expression, Location location) {
		switch (expression) {
		case ExprVarAccess access -> write(new IRAddrOf(var, varAccessToVar(access), location));
		case ExprArrayAccess access -> arrayAddr(var, access, location);
		case ExprMemberAccess access -> writeMemberAddress(var, access);
		default -> throw new UnsupportedOperationException(String.valueOf(expression));
		}
	}

	private void writeDeref(IRVar var, ExprUnary unary) {
		final IRVar pointer = writeExpression(unary.expression());
		write(new IRMemLoad(var, pointer, unary.location()));
	}

	private void writeUnary(IRUnary.Op op, IRVar var, ExprUnary unary) {
		final IRVar value = writeExpression(unary.expression());
		write(new IRUnary(op, var, value));
	}

	private void writeCall(@Nullable IRVar var, ExprFuncCall call) {
		final List<IRVar> args = new ArrayList<>();
		for (Expression expression : call.argExpressions()) {
			args.add(writeExpression(expression));
		}
		write(new IRCall(var, call.name(), args, call.location()));
	}

	@NotNull
	private IRVar varAccessToVar(ExprVarAccess access) {
		final int index = access.index();
		final VariableScope scope = access.scope();
		final boolean cantBeRegister = switch (scope) {
			case global -> globalVarsCantBeRegister.contains(index);
			case argument, function -> localVarsCantBeRegister.contains(index);
		};
		return new IRVar(access.varName(), index, scope, access.typeNotNull(), !cantBeRegister);
	}

	private IRVar createTempVar(@NotNull Type type) {
		final int index = localVars.size();
		final String name = "t." + index;
		final IRVar var = new IRVar(name, index, VariableScope.function, type, true);
		localVars.add(new IRVarDef(name, index, VariableScope.function, type, getTypeSize(type)));
		return var;
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
/*
		if (!(instruction instanceof IR2Label)) {
			System.out.print("\t");
		}
		System.out.println(instruction);
*/
		instructions.add(instruction);
	}

	private int nextLabelIndex() {
		labelIndex++;
		return labelIndex;
	}

	@NotNull
	private static String getStringLiteralName(int i) {
		return "string_" + i;
	}

	private record BreakContinueLabels(String breakLabel, String continueLabel) {
	}

	private record TypeInfo(int size, Map<String, Integer> memberToOffset) {
		public int get(String member) {
			return memberToOffset.get(member);
		}
	}
}
