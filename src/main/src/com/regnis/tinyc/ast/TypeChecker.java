package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class TypeChecker {

	private final Map<String, Var> nameToGlobalVar = new HashMap<>();
	private final Map<String, List<Func>> nameToFunctions = new HashMap<>();
	private final Map<String, TypeDef> typeDefs = new HashMap<>();
	private final List<Var> globalVars = new ArrayList<>();
	private final Map<String, StringLiteral> stringLiteralMap = new HashMap<>();
	private final List<StringLiteral> stringLiterals = new ArrayList<>();
	private final Type pointerIntType;

	private List<Statement> statements = List.of();
	@Nullable private Type expectedReturnType;
	@Nullable private LocalVars localVars;

	public TypeChecker(@NotNull Type pointerIntType) {
		Utils.assertTrue(pointerIntType.isInt());
		this.pointerIntType = pointerIntType;
	}

	@NotNull
	public Program check(@NotNull Program program) {
		final List<TypeDef> typeDefs = processTypeDefs(program.typeDefs());
		final List<Statement> globalVars = processStatements(program.globalVars());
		final List<Function> typedFunctions = determineFunctionDeclarationTypes(program.functions());
		final List<Function> functions = determineStatementTypes(typedFunctions);
		final List<Variable> globalVariables = toVariables(this.globalVars);
		return new Program(typeDefs, globalVars, functions, globalVariables, stringLiterals);
	}

	private List<TypeDef> processTypeDefs(List<TypeDef> rawTypeDefs) {
		// split into preProcessTypeDef and processTypeDef, so it is
		// possible to reference one type in another (without caring for the order)
		for (TypeDef typeDef : rawTypeDefs) {
			preProcessTypeDef(typeDef);
		}

		final List<TypeDef> typeDefs = new ArrayList<>();
		for (TypeDef typeDef : rawTypeDefs) {
			typeDefs.add(processTypeDef(typeDef));
		}
		return typeDefs;
	}

	private void preProcessTypeDef(TypeDef typeDef) {
		final String name = typeDef.name();
		if (Type.getDefaultType(name) != null) {
			throw new SyntaxException(Messages.cantRedefineDefaultTypes(), typeDef.location());
		}

		final TypeDef prevTypeDef = this.typeDefs.get(name);
		if (prevTypeDef != null) {
			throw new SyntaxException(Messages.typeAlreadyDefined(name, prevTypeDef.location()), typeDef.location());
		}

		final Type type = Type.struct(name);
		this.typeDefs.put(name, new TypeDef(name, type, typeDef.parts(), typeDef.location()));
	}

	private TypeDef processTypeDef(TypeDef rawTypeDef) {
		final String name = rawTypeDef.name();
		final Type type = Type.struct(name);

		final List<TypeDef.Part> typedParts = new ArrayList<>();
		final Map<String, Location> partNameToLocation = new HashMap<>();
		for (TypeDef.Part part : rawTypeDef.parts()) {
			final String partName = part.name();
			final Location partLocation = part.location();
			final Location prevLocation = partNameToLocation.put(partName, partLocation);
			if (prevLocation != null) {
				throw new SyntaxException(Messages.memberAlreadyDefinedAt(partName, prevLocation), partLocation);
			}
			final String typeName = part.typeName();
			final Type partType = getType(typeName, partLocation);
			typedParts.add(new TypeDef.Part(partName, typeName, partType, partLocation));
		}

		final TypeDef typeDef = new TypeDef(name, type, typedParts, rawTypeDef.location());
		this.typeDefs.put(name, typeDef);
		return typeDef;
	}

	@NotNull
	private List<Function> determineFunctionDeclarationTypes(List<Function> functions) {
		final List<Function> typedFunctions = new ArrayList<>();
		for (Function function : functions) {
			final Function typedFunction = determineDeclarationTypes(function);
			typedFunctions.add(typedFunction);
		}
		return typedFunctions;
	}

	@NotNull
	private Function determineDeclarationTypes(Function function) {
		final String name = function.name();
		final Location location = function.location();

		final Type returnType = getType(function.typeString(), location);
		final List<Function.Parameter> parameters = new ArrayList<>();
		final List<Type> parameterTypes = new ArrayList<>();
		for (Function.Parameter parameter : function.parameters()) {
			final Type argType = getType(parameter.typeString(), parameter.location());
			parameters.add(new Function.Parameter(parameter.typeString(), argType, parameter.name(), parameter.location()));
			parameterTypes.add(argType);
		}

		final List<Func> funcs = nameToFunctions.computeIfAbsent(name, k -> new ArrayList<>());
		for (Func func : funcs) {
			final List<Type> existingFuncParameterTypes = func.parameterTypes;
			if (existingFuncParameterTypes.equals(parameterTypes)) {
				throw new SyntaxException(Messages.functionAlreadDeclaredAt(name, func.location), location);
			}
		}

		funcs.add(new Func(returnType, parameterTypes, location));
		final String canonicalName = canonicalFunctionName(name, parameterTypes);
		return new Function(canonicalName, function.typeString(), returnType, parameters, List.of(), function.statements(), function.asmLines(), location);
	}

	private String canonicalFunctionName(String name, List<Type> types) {
		Utils.assertTrue(name.indexOf('@') < 0);
		final StringBuilder buffer = new StringBuilder();
		buffer.append(name);
		for (Type type : types) {
			buffer.append("@");
			while (type.isPointer()) {
				buffer.append("@");
				type = type.toType();
				assert type != null;
			}
			final String typeString = type.toString();
			Utils.assertTrue(typeString.indexOf('@') < 0);
			buffer.append(typeString);
		}
		return buffer.toString();
	}

	@NotNull
	private List<Function> determineStatementTypes(List<Function> typedFunctions) {
		final List<Function> functions = new ArrayList<>();
		for (Function typedFunction : typedFunctions) {
			final Function function = determineTypes(typedFunction);
			functions.add(function);
		}
		return functions;
	}

	@NotNull
	private Function determineTypes(Function function) {
		if (function.asmLines().size() > 0) {
			Utils.assertTrue(function.localVars().isEmpty());
			Utils.assertTrue(function.statements().isEmpty());
			return new Function(function.name(), function.typeString(), function.returnTypeNotNull(), function.parameters(), List.of(), List.of(), function.asmLines(), function.location());
		}

		expectedReturnType = function.returnType();
		localVars = new LocalVars();
		try {
			for (Function.Parameter arg : function.parameters()) {
				localVars.addArg(arg.name(), arg.typeNotNull(), arg.location());
			}

			final List<Statement> statements = processStatements(function.statements());
			if (expectedReturnType != Type.VOID) {
				if (!(Utils.getLastOrNull(statements) instanceof StmtReturn)) {
					throw new SyntaxException(Messages.functionMustReturnType(expectedReturnType), function.location());
				}
			}
			return Function.typedInstance(function.name(), function.typeString(), function.returnTypeNotNull(), function.parameters(), localVars.toList(), statements, List.of(), function.location());
		}
		finally {
			localVars = null;
			expectedReturnType = null;
		}
	}

	@NotNull
	private List<Statement> processStatements(@NotNull List<Statement> statements) {
		final List<Statement> prevStatements = this.statements;
		try {
			this.statements = new ArrayList<>();

			for (Statement statement : statements) {
				processStatement(statement);
			}

			return this.statements;
		}
		finally {
			this.statements = prevStatements;
		}
	}

	@NotNull
	private List<Statement> processStatementsWithLocalScope(@NotNull List<Statement> statements) {
		final LocalVars prevLocalVars = Objects.requireNonNull(this.localVars);
		this.localVars = new LocalVars(prevLocalVars);
		try {
			return processStatements(statements);
		}
		finally {
			this.localVars = prevLocalVars;
		}
	}

	private void add(Statement statement) {
		statements.add(statement);
	}

	private void processStatement(Statement statement) {
		switch (statement) {
		case StmtVarDeclaration declaration -> processVarDeclaration(declaration);
		case StmtArrayDeclaration declaration -> processArrayDeclaration(declaration);
		case StmtCompound compound -> processCompound(compound);
		case StmtIf ifStatement -> processIf(ifStatement);
		case StmtLoop forStatement -> processFor(forStatement);
		case StmtReturn stmt -> processReturn(stmt.expression(), stmt.location());
		case StmtExpr stmt -> add(new StmtExpr(processExpression(stmt.expression())));
		// nothing to do here
		case StmtBreakContinue breakContinue -> add(breakContinue);
		default -> throw new IllegalStateException("Unexpected value: " + statement);
		}
	}

	private void processVarDeclaration(StmtVarDeclaration declaration) {
		Expression expression = declaration.expression();
		if (expression != null) {
			expression = processExpression(expression);
		}

		final String varName = declaration.varName();
		final Location location = declaration.location();
		final Type type = getType(declaration.typeString(), location);
		final Var var = addVar(varName, type, 0, location);
		if (expression != null) {
			expression = simpleCast(type, expression, location);
			addAssignment(var, expression, location);
		}
	}

	private void addAssignment(Var var, Expression expression, Location location) {
		add(new StmtExpr(new ExprBinary(ExprBinary.Op.Assign,
		                                var.type,
		                                new ExprVarAccess(var.name, var.index, var.scope, var.type, var.isArray(), location),
		                                expression,
		                                location)));
	}

	private void processArrayDeclaration(StmtArrayDeclaration declaration) {
		Utils.assertTrue(declaration.size() > 0);
		final String varName = declaration.varName();
		final Location location = declaration.location();
		Type type = getType(declaration.typeString(), location);
		type = Type.pointer(type);
		addVar(varName, type, declaration.size(), location);
	}

	private void processCompound(StmtCompound compound) {
		final List<Statement> statements = processStatementsWithLocalScope(compound.statements());
		this.statements.addAll(statements);
	}

	private void processIf(StmtIf ifStmt) {
		final Expression condition = checkBooleanCondition(ifStmt.condition());
		final List<Statement> thenStatements = processStatementsWithLocalScope(ifStmt.thenStatements());
		final List<Statement> elseStatements = processStatementsWithLocalScope(ifStmt.elseStatements());
		add(new StmtIf(condition, thenStatements, elseStatements, ifStmt.location()));
	}

	private void processFor(StmtLoop forStmt) {
		final Expression condition = checkBooleanCondition(forStmt.condition());

		final List<Statement> iteration = processStatements(forStmt.iteration());

		final List<Statement> bodyStatements = processStatementsWithLocalScope(forStmt.bodyStatements());
		add(new StmtLoop(condition, bodyStatements, iteration, forStmt.location()));
	}

	@NotNull
	private Expression checkBooleanCondition(Expression expression) {
		final Expression condition = processExpression(expression);
		if (condition.typeNotNull() != Type.BOOL) {
			throw new SyntaxException(Messages.expectedBoolExpression(), expression.location());
		}
		return condition;
	}

	private void processReturn(@Nullable Expression expression, Location location) {
		final Type expectedReturnType = Objects.requireNonNull(this.expectedReturnType);
		if (expression == null) {
			if (expectedReturnType != Type.VOID) {
				throw new SyntaxException(Messages.returnExpectedExpressionOfType(expectedReturnType), location);
			}
		}
		else {
			if (expectedReturnType == Type.VOID) {
				throw new SyntaxException(Messages.cantReturnAnythingFromVoidFunction(), location);
			}
			expression = processExpression(expression);
			expression = simpleCast(expectedReturnType, expression, location);
		}
		add(new StmtReturn(expression, location));
	}

	@NotNull
	private Expression simpleCast(Type expectedType, Expression expression, Location location) {
		final Type type = expression.typeNotNull();
		if (expectedType.equals(type)) {
			return expression;
		}

		if (expression instanceof ExprIntLiteral literal) {
			final int value = literal.value();
			if (value < expectedType.min() || value > expectedType.max()) {
				throw new SyntaxException(Messages.integerLiteralDoesNotFit(value, expectedType), literal.location());
			}
			return new ExprIntLiteral(value, expectedType, literal.location());
		}

		if (expectedType.isInt()) {
			throw new SyntaxException(Messages.needExplicitCast(type, expectedType), expression.location());
		}

		throw new SyntaxException(Messages.cantCastFromTo(type, expectedType), location);
	}

	@NotNull
	private Expression autoCastTo(Type type, Expression expression, Location location) {
		final Type expressionType = expression.typeNotNull();
		if (type.equals(expressionType)) {
			return expression;
		}

		if (type.isPointer() != expressionType.isPointer()) {
			throw new SyntaxException(Messages.cantCastFromTo(expressionType, type), location);
		}

		if (expression instanceof ExprIntLiteral literal) {
			final int value = literal.value();
			if (value < type.min() || value > type.max()) {
				throw new SyntaxException(Messages.integerLiteralDoesNotFit(value, type), literal.location());
			}
			return new ExprIntLiteral(value, type, literal.location());
		}

		final int expectedSize = getTypeSize(type);
		final int actualSize = getTypeSize(expressionType);
		if (actualSize >= expectedSize) {
			throw new SyntaxException(Messages.needExplicitCast(expressionType, type), location);
		}

		return ExprCast.autocast(expression, type);
	}

	private int getTypeSize(Type type) {
		return Type.getSize(type, pointerIntType);
	}

	@NotNull
	private Expression processExpression(Expression expression) {
		return switch (expression) {
			case ExprIntLiteral ignored -> expression;
			case ExprBoolLiteral ignored -> expression;
			case ExprStringLiteral literal -> processStringLiteral(literal);
			case ExprCast cast -> processCast(cast);
			case ExprVarAccess var -> processVarAccess(var);
			case ExprArrayAccess access -> processArrayAccess(access);
			case ExprMemberAccess access -> processMemberAccess(access);
			case ExprFuncCall call -> processFuncCall(call.name(), call.argExpressions(), call.location());
			case ExprBinary binary -> {
				if (binary.op() == ExprBinary.Op.Assign) {
					yield processAssign(binary.left(), binary.right(), binary.location());
				}
				final Expression left = processExpression(binary.left());
				final Expression right = processExpression(binary.right());
				yield processBinary(binary.op(), left, right, binary.location());
			}
			case ExprUnary unary -> processUnary(unary);
			default -> throw new IllegalStateException("Unexpected expression: " + expression);
		};
	}

	@NotNull
	private ExprStringLiteral processStringLiteral(ExprStringLiteral literal) {
		final String text = literal.text();
		StringLiteral stringLiteral = stringLiteralMap.get(text);
		if (stringLiteral == null) {
			stringLiteral = new StringLiteral(text, stringLiterals.size());
			stringLiteralMap.put(text, stringLiteral);
			stringLiterals.add(stringLiteral);
		}
		return new ExprStringLiteral(text, stringLiteral.index(), literal.location());
	}

	private Expression processCast(ExprCast cast) {
		final String typeString = cast.typeString();
		final Location location = cast.location();
		final Type type = getType(typeString, location);
		final Expression expression = processExpression(cast.expression());
		final Type expressionType = expression.typeNotNull();
		if (type.isPointer() != expressionType.isPointer()) {
			throw new SyntaxException(Messages.cantCastFromTo(expressionType, type), location);
		}

		return new ExprCast(typeString, expression, type, location);
	}

	@NotNull
	private ExprVarAccess processVarAccess(ExprVarAccess access) {
		final String name = access.varName();
		final Location location = access.location();
		final Var var = getVar(name, location);
		Utils.assertTrue(Objects.equals(var.name, name));
		return new ExprVarAccess(name, var.index, var.scope, var.type, var.isArray(), location);
	}

	@NotNull
	private ExprArrayAccess processArrayAccess(ExprArrayAccess access) {
		final ExprVarAccess varAccess = processVarAccess(access.varAccess());
		final Type type = varAccess.typeNotNull();
		final Type resolvedType = type.toType();
		if (resolvedType == null) {
			throw new SyntaxException(Messages.expectedPointerButGot(type), varAccess.location());
		}
		final Expression index = processArrayIndex(access.index());
		return new ExprArrayAccess(varAccess, resolvedType, index);
	}

	@NotNull
	private ExprMemberAccess processMemberAccess(ExprMemberAccess access) {
		final Expression expression = processExpression(access.expression());
		Type type = expression.typeNotNull();
		final String member = access.member();
		type = getMemberType(type, member, access.location());
		return new ExprMemberAccess(expression, member, type, access.location());
	}

	@NotNull
	private Type getMemberType(Type type, String member, Location location) {
		String name = type.name();
		if (isPointer(name)) {
			name = stripPointer(name);
		}
		final TypeDef typeDef = typeDefs.get(name);
		if (typeDef == null) {
			throw new SyntaxException(Messages.expectedStruct(name), location);
		}

		for (TypeDef.Part part : typeDef.parts()) {
			if (part.name().equals(member)) {
				return part.typeNotNull();
			}
		}
		throw new SyntaxException(Messages.structDoesNotHaveMember(name, member), location);
	}

	@NotNull
	private Expression processArrayIndex(Expression arrayIndex) {
		final Location location = arrayIndex.location();
		Expression expression = processExpression(arrayIndex);
		if (!expression.typeNotNull().isInt()) {
			throw new SyntaxException(Messages.arrayIndexMustBeInt(), location);
		}
		expression = autoCastTo(pointerIntType, expression, location);
		return expression;
	}

	@NotNull
	private Expression processUnary(ExprUnary unary) {
		final ExprUnary.Op op = unary.op();
		final Location location = unary.location();
		final Expression expression = processExpression(unary.expression());
		final Type expressionType = expression.typeNotNull();
		Type type = expressionType;
		switch (op) {
		case AddrOf -> {
			if (expression instanceof ExprVarAccess access) {
				final String name = access.varName();
				final Var var = getVar(name, location);
				if (var.isArray()) {
					throw new SyntaxException(Messages.addressOfArray(), location);
				}
				var.setUsesAddrOf();
			}
			else if (!(expression instanceof ExprArrayAccess)
			         && !(expression instanceof ExprMemberAccess)) {
				throw new SyntaxException(Messages.expectedAddressableObject(), expression.location());
			}
			type = Type.pointer(type);
		}
		case Deref -> {
			type = type.toType();
			if (type == null) {
				throw new SyntaxException(Messages.expectedPointerButGot(expressionType), location);
			}
		}
		case Neg -> {
			if (!type.isInt()) {
				throw new SyntaxException(Messages.expectedIntegerExpression(), expression.location());
			}
			if (expression instanceof ExprIntLiteral literal) {
				return ExprIntLiteral.autoType(-literal.value(), location);
			}
		}
		case Com -> {
			if (!type.isInt()) {
				throw new SyntaxException(Messages.expectedIntegerExpression(), location);
			}
		}
		case NotLog -> {
			if (type != Type.BOOL) {
				throw new SyntaxException(Messages.expectedBoolExpression(), location);
			}
		}
		default -> throw new UnsupportedOperationException("Unsupported operator " + op);
		}
		return new ExprUnary(op, expression, type, location);
	}

	@NotNull
	private ExprFuncCall processFuncCall(String name, List<Expression> argExpressions, Location location) {
		final List<Expression> expressions = new ArrayList<>();
		final List<Type> argTypes = new ArrayList<>();
		for (Expression argExpr : argExpressions) {
			final Expression expression = processExpression(argExpr);
			expressions.add(expression);
			argTypes.add(expression.typeNotNull());
		}

		final List<Func> funcs = nameToFunctions.get(name);
		List<List<Type>> alternatives = List.of();
		if (funcs == null) {
			throw new SyntaxException(Messages.undeclaredFunction(name, argTypes, alternatives), location);
		}

		if (funcs.size() == 1) {
			final Func func = funcs.getFirst();
			final List<Type> parameterTypes = func.parameterTypes();
			if (expressions.size() == parameterTypes.size()) {
				for (int i = 0; i < expressions.size(); i++) {
					final Type type = parameterTypes.get(i);
					final Expression expression = expressions.get(i);
					if (expression instanceof ExprCast cast) {
						final Type castType = cast.typeNotNull();
						if (castType.equals(expression.typeNotNull())) {
							// todo should later become a warning
							throw new SyntaxException(Messages.redundantCast(castType), expression.location());
						}
					}
					final Expression castExpression = simpleCast(type, expression, expression.location());
					expressions.set(i, castExpression);
				}
				final String canonicalName = canonicalFunctionName(name, func.parameterTypes);
				return new ExprFuncCall(canonicalName, func.returnType(), expressions, location);
			}
		}

		alternatives = new ArrayList<>();
		for (Func func : funcs) {
			if (func.parameterTypes.equals(argTypes)) {
				Utils.assertTrue(func.parameterTypes().size() == argExpressions.size());
				final String canonicalName = canonicalFunctionName(name, argTypes);
				return new ExprFuncCall(canonicalName, func.returnType(), expressions, location);
			}

			alternatives.add(func.parameterTypes);
		}

		throw new SyntaxException(Messages.undeclaredFunction(name, argTypes, alternatives), location);
	}

	@NotNull
	private Expression processBinary(ExprBinary.Op op, Expression left, Expression right, Location location) {
		final Type leftType = left.typeNotNull();
		final Type rightType = right.typeNotNull();
		final Location rightLocation = right.location();

		if (leftType.isPointer() || rightType.isPointer()) {
			if (op == ExprBinary.Op.Equals
			    || op == ExprBinary.Op.NotEquals) {
				if (leftType.isPointer() && rightType.isPointer()) {
					return new ExprBinary(op, Type.BOOL, left, right, location);
				}
			}
			else if (op == ExprBinary.Op.Add
			         || op == ExprBinary.Op.Sub) {
				final Type toType = leftType.toType();
				if (toType != null && rightType.isInt()) {
					final int size = getTypeSize(toType);
					left = ExprCast.autocast(left, pointerIntType);
					right = autoCastTo(pointerIntType, right, rightLocation);
					if (size > 1) {
						right = new ExprBinary(ExprBinary.Op.Multiply, pointerIntType, right,
						                       autoCastTo(pointerIntType, ExprIntLiteral.autoType(size, rightLocation),
						                                  rightLocation),
						                       rightLocation);
					}
					return ExprCast.autocast(new ExprBinary(op, pointerIntType, left, right, location),
					                         leftType);
				}
			}
		}

		if (op.kind == ExprBinary.OpKind.Logic) {
			if (leftType != Type.BOOL) {
				throw new SyntaxException(Messages.expectedBoolExpression(), left.location());
			}
			if (rightType != Type.BOOL) {
				throw new SyntaxException(Messages.expectedBoolExpression(), right.location());
			}
			return new ExprBinary(op, Type.BOOL, left, right, location);
		}

		if (!leftType.isInt() || !rightType.isInt()) {
			throw new SyntaxException(Messages.operationNotSupportedForTypes(op, leftType, rightType), location);
		}

		final Type type;
		switch (op.kind) {
		case Arithmetic -> {
			type = leftType;
			if (!Objects.equals(leftType, rightType)) {
				if (right instanceof ExprIntLiteral) {
					right = simpleCast(type, right, right.location());
				}
				else {
					throw new SyntaxException(Messages.needExplicitCast(type, rightType), location);
				}
			}
		}
		case Relational -> {
			type = Type.BOOL;
			if (!Objects.equals(leftType, rightType)) {
				if (right instanceof ExprIntLiteral) {
					right = simpleCast(leftType, right, right.location());
				}
				else if (left instanceof ExprIntLiteral) {
					left = simpleCast(rightType, left, left.location());
				}
				else {
					throw new SyntaxException(Messages.needExplicitCast(leftType, rightType), location);
				}
			}
		}
		default -> throw new UnsupportedOperationException(String.valueOf(op.kind));
		}
		return new ExprBinary(op, type, left, right, location);
	}

	private Expression processAssign(Expression left, Expression right, Location location) {
		left = processLValue(left);
		right = processExpression(right);
		final Type leftType = left.typeNotNull();
		final Type rightType = right.typeNotNull();
		if (!Objects.equals(leftType, rightType)) {
			right = autoCastTo(leftType, right, location);
		}
		return new ExprBinary(ExprBinary.Op.Assign, leftType, left, right, location);
	}

	private Expression processLValue(Expression expression) {
		return switch (expression) {
			case ExprVarAccess varRead -> processLValueVar(varRead);
			case ExprArrayAccess arrayAccess -> processArrayAccess(arrayAccess);
			case ExprMemberAccess memberAccess -> processMemberAccess(memberAccess);
			case ExprUnary deref -> processUnary(deref);
			default -> throw new SyntaxException(Messages.expectedLValue(), expression.location());
		};
	}

	@NotNull
	private ExprVarAccess processLValueVar(ExprVarAccess access) {
		final String name = access.varName();
		final Location location = access.location();
		final Var var = getVar(name, location);
		if (var.isArray()) {
			throw new SyntaxException(Messages.arraysAreImmutable(), location);
		}
		Utils.assertTrue(Objects.equals(var.name, name));
		return new ExprVarAccess(name, var.index, var.scope, var.type, false, location);
	}

	@NotNull
	private Var addVar(@Nullable String varName, Type type, int arraySize, Location location) {
		if (varName != null) {
			final Var existingVar = nameToGlobalVar.get(varName);
			if (existingVar != null) {
				throw new SyntaxException(Messages.variableAlreadyDeclaredAt(varName, existingVar.location()), location);
			}
		}
		if (localVars == null) {
			return addGlobalVariable(varName, type, arraySize, location);
		}

		return localVars.add(varName, type, arraySize, location);
	}

	@NotNull
	private Var addGlobalVariable(@Nullable String varName, Type type, int arraySize, Location location) {
		varName = getTempVarName(varName, globalVars);
		final Var var = new Var(varName, globalVars.size(), VariableScope.global, type, arraySize, location);
		nameToGlobalVar.put(varName, var);
		globalVars.add(var);
		return var;
	}

	@NotNull
	private Var getVar(String name, Location location) {
		if (localVars != null) {
			final Var localVar = localVars.get(name);
			if (localVar != null) {
				return localVar;
			}
		}
		final Var globalVar = nameToGlobalVar.get(name);
		if (globalVar == null) {
			throw new SyntaxException(Messages.undeclaredVariable(name), location);
		}
		return globalVar;
	}

	@NotNull
	private Type getType(@NotNull String typeString, @NotNull Location location) {
		if (isPointer(typeString)) {
			return Type.pointer(getType(stripPointer(typeString), location));
		}

		final Type type = Type.getDefaultType(typeString);
		if (type != null) {
			return type;
		}

		final TypeDef typeDef = typeDefs.get(typeString);
		if (typeDef != null) {
			return typeDef.typeNotNull();
		}

		throw new SyntaxException(Messages.unknownType(typeString), location);
	}

	private boolean isPointer(@NotNull String typeString) {
		return typeString.endsWith("*");
	}

	@NotNull
	private String stripPointer(@NotNull String typeString) {
		return typeString.substring(0, typeString.length() - 1);
	}

	@NotNull
	private static String getTempVarName(@Nullable String varName, List<Var> globalVars) {
		if (varName == null) {
			varName = "$." + globalVars.size();
		}
		return varName;
	}

	private static List<Variable> toVariables(List<Var> vars) {
		final List<Variable> globalVariables = new ArrayList<>();
		for (Var var : vars) {
			globalVariables.add(new Variable(var.name, var.index, var.scope, var.type, var.arraySize, var.canBeRegister, var.location));
		}
		return globalVariables;
	}

	public record Func(@NotNull Type returnType, @NotNull List<Type> parameterTypes, @NotNull Location location) {
		public Func(Type returnType, List<Type> parameterTypes, Location location) {
			this.returnType = returnType;
			this.parameterTypes = List.copyOf(parameterTypes);
			this.location = location;
		}
	}

	private static final class Var {
		@NotNull private final String name;
		private final int index;
		@NotNull private final VariableScope scope;
		@NotNull private final Type type;
		private final int arraySize;
		@NotNull private final Location location;

		private boolean canBeRegister;

		private Var(@NotNull String name, int index, @NotNull VariableScope scope, @NotNull Type type, int arraySize, @NotNull Location location) {
			this.name = name;
			this.index = index;
			this.scope = scope;
			this.type = type;
			this.arraySize = arraySize;
			this.location = location;
			canBeRegister = arraySize == 0;
		}

		@NotNull
		public Location location() {
			return location;
		}

		public boolean isArray() {
			return arraySize > 0;
		}

		public void setUsesAddrOf() {
			canBeRegister = false;
		}
	}

	private static final class LocalVars {

		private final Map<String, Var> nameToVariable = new HashMap<>();
		private final List<Var> vars;
		@Nullable private final LocalVars parent;

		public LocalVars() {
			this.parent = null;
			vars = new ArrayList<>();
		}

		public LocalVars(@NotNull LocalVars parent) {
			this.parent = parent;
			vars = parent.vars;
		}

		@NotNull
		public Var add(@Nullable String varName, Type type, int arraySize, Location location) {
			varName = getTempVarName(varName, vars);
			return add(new Var(varName, vars.size(), VariableScope.function, type, arraySize, location));
		}

		public void addArg(@NotNull String name, @NotNull Type type, @NotNull Location location) {
			if (nameToVariable.containsKey(name)) {
				throw new SyntaxException(Messages.duplicateArgumentName(name), location);
			}
			add(new Var(name, vars.size(), VariableScope.parameter, type, 0, location));
		}

		@Nullable
		public Var get(String name) {
			final Var variable = nameToVariable.get(name);
			if (variable == null && parent != null) {
				return parent.get(name);
			}
			return variable;
		}

		public List<Variable> toList() {
			return toVariables(vars);
		}

		private Var add(@NotNull Var var) {
			nameToVariable.put(var.name, var);
			vars.add(var);
			return var;
		}
	}
}
