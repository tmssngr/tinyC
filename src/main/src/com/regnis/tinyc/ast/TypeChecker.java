package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class TypeChecker {

	private final Map<String, Symbol> globalSymbols = new HashMap<>();
	private final Map<String, TypeDef> typeDefs = new HashMap<>();
	private final List<Variable> globalVariables = new ArrayList<>();
	private final Map<String, StringLiteral> stringLiteralMap = new HashMap<>();
	private final List<StringLiteral> stringLiterals = new ArrayList<>();
	private final Type pointerIntType;

	private List<Statement> statements = List.of();
	@Nullable private Type expectedReturnType;
	@Nullable private LocalVariables localVariables;

	public TypeChecker(@NotNull Type pointerIntType) {
		Utils.assertTrue(pointerIntType.isInt());
		this.pointerIntType = pointerIntType;
		globalSymbols.put("printString", new Symbol.Func(Type.VOID, List.of(Type.pointer(Type.U8)), new Location(-1, -1)));
		globalSymbols.put("print", new Symbol.Func(Type.VOID, List.of(Type.I64), new Location(-1, -1)));
	}

	@NotNull
	public Program check(@NotNull Program program) {
		final List<TypeDef> typeDefs = processTypeDefs(program.typeDefs());
		final List<Statement> globalVars = processStatements(program.globalVars());
		final List<Function> typedFunctions = determineFunctionDeclarationTypes(program.functions());
		final List<Function> functions = determineStatementTypes(typedFunctions);
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
		checkNoSymbolNamed(name, location);

		final Type returnType = getType(function.typeString(), location);
		final List<Function.Arg> args = new ArrayList<>();
		final List<Type> argTypes = new ArrayList<>();
		for (Function.Arg arg : function.args()) {
			final Type argType = getType(arg.typeString(), arg.location());
			args.add(new Function.Arg(arg.typeString(), argType, arg.name(), arg.location()));
			argTypes.add(argType);
		}
		globalSymbols.put(name, new Symbol.Func(returnType, argTypes, location));
		return new Function(name, function.typeString(), returnType, args, List.of(), function.statements(), location);
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
		expectedReturnType = function.returnType();
		localVariables = new LocalVariables();
		try {
			for (Function.Arg arg : function.args()) {
				localVariables.addArg(arg.name(), arg.typeNotNull(), arg.location());
			}

			final List<Statement> statements = processStatements(function.statements());
			if (expectedReturnType != Type.VOID) {
				if (!(Utils.getLastOrNull(statements) instanceof StmtReturn)) {
					throw new SyntaxException(Messages.functionMustReturnType(expectedReturnType), function.location());
				}
			}
			return new Function(function.name(), function.typeString(), function.returnType(), function.args(), localVariables.getList(), statements, function.location());
		}
		finally {
			localVariables = null;
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
		final LocalVariables prevLocalVariables = Objects.requireNonNull(this.localVariables);
		this.localVariables = new LocalVariables(prevLocalVariables);
		try {
			return processStatements(statements);
		}
		finally {
			this.localVariables = prevLocalVariables;
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
		final String varName = declaration.varName();
		final Location location = declaration.location();
		final Type type = getType(declaration.typeString(), location);
		final Variable variable = addVariable(varName, type, 0, location);
		Expression expression = declaration.expression();
		if (expression != null) {
			expression = processExpression(expression);
			expression = autoCastTo(type, expression, location);
			addAssignment(variable, expression, location);
		}
	}

	private void addAssignment(Variable variable, Expression expression, Location location) {
		add(new StmtExpr(new ExprBinary(ExprBinary.Op.Assign,
		                                variable.type(),
		                                new ExprVarAccess(variable.name(), variable.index(), variable.scope(), variable.type(), location),
		                                expression,
		                                location)));
	}

	private void processArrayDeclaration(StmtArrayDeclaration declaration) {
		Utils.assertTrue(declaration.size() > 0);
		final String varName = declaration.varName();
		final Location location = declaration.location();
		Type type = getType(declaration.typeString(), location);
		type = Type.pointer(type);
		addVariable(varName, type, declaration.size(), location);
	}

	private void processCompound(StmtCompound compound) {
		final List<Statement> statements = processStatementsWithLocalScope(compound.statements());
		this.statements.addAll(statements);
	}

	private void processIf(StmtIf ifStmt) {
		final Expression condition = checkBooleanCondition(ifStmt.condition(), ifStmt.location());
		final List<Statement> thenStatements = processStatementsWithLocalScope(ifStmt.thenStatements());
		final List<Statement> elseStatements = processStatementsWithLocalScope(ifStmt.elseStatements());
		add(new StmtIf(condition, thenStatements, elseStatements, ifStmt.location()));
	}

	private void processFor(StmtLoop forStmt) {
		final Expression condition = checkBooleanCondition(forStmt.condition(), forStmt.location());

		final List<Statement> iteration = processStatements(forStmt.iteration());

		final List<Statement> bodyStatements = processStatementsWithLocalScope(forStmt.bodyStatements());
		add(new StmtLoop(condition, bodyStatements, iteration, forStmt.location()));
	}

	@NotNull
	private Expression checkBooleanCondition(Expression expression, Location location) {
		final Expression condition = processExpression(expression);
		if (condition.typeNotNull() != Type.BOOL) {
			throw new SyntaxException(Messages.expectedBoolExpression(), location);
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
			expression = autoCastTo(expectedReturnType, expression, location);
		}
		add(new StmtReturn(expression, location));
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

		final int expectedSize = getTypeSize(type);
		final int actualSize = getTypeSize(expressionType);
		if (actualSize >= expectedSize) {
			throw new SyntaxException(Messages.cantCastFromTo(expressionType, type), location);
		}

		if (expression instanceof ExprIntLiteral literal) {
			return new ExprIntLiteral(literal.value(), type, literal.location());
		}

		return ExprCast.autocast(expression, type);
	}

	private int getTypeSize(Type type) {
		if (type.isPointer()) {
			type = pointerIntType;
		}
		return Type.getSize(type);
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
	private Expression splitIntoTempVarAssignment(Expression expression) {
		if (expression instanceof ExprVarAccess varAccess && varAccess.scope() == VariableScope.function) {
			return expression;
		}

		final Variable variable = addVariable(null, expression.typeNotNull(), 0, expression.location());
		addAssignment(variable, expression, expression.location());
		return new ExprVarAccess(variable.name(), variable.index(), variable.scope(), variable.type(), variable.location());
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
	private ExprVarAccess processVarAccess(ExprVarAccess var) {
		final String name = var.varName();
		final Location location = var.location();
		final Variable variable = getVariable(name, location);
		final Type type = variable.type();
		return new ExprVarAccess(name, variable.index(), variable.scope(), type, location);
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
		Expression expression = processExpression(unary.expression());
		final Type expressionType = expression.typeNotNull();
		Type type = expressionType;
		switch (op) {
		case AddrOf -> {
			if (expression instanceof ExprVarAccess access) {
				final String name = access.varName();
				final Variable variable = getVariable(name, location);
				if (variable.isArray()) {
					throw new SyntaxException(Messages.addressOfArray(), location);
				}
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
				throw new SyntaxException(Messages.expectedIntegerType(type), location);
			}
			if (type == Type.U8) {
				type = Type.I16;
				expression = autoCastTo(type, expression, expression.location());
			}
		}
		case Com -> {
			if (!type.isInt()) {
				throw new SyntaxException(Messages.expectedIntegerType(type), location);
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
		final Symbol symbol = globalSymbols.get(name);
		if (!(symbol instanceof Symbol.Func function)) {
			throw new SyntaxException(Messages.undeclaredFunction(name), location);
		}
		if (function.argTypes().size() != argExpressions.size()) {
			throw new SyntaxException(Messages.functionNeedsXArgumentsButGotY(name, function.argTypes().size(), argExpressions.size()), location);
		}

		final List<Expression> expressions = new ArrayList<>();
		final Iterator<Type> methodArgIt = function.argTypes().iterator();
		final Iterator<Expression> argExprIt = argExpressions.iterator();
		while (methodArgIt.hasNext()) {
			final Type expectedType = methodArgIt.next();
			final Expression argExpr = argExprIt.next();
			Expression expression = processExpression(argExpr);
			expression = autoCastTo(expectedType, expression, location);
			expression = splitIntoTempVarAssignment(expression);
			expressions.add(expression);
		}
		return new ExprFuncCall(name, function.returnType(), expressions, location);
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
					return new ExprBinary(op, Type.U8, left, right, location);
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
						                       autoCastTo(pointerIntType, new ExprIntLiteral(size, rightLocation),
						                                  rightLocation),
						                       rightLocation);
					}
					return ExprCast.autocast(new ExprBinary(op, leftType, left, right, location),
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

		Type type;
		switch (op.kind) {
		case Arithmetic -> {
			type = leftType;
			if (!Objects.equals(leftType, rightType)) {
				if (leftType == Type.U8) {
					left = autoCastTo(rightType, left, left.location());
					type = rightType;
				}
				else {
					right = autoCastTo(leftType, right, right.location());
				}
			}
		}
		case Relational -> {
			type = Type.BOOL;
			if (!Objects.equals(leftType, rightType)) {
				if (leftType == Type.U8) {
					left = autoCastTo(rightType, left, left.location());
				}
				else {
					right = autoCastTo(leftType, right, right.location());
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
	private ExprVarAccess processLValueVar(ExprVarAccess var) {
		final String name = var.varName();
		final Location location = var.location();
		final Variable variable = getVariable(name, location);
		if (variable.isArray()) {
			throw new SyntaxException(Messages.arraysAreImmutable(), location);
		}
		return new ExprVarAccess(name, variable.index(), variable.scope(), variable.type(), location);
	}

	private void checkNoSymbolNamed(String name, Location location) {
		final Symbol existingSymbol = globalSymbols.get(name);
		if (existingSymbol instanceof Symbol.Func) {
			throw new SyntaxException(Messages.functionAlreadDeclaredAt(name, existingSymbol.location()), location);
		}
		if (existingSymbol instanceof Variable) {
			throw new SyntaxException(Messages.variableAlreadyDeclaredAt(name, existingSymbol.location()), location);
		}
		Utils.assertTrue(existingSymbol == null);
	}

	@NotNull
	private Variable addVariable(@Nullable String varName, Type type, int arraySize, Location location) {
		if (varName != null) {
			checkNoSymbolNamed(varName, location);
		}
		if (localVariables == null) {
			return addGlobalVariable(varName, type, arraySize, location);
		}

		return localVariables.add(varName, type, arraySize, location);
	}

	@NotNull
	private Variable addGlobalVariable(@Nullable String varName, Type type, int arraySize, Location location) {
		varName = getTempVarName(varName, globalVariables);
		final Variable variable = new Variable(varName, globalVariables.size(), VariableScope.global, type, arraySize, location);
		globalSymbols.put(varName, variable);
		globalVariables.add(variable);
		return variable;
	}

	@NotNull
	private Variable getVariable(String name, Location location) {
		if (localVariables != null) {
			final Variable localVariable = localVariables.get(name);
			if (localVariable != null) {
				return localVariable;
			}
		}
		final Symbol symbol = globalSymbols.get(name);
		if (!(symbol instanceof Variable variable)) {
			throw new SyntaxException(Messages.undeclaredVariable(name), location);
		}
		return variable;
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
	private static String getTempVarName(@Nullable String varName, List<Variable> globalVariables) {
		if (varName == null) {
			varName = "$." + globalVariables.size();
		}
		return varName;
	}

	private static final class LocalVariables {

		private final Map<String, Variable> nameToVariable = new HashMap<>();
		private final List<Variable> vars;
		@Nullable private final LocalVariables parent;

		public LocalVariables() {
			this.parent = null;
			vars = new ArrayList<>();
		}

		public LocalVariables(@NotNull LocalVariables parent) {
			this.parent = parent;
			vars = parent.vars;
		}

		@NotNull
		public Variable add(@Nullable String varName, Type type, int arraySize, Location location) {
			varName = getTempVarName(varName, vars);
			return add(new Variable(varName, vars.size(), VariableScope.function, type, arraySize, location));
		}

		public void addArg(@NotNull String name, @NotNull Type type, @NotNull Location location) {
			if (nameToVariable.containsKey(name)) {
				throw new SyntaxException(Messages.duplicateArgumentName(name), location);
			}
			add(new Variable(name, vars.size(), VariableScope.argument, type, 0, location));
		}

		@Nullable
		public Variable get(String name) {
			final Variable variable = nameToVariable.get(name);
			if (variable == null && parent != null) {
				return parent.get(name);
			}
			return variable;
		}

		public List<Variable> getList() {
			return Collections.unmodifiableList(vars);
		}

		private Variable add(@NotNull Variable variable) {
			nameToVariable.put(variable.name(), variable);
			vars.add(variable);
			return variable;
		}
	}
}
