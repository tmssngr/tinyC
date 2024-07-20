package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class TypeChecker {

	private final Map<String, Symbol> globalSymbols = new HashMap<>();
	private final List<Variable> globalVariables = new ArrayList<>();
	private final Map<String, StringLiteral> stringLiteralMap = new HashMap<>();
	private final List<StringLiteral> stringLiterals = new ArrayList<>();

	private final Type pointerIntType;

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
		final List<StmtDeclaration> globalVars = processGlobalVars(program.globalVars());
		final List<Function> typedFunctions = determineFunctionDeclarationTypes(program.functions());
		final List<Function> functions = determineStatementTypes(typedFunctions);
		return new Program(globalVars, functions, globalVariables, stringLiterals);
	}

	@NotNull
	private List<StmtDeclaration> processGlobalVars(List<StmtDeclaration> globalVars) {
		final List<StmtDeclaration> declarations = new ArrayList<>();
		for (StmtDeclaration declaration : globalVars) {
			final StmtDeclaration newDeclaration = processGlobalVar(declaration);
			declarations.add(newDeclaration);
		}
		return declarations;
	}

	@NotNull
	private StmtDeclaration processGlobalVar(StmtDeclaration declaration) {
		return switch (declaration) {
			case StmtVarDeclaration var -> processVarDeclaration(var);
			case StmtArrayDeclaration array -> processArrayDeclaration(array);
			default -> throw new UnsupportedOperationException();
		};
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
		return new Function(name, function.typeString(), returnType, args, List.of(), function.statement(), location);
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
			final Statement statement = processStatement(function.statement());
			final StmtCompound compound = statement instanceof StmtCompound c ? c : new StmtCompound(List.of(statement));
			if (expectedReturnType != Type.VOID) {
				if (!(Utils.getLastOrNull(compound.statements()) instanceof StmtReturn)) {
					throw new SyntaxException(Messages.functionMustReturnType(expectedReturnType), function.location());
				}
			}
			return new Function(function.name(), function.typeString(), function.returnType(), function.args(), localVariables.getList(), statement, function.location());
		}
		finally {
			localVariables = null;
			expectedReturnType = null;
		}
	}

	@NotNull
	private Statement processStatement(Statement statement) {
		return switch (statement) {
			case StmtVarDeclaration declaration -> processVarDeclaration(declaration);
			case StmtCompound compound -> processCompound(compound);
			case StmtIf ifStatement -> processIf(ifStatement);
			case StmtLoop forStatement -> processFor(forStatement);
			case StmtReturn stmt -> processReturn(stmt.expression(), stmt.location());
			case StmtExpr stmt -> new StmtExpr(processExpression(stmt.expression()));
			default -> throw new IllegalStateException("Unexpected value: " + statement);
		};
	}

	@NotNull
	private StmtVarDeclaration processVarDeclaration(StmtVarDeclaration declaration) {
		final String varName = declaration.varName();
		final Location location = declaration.location();
		Expression expression = processExpression(declaration.expression());
		final Type type = getType(declaration.typeString(), location);
		expression = autoCastTo(type, expression, location);

		final Variable variable = addVariable(varName, type, 0, location);
		return new StmtVarDeclaration(declaration.typeString(), varName, variable.index(), variable.scope(), type, expression, location);
	}

	@NotNull
	private StmtArrayDeclaration processArrayDeclaration(StmtArrayDeclaration declaration) {
		Utils.assertTrue(declaration.size() > 0);
		final String varName = declaration.varName();
		final Location location = declaration.location();
		Type type = getType(declaration.typeString(), location);
		type = Type.pointer(type);
		final Variable variable = addVariable(varName, type, declaration.size(), location);
		return new StmtArrayDeclaration(declaration.typeString(), varName, variable.index(), variable.scope(), type, declaration.size(), location);
	}

	@NotNull
	private StmtCompound processCompound(StmtCompound compound) {
		final LocalVariables prevLocalVariables = Objects.requireNonNull(localVariables);
		localVariables = new LocalVariables(prevLocalVariables);
		try {
			final List<Statement> statements = processStatements(compound.statements());
			return new StmtCompound(statements);
		}
		finally {
			localVariables = prevLocalVariables;
		}
	}

	@NotNull
	private StmtIf processIf(StmtIf ifStmt) {
		final Expression condition = checkBooleanCondition(ifStmt.condition(), ifStmt.location());
		final Statement thenStatement = processStatement(ifStmt.thenStatement());
		Statement elseStatement = ifStmt.elseStatement();
		if (elseStatement != null) {
			elseStatement = processStatement(elseStatement);
		}
		return new StmtIf(condition, thenStatement, elseStatement, ifStmt.location());
	}

	@NotNull
	private StmtLoop processFor(StmtLoop forStmt) {
		final Expression condition = checkBooleanCondition(forStmt.condition(), forStmt.location());

		final List<Statement> iteration = processStatements(forStmt.iteration());

		final Statement bodyStatement = processStatement(forStmt.bodyStatement());
		return new StmtLoop(condition, bodyStatement, iteration, forStmt.location());
	}

	@NotNull
	private Expression checkBooleanCondition(Expression expression, Location location) {
		final Expression condition = processExpression(expression);
		if (condition.typeNotNull() != Type.BOOL) {
			throw new SyntaxException(Messages.expectedBoolExpression(), location);
		}
		return condition;
	}

	@NotNull
	private List<Statement> processStatements(@NotNull List<Statement> statements) {
		final List<Statement> newStatements = new ArrayList<>();
		for (Statement statement : statements) {
			final Statement newStatement = processStatement(statement);
			newStatements.add(newStatement);
		}
		return newStatements;
	}

	@NotNull
	private StmtReturn processReturn(@Nullable Expression expression, Location location) {
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
		return new StmtReturn(expression, location);
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
			case ExprVarAccess var -> processVarRead(var);
			case ExprFuncCall call -> processFuncCall(call.name(), call.argExpressions(), call.location());
			case ExprBinary binary -> {
				if (binary.op() == ExprBinary.Op.Assign) {
					yield processAssign(binary.left(), binary.right(), binary.location());
				}
				final Expression left = processExpression(binary.left());
				final Expression right = processExpression(binary.right());
				yield processBinary(binary.op(), left, right, binary.location());
			}
			case ExprAddrOf addrOf -> processAddrOf(addrOf);
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
	private Expression processVarRead(ExprVarAccess var) {
		final String name = var.varName();
		final Location location = var.location();
		final Expression arrayIndex = var.arrayIndex();
		final Variable variable = getVariable(name, location);
		Type type = variable.type();
		if (arrayIndex != null) {
			type = type.toType();
			if (type == null) {
				throw new SyntaxException(Messages.expectedPointerButGot(variable.type()), location);
			}

			final Expression expression = processArrayIndex(arrayIndex, location);
			return new ExprVarAccess(name, variable.index(), variable.scope(), type, expression, location);
		}
		return new ExprVarAccess(name, variable.index(), variable.scope(), type, null, location);
	}

	@NotNull
	private Expression processArrayIndex(Expression arrayIndex, Location location) {
		Expression expression = processExpression(arrayIndex);
		if (!expression.typeNotNull().isInt()) {
			throw new SyntaxException(Messages.arrayIndexMustBeInt(), location);
		}
		expression = autoCastTo(pointerIntType, expression, location);
		return expression;
	}

	@NotNull
	private Expression processAddrOf(ExprAddrOf addrOf) {
		final String name = addrOf.varName();
		final Location location = addrOf.location();
		final Variable variable = getVariable(name, location);
		Expression arrayIndex = addrOf.arrayIndex();
		if (arrayIndex != null) {
			arrayIndex = processArrayIndex(arrayIndex, location);
			return new ExprAddrOf(name, variable.index(), variable.scope(), variable.type(), arrayIndex, location);
		}
		return new ExprAddrOf(name, variable.index(), variable.scope(), Type.pointer(variable.type()), null, location);
	}

	@NotNull
	private Expression processUnary(ExprUnary unary) {
		final ExprUnary.Op op = unary.op();
		final Location location = unary.location();
		Expression expression = processExpression(unary.expression());
		final Type expressionType = expression.typeNotNull();
		Type type = expressionType;
		switch (op) {
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
					left = ExprCast.autocast(left, rightType);
					type = rightType;
				}
				else {
					right = ExprCast.autocast(right, leftType);
				}
			}
		}
		case Relational -> {
			type = Type.BOOL;
			if (!Objects.equals(leftType, rightType)) {
				if (leftType == Type.U8) {
					left = ExprCast.autocast(left, rightType);
				}
				else {
					right = ExprCast.autocast(right, leftType);
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
			case ExprUnary deref -> processUnary(deref);
			default -> throw new SyntaxException(Messages.expectedLValue(), expression.location());
		};
	}

	@NotNull
	private ExprVarAccess processLValueVar(ExprVarAccess var) {
		final String name = var.varName();
		final Location location = var.location();
		final Variable variable = getVariable(name, location);
		final Expression arrayIndex = var.arrayIndex();
		if (arrayIndex != null) {
			if (!variable.isArray()) {
				throw new SyntaxException(Messages.arraysAreImmutable(), location);
			}
			final Expression expression = processArrayIndex(arrayIndex, location);
			final Type type = Objects.requireNonNull(variable.type().toType());
			return new ExprVarAccess(name, variable.index(), variable.scope(), type, expression, location);
		}

		if (variable.isArray()) {
			throw new SyntaxException(Messages.arraysAreImmutable(), location);
		}
		return new ExprVarAccess(name, variable.index(), variable.scope(), variable.type(), null, location);
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
	private Variable addVariable(String varName, Type type, int arraySize, Location location) {
		checkNoSymbolNamed(varName, location);
		if (localVariables == null) {
			return addGlobalVariable(varName, type, arraySize, location);
		}

		return localVariables.add(varName, type, arraySize, location);
	}

	@NotNull
	private Variable addGlobalVariable(String varName, Type type, int arraySize, Location location) {
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
	private Type getType(@NotNull String type, @NotNull Location location) {
		if (type.endsWith("*")) {
			return Type.pointer(getType(type.substring(0, type.length() - 1), location));
		}
		return switch (type) {
			case "void" -> Type.VOID;
			case "u8" -> Type.U8;
			case "i16" -> Type.I16;
			default -> throw new SyntaxException(Messages.unknownType(type), location);
		};
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
		public Variable add(String varName, Type type, int arraySize, Location location) {
			final Variable variable = new Variable(varName, vars.size(), VariableScope.function, type, arraySize, location);
			nameToVariable.put(varName, variable);
			vars.add(variable);
			return variable;
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
	}
}
