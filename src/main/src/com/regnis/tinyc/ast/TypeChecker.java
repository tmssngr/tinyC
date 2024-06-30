package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class TypeChecker {

	private final Map<String, Pair<Type, Location>> variables = new HashMap<>();

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
		final Type returnType = getType(function.typeString(), location);
		return new Function(name, function.typeString(), returnType, function.statement(), location);
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
		final Statement statement = processStatement(function.statement());
		return new Function(function.name(), function.typeString(), function.type(), statement, function.location());
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
		if (!type.equals(expression.typeNotNull())) {
			if (type == Type.U8) {
				throw new SyntaxException("Expected type " + type + " but got " + expression.typeNotNull(), location);
			}

			expression = new ExprCast(expression, expression.typeNotNull(), type, expression.location());
		}

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

		if (!type.equals(expression.typeNotNull())) {
			if (type == Type.U8) {
				throw new SyntaxException("Expected type " + type + " but got " + expression.typeNotNull(), assign.location());
			}

			expression = new ExprCast(expression, expression.typeNotNull(), type, expression.location());
		}
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
	private Expression processExpression(Expression expression) {
		return switch (expression) {
			case ExprCast cast -> cast;
			case ExprVarRead varRead -> processVarRead(varRead.varName(), varRead.location());
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
}
