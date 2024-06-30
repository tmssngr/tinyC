package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class TypeChecker {

	private final Map<String, Pair<Type, Location>> variables = new HashMap<>();
	private final Map<String, Func> functions = new HashMap<>();

	@Nullable private Type expectedReturnType;

	public TypeChecker() {
	}

	@NotNull
	public Program check(@NotNull Program program) {
		final List<Function> typedFunctions = determineFunctionDeclarationTypes(program.functions());
		final List<Function> functions = determineStatementTypes(typedFunctions);
		return new Program(functions);
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
		final Func existingFunc = functions.get(name);
		if (existingFunc != null) {
			throw new SyntaxException("Function '" + name + "' has already been declared at " + existingFunc.location, location);
		}

		final Type returnType = getType(function.typeString(), location);
		final List<Function.Arg> args = new ArrayList<>();
		final List<Type> argTypes = new ArrayList<>();
		for (Function.Arg arg : function.args()) {
			final Type argType = getType(arg.typeString(), arg.location());
			args.add(new Function.Arg(arg.typeString(), argType, arg.name(), arg.location()));
			argTypes.add(argType);
		}
		functions.put(name, new Func(returnType, argTypes, location));
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
		return new Function(function.name(), function.typeString(), function.returnType(), function.args(), statement, function.location());
	}

	@NotNull
	private Statement processStatement(Statement statement) {
		if (statement instanceof Statement.Simple simple) {
			return processStatement(simple);
		}
		return switch (statement) {
			case StmtCompound compound -> processCompound(compound);
			case StmtIf ifStatement -> processIf(ifStatement);
			case StmtWhile whileStatement -> processWhile(whileStatement);
			case StmtFor forStatement -> processFor(forStatement);
			case StmtPrint print -> processPrint(print.expression(), print.location());
			case StmtReturn stmt -> processReturn(stmt.expression(), stmt.location());
			case StmtCall stmt -> processCall(stmt);
			default -> throw new IllegalStateException("Unexpected value: " + statement);
		};
	}

	@NotNull
	private Statement.Simple processStatement(Statement.Simple statement) {
		return switch (statement) {
			case StmtDeclaration declaration -> processDeclaration(declaration);
			case StmtAssign assign -> processAssign(assign);
			default -> throw new IllegalStateException("Unexpected value: " + statement);
		};
	}

	@NotNull
	private StmtCompound processCompound(StmtCompound compound) {
		final List<Statement> statements = new ArrayList<>();
		for (Statement statement : compound.statements()) {
			final Statement newStatement = processStatement(statement);
			statements.add(newStatement);
		}
		return new StmtCompound(statements);
	}

	@NotNull
	private StmtDeclaration processDeclaration(StmtDeclaration declaration) {
		final String varName = declaration.varName();
		final Location location = declaration.location();
		Expression expression = processExpression(declaration.expression());
		final Type type = getType(declaration.typeString(), location);
		expression = autoCastTo(type, expression, location);

		final Pair<Type, Location> pair = variables.get(varName);
		if (pair != null) {
			throw new SyntaxException("Variable '" + varName + "' has already been declared at " + pair.right(), location);
		}

		variables.put(varName, new Pair<>(type, location));
		return new StmtDeclaration(declaration.typeString(), type, varName, expression, location);
	}

	@NotNull
	private StmtAssign processAssign(StmtAssign assign) {
		Expression expression = processExpression(assign.expression());
		final Type type = getVariableType(assign.varName());
		if (type == null) {
			throw new SyntaxException("Undeclared variable '" + assign.varName() + "'", assign.location());
		}

		expression = autoCastTo(type, expression, assign.location());
		return new StmtAssign(assign.varName(), expression, assign.location());
	}

	@NotNull
	private StmtIf processIf(StmtIf ifStmt) {
		final Expression condition = processExpression(ifStmt.condition());
		if (condition.typeNotNull() != Type.U8) {
			throw new SyntaxException("Expected type u8 for the condition", ifStmt.location());
		}
		final Statement thenStatement = processStatement(ifStmt.thenStatement());
		Statement elseStatement = ifStmt.elseStatement();
		if (elseStatement != null) {
			elseStatement = processStatement(elseStatement);
		}
		return new StmtIf(condition, thenStatement, elseStatement, ifStmt.location());
	}

	@NotNull
	private StmtWhile processWhile(StmtWhile stmtWhile) {
		final Expression condition = processExpression(stmtWhile.condition());
		if (condition.typeNotNull() != Type.U8) {
			throw new SyntaxException("Expected type u8 for the condition", stmtWhile.location());
		}
		final Statement bodyStatement = processStatement(stmtWhile.bodyStatement());
		return new StmtWhile(condition, bodyStatement, stmtWhile.location());
	}

	@NotNull
	private StmtFor processFor(StmtFor forStmt) {
		final List<Statement.Simple> initialization = determineTypes(forStmt.initialization());

		final Expression condition = processExpression(forStmt.condition());
		if (condition.typeNotNull() != Type.U8) {
			throw new SyntaxException("Expected type u8 for the condition", forStmt.location());
		}

		final List<Statement.Simple> iteration = determineTypes(forStmt.iteration());

		final Statement bodyStatement = processStatement(forStmt.bodyStatement());
		return new StmtFor(initialization, condition, bodyStatement, iteration, forStmt.location());
	}

	@NotNull
	private List<Statement.Simple> determineTypes(@NotNull List<Statement.Simple> initialization) {
		final List<Statement.Simple> newInit = new ArrayList<>();
		for (Statement.Simple statement : initialization) {
			final Statement.Simple newStatement = processStatement(statement);
			newInit.add(newStatement);
		}
		return newInit;
	}

	@NotNull
	private StmtPrint processPrint(Expression expression, Location location) {
		expression = processExpression(expression);
		return new StmtPrint(expression, location);
	}

	@NotNull
	private StmtReturn processReturn(@Nullable Expression expression, Location location) {
		final Type expectedReturnType = Objects.requireNonNull(this.expectedReturnType);
		if (expression == null) {
			if (expectedReturnType != Type.VOID) {
				throw new SyntaxException("Expected expression of type '" + expectedReturnType + "'", location);
			}
		}
		else {
			if (expectedReturnType == Type.VOID) {
				throw new SyntaxException("Can't return anything from a void function", location);
			}
			expression = processExpression(expression);
			expression = autoCastTo(expectedReturnType, expression, location);
		}
		return new StmtReturn(expression, location);
	}

	@NotNull
	private StmtCall processCall(StmtCall stmt) {
		final ExprFuncCall call = stmt.call();
		return new StmtCall(processFuncCall(call.name(), call.argExpressions(), call.location()));
	}

	@NotNull
	private Expression autoCastTo(Type type, Expression expression, Location location) {
		final Type expressionType = expression.typeNotNull();
		if (type.equals(expressionType)) {
			return expression;
		}

		final int expectedSize = Type.getSize(type);
		final int actualSize = Type.getSize(expressionType);
		if (actualSize >= expectedSize) {
			throw new SyntaxException("Expected type " + type + " but got " + expressionType, location);
		}

		return new ExprCast(expression, expressionType, type, expression.location());
	}

	@NotNull
	private Expression processExpression(Expression expression) {
		return switch (expression) {
			case ExprCast cast -> cast;
			case ExprVarRead varRead -> processVarRead(varRead.varName(), varRead.location());
			case ExprFuncCall call -> processFuncCall(call.name(), call.argExpressions(), call.location());
			case ExprIntLiteral intLiteral -> intLiteral;
			case ExprBinary binary -> {
				final Expression left = processExpression(binary.left());
				final Expression right = processExpression(binary.right());
				yield processBinary(binary.op(), left, right, binary.location());
			}
			default -> throw new IllegalStateException("Unexpected expression: " + expression);
		};
	}

	@NotNull
	private Expression processVarRead(String name, Location location) {
		final Type type = getVariableType(name);
		if (type == null) {
			throw new SyntaxException("Unknown variable '" + name + "'", location);
		}
		return new ExprVarRead(name, type, location);
	}

	@NotNull
	private ExprFuncCall processFuncCall(String name, List<Expression> argExpressions, Location location) {
		final Func function = functions.get(name);
		if (function == null) {
			throw new SyntaxException("Undeclared function '" + name + "'", location);
		}
		if (function.argTypes().size() != argExpressions.size()) {
			throw new SyntaxException("Function '" + name + "' needs " + function.argTypes().size() + " arguments, but got " + argExpressions.size(), location);
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
	private ExprBinary processBinary(ExprBinary.Op op, Expression left, Expression right, Location location) {
		final Type leftType = left.typeNotNull();
		final Type rightType = right.typeNotNull();

		Type type;
		if (op == ExprBinary.Op.Add || op == ExprBinary.Op.Sub || op == ExprBinary.Op.Multiply || op == ExprBinary.Op.Divide) {
			type = leftType;
			if (leftType != rightType) {
				if (leftType == Type.U8) {
					left = new ExprCast(left, leftType, rightType, left.location());
					type = rightType;
				}
				else {
					right = new ExprCast(right, rightType, leftType, right.location());
				}
			}
		}
		else {
			type = Type.U8;
			if (leftType != rightType) {
				if (leftType == Type.U8) {
					left = new ExprCast(left, leftType, rightType, left.location());
				}
				else {
					right = new ExprCast(right, rightType, leftType, right.location());
				}
			}
		}
		return new ExprBinary(op, type, left, right, location);
	}

	@Nullable
	private Type getVariableType(@NotNull String name) {
		final Pair<Type, Location> pair = variables.get(name);
		return pair != null ? pair.left() : null;
	}

	@NotNull
	private Type getType(@NotNull String type, @NotNull Location location) {
		return switch (type) {
			case "void" -> Type.VOID;
			case "u8" -> Type.U8;
			case "i16" -> Type.I16;
			default -> throw new SyntaxException("Unknown type '" + type + "'", location);
		};
	}

	public record Func(Type returnType, List<Type> argTypes, Location location) {
	}
}
