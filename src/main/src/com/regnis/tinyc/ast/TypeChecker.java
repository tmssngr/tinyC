package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class TypeChecker {

	private final Map<String, Symbol> symbolMap = new HashMap<>();

	private final Type pointerIntType;

	@Nullable private Type expectedReturnType;

	public TypeChecker(@NotNull Type pointerIntType) {
		Utils.assertTrue(pointerIntType.isInt());
		this.pointerIntType = pointerIntType;
		symbolMap.put("print", new Symbol.Func(Type.VOID, List.of(Type.I16), new Location(-1, -1)));
	}

	@NotNull
	public Program check(@NotNull Program program) {
		final List<StmtDeclaration> globalVars = processGlobalVars(program.globalVars());
		final List<Function> typedFunctions = determineFunctionDeclarationTypes(program.functions());
		final List<Function> functions = determineStatementTypes(typedFunctions);
		return new Program(globalVars, functions);
	}

	@NotNull
	private List<StmtDeclaration> processGlobalVars(List<StmtDeclaration> globalVars) {
		final List<StmtDeclaration> declarations = new ArrayList<>();
		for (StmtDeclaration globalVar : globalVars) {
			final StmtDeclaration declaration = processDeclaration(globalVar);
			declarations.add(declaration);
		}
		return declarations;
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
		symbolMap.put(name, new Symbol.Func(returnType, argTypes, location));
		return new Function(name, function.typeString(), returnType, args, function.statement(), location);
	}

	@NotNull
	private List<Function> determineStatementTypes(List<Function> typedFunctions) {
		final List<Function> functions = new ArrayList<>();
		for (Function typedFunction : typedFunctions) {
			expectedReturnType = typedFunction.returnType();
			try {
				final Function function = determineTypes(typedFunction);
				functions.add(function);
			}
			finally {
				expectedReturnType = null;
			}
		}
		return functions;
	}

	@NotNull
	private Function determineTypes(Function function) {
		final Statement statement = processStatement(function.statement());
		final StmtCompound compound = statement instanceof StmtCompound c ? c : new StmtCompound(List.of(statement));
		if (expectedReturnType != Type.VOID) {
			if (!(Utils.getLastOrNull(compound.statements()) instanceof StmtReturn)) {
				throw new SyntaxException(Messages.functionMustReturnType(expectedReturnType), function.location());
			}
		}
		return new Function(function.name(), function.typeString(), function.returnType(), function.args(), statement, function.location());
	}

	@NotNull
	private Statement processStatement(Statement statement) {
		return switch (statement) {
			case StmtDeclaration declaration -> processDeclaration(declaration);
			case StmtCompound compound -> new StmtCompound(processStatements(compound.statements()));
			case StmtIf ifStatement -> processIf(ifStatement);
			case StmtWhile whileStatement -> processWhile(whileStatement);
			case StmtFor forStatement -> processFor(forStatement);
			case StmtReturn stmt -> processReturn(stmt.expression(), stmt.location());
			case StmtExpr stmt -> new StmtExpr(processExpression(stmt.expression()));
			default -> throw new IllegalStateException("Unexpected value: " + statement);
		};
	}

	@NotNull
	private StmtDeclaration processDeclaration(StmtDeclaration declaration) {
		final String varName = declaration.varName();
		final Location location = declaration.location();
		Expression expression = processExpression(declaration.expression());
		final Type type = getType(declaration.typeString(), location);
		expression = autoCastTo(type, expression, location);

		addVariable(varName, type, location);
		return new StmtDeclaration(declaration.typeString(), type, varName, expression, location);
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
	private StmtWhile processWhile(StmtWhile stmtWhile) {
		final Expression condition = checkBooleanCondition(stmtWhile.condition(), stmtWhile.location());
		final Statement bodyStatement = processStatement(stmtWhile.bodyStatement());
		return new StmtWhile(condition, bodyStatement, stmtWhile.location());
	}

	@NotNull
	private StmtFor processFor(StmtFor forStmt) {
		final List<Statement> initialization = processStatements(forStmt.initialization());

		final Expression condition = checkBooleanCondition(forStmt.condition(), forStmt.location());

		final List<Statement> iteration = processStatements(forStmt.iteration());

		final Statement bodyStatement = processStatement(forStmt.bodyStatement());
		return new StmtFor(initialization, condition, bodyStatement, iteration, forStmt.location());
	}

	@NotNull
	private Expression checkBooleanCondition(Expression expression, Location location) {
		final Expression condition = processExpression(expression);
		if (condition.typeNotNull() != Type.U8) {
			throw new SyntaxException("Expected type u8 for the condition", location);
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

		return new ExprCast(expression, expressionType, type, expression.location());
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
			case ExprCast cast -> cast;
			case ExprVarRead varRead -> processVarRead(varRead.varName(), varRead.location());
			case ExprFuncCall call -> processFuncCall(call.name(), call.argExpressions(), call.location());
			case ExprIntLiteral intLiteral -> intLiteral;
			case ExprBinary binary -> {
				if (binary.op() == ExprBinary.Op.Assign) {
					yield processAssign(binary.left(), binary.right(), binary.location());
				}
				final Expression left = processExpression(binary.left());
				final Expression right = processExpression(binary.right());
				yield processBinary(binary.op(), left, right, binary.location());
			}
			case ExprAddrOf addrOf -> processAddrOf(addrOf.varName(), addrOf.location());
			case ExprDeref deref -> processDeref(deref.expression(), deref.location());
			default -> throw new IllegalStateException("Unexpected expression: " + expression);
		};
	}

	@NotNull
	private Expression processVarRead(String name, Location location) {
		final Type type = getVariable(name, location);
		return new ExprVarRead(name, type, location);
	}

	@NotNull
	private Expression processAddrOf(String name, Location location) {
		final Type type = getVariable(name, location);
		return new ExprAddrOf(name, Type.pointer(type), location);
	}

	@NotNull
	private Expression processDeref(Expression expression, Location location) {
		expression = processExpression(expression);
		final Type type = expression.typeNotNull();
		final Type derefType = type.toType();
		if (derefType == null) {
			throw new SyntaxException(Messages.expectedPointerButGot(type), location);
		}
		return new ExprDeref(expression, derefType, location);
	}

	@NotNull
	private ExprFuncCall processFuncCall(String name, List<Expression> argExpressions, Location location) {
		final Symbol symbol = symbolMap.get(name);
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
					left = new ExprCast(left, leftType, pointerIntType, left.location());
					right = autoCastTo(pointerIntType, right, rightLocation);
					if (size > 1) {
						right = new ExprBinary(ExprBinary.Op.Multiply, pointerIntType, right,
						                       autoCastTo(pointerIntType, new ExprIntLiteral(size, rightLocation),
						                                  rightLocation),
						                       rightLocation);
					}
					return new ExprCast(new ExprBinary(op, leftType, left, right, location),
					                    pointerIntType, leftType, location);
				}
			}
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
					left = new ExprCast(left, leftType, rightType, left.location());
					type = rightType;
				}
				else {
					right = new ExprCast(right, rightType, leftType, rightLocation);
				}
			}
		}
		case Relational -> {
			type = Type.U8;
			if (!Objects.equals(leftType, rightType)) {
				if (leftType == Type.U8) {
					left = new ExprCast(left, leftType, rightType, left.location());
				}
				else {
					right = new ExprCast(right, rightType, leftType, rightLocation);
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
			case ExprVarRead varRead -> processVarRead(varRead.varName(), varRead.location());
			case ExprDeref deref -> processDeref(deref.expression(), deref.location());
			default -> throw new SyntaxException(Messages.expectedLValue(), expression.location());
		};
	}

	private void checkNoSymbolNamed(String name, Location location) {
		final Symbol existingSymbol = symbolMap.get(name);
		if (existingSymbol instanceof Symbol.Func) {
			throw new SyntaxException(Messages.functionAlreadDeclaredAt(name, existingSymbol.location()), location);
		}
		if (existingSymbol instanceof Symbol.Variable) {
			throw new SyntaxException(Messages.variableAlreadyDeclaredAt(name, existingSymbol.location()), location);
		}
		Utils.assertTrue(existingSymbol == null);
	}

	private void addVariable(String varName, Type type, Location location) {
		checkNoSymbolNamed(varName, location);
		symbolMap.put(varName, new Symbol.Variable(type, location));
	}

	@NotNull
	private Type getVariable(String name, Location location) {
		final Symbol symbol = symbolMap.get(name);
		if (!(symbol instanceof Symbol.Variable variable)) {
			throw new SyntaxException(Messages.undeclaredVariable(name), location);
		}
		return variable.type();
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
}
