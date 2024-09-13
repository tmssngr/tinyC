package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public class ArithmeticSimplifier {

	@NotNull
	public static Program simplify(@NotNull Program program) {
		final List<Function> functions = new ArrayList<>();
		for (Function function : program.functions()) {
			functions.add(simplify(function));
		}
		return new Program(program.typeDefs(), program.globalVars(), functions, program.globalVariables(), program.stringLiterals());
	}

	static Expression simplify(Expression expression) {
		return switch (expression) {
			case ExprUnary unary -> simplify(unary);
			case ExprCast unary -> new ExprCast(unary.typeString(), simplify(unary.expression()), unary.type(), unary.location());
			case ExprBinary binary -> simplify(binary);
			case ExprFuncCall call -> simplify(call);
			case ExprArrayAccess access -> simplify(access);
			case ExprVarAccess var -> simplify(var);
			case ExprIntLiteral literal -> literal;
			case ExprBoolLiteral literal -> literal;
			default -> expression;
		};
	}

	private static Function simplify(Function function) {
		if (function.asmLines().size() > 0) {
			return function;
		}

		final List<Statement> statements = simplify(function.statements());
		return new Function(function.name(), function.typeString(), function.returnTypeNotNull(), function.args(), function.localVars(), statements, List.of(), function.location());
	}

	@NotNull
	private static List<Statement> simplify(List<Statement> statements) {
		final List<Statement> simplified = new ArrayList<>();
		for (Statement statement : statements) {
			final Statement simplified1 = simplify(statement);
/*
			final String orig = statement.toString();
			final String simpl = simplified1.toString();
			if (orig.equals(simpl)) {
				System.out.println("Not simplified " + orig);
			}
			else {
				System.out.println("Simplified " + orig);
				System.out.println("        to " + simpl);
			}
*/
			simplified.add(simplified1);
		}
		return simplified;
	}

	private static Statement simplify(Statement statement) {
		return switch (statement) {
			case StmtExpr stmtExpr -> new StmtExpr(simplify(stmtExpr.expression()));
			case StmtIf stmtIf -> new StmtIf(simplify(stmtIf.condition()),
			                                 simplify(stmtIf.thenStatements()),
			                                 simplify(stmtIf.elseStatements()),
			                                 stmtIf.location());
			case StmtLoop stmtLoop -> new StmtLoop(simplify(stmtLoop.condition()),
			                                       simplify(stmtLoop.bodyStatements()),
			                                       simplify(stmtLoop.iteration()),
			                                       stmtLoop.location());
			case StmtReturn stmtReturn -> {
				final Expression expression = stmtReturn.expression();
				yield expression != null
						? new StmtReturn(simplify(expression), stmtReturn.location())
						: stmtReturn;
			}
			case StmtVarDeclaration stmt -> {
				final Expression expression = stmt.expression();
				yield expression != null
						? new StmtVarDeclaration(stmt.typeString(), stmt.varName(), stmt.index(), stmt.scope(), stmt.type(), simplify(expression), stmt.location())
						: stmt;
			}
			default -> statement;
		};
	}

	private static ExprVarAccess simplify(ExprVarAccess var) {
		return var;
	}

	private static Expression simplify(ExprBinary binary) {
		final Expression left = simplify(binary.left());
		final Expression right = simplify(binary.right());
		final Type type = binary.typeNotNull();
		final Location location = binary.location();

		if (left instanceof ExprIntLiteral leftLit
		    && right instanceof ExprIntLiteral rightLit) {
			final int leftValue = leftLit.value();
			final int rightValue = rightLit.value();
			return switch (binary.op()) {
				case Add -> new ExprIntLiteral(leftValue + rightValue, type, location);
				case Sub -> new ExprIntLiteral(leftValue - rightValue, type, location);
				case Multiply -> new ExprIntLiteral(leftValue * rightValue, type, location);
				case Divide -> new ExprIntLiteral(leftValue / rightValue, type, location);
				case Mod -> new ExprIntLiteral(leftValue % rightValue, type, location);
				case And -> new ExprIntLiteral(leftValue & rightValue, type, location);
				case Or -> new ExprIntLiteral(leftValue | rightValue, type, location);
				case Xor -> new ExprIntLiteral(leftValue ^ rightValue, type, location);
				case Lt -> new ExprBoolLiteral(leftValue < rightValue, location);
				case LtEq -> new ExprBoolLiteral(leftValue <= rightValue, location);
				case Equals -> new ExprBoolLiteral(leftValue == rightValue, location);
				case NotEquals -> new ExprBoolLiteral(leftValue != rightValue, location);
				case GtEq -> new ExprBoolLiteral(leftValue >= rightValue, location);
				case Gt -> new ExprBoolLiteral(leftValue > rightValue, location);
				default -> throw new UnsupportedOperationException();
			};
		}

		if (left instanceof ExprBoolLiteral leftLit
		    && right instanceof ExprBoolLiteral rightLit) {
			final boolean leftValue = leftLit.value();
			final boolean rightValue = rightLit.value();
			return switch (binary.op()) {
				case AndLog -> new ExprBoolLiteral(leftValue && rightValue, location);
				case OrLog -> new ExprBoolLiteral(leftValue || rightValue, location);
				case Equals -> new ExprBoolLiteral(leftValue == rightValue, location);
				case NotEquals -> new ExprBoolLiteral(leftValue != rightValue, location);
				default -> throw new UnsupportedOperationException();
			};
		}

		return new ExprBinary(binary.op(), type, left, right, location);
	}

	private static Expression simplify(ExprFuncCall call) {
		final List<Expression> args = new ArrayList<>();
		for (Expression expression : call.argExpressions()) {
			args.add(simplify(expression));
		}
		return new ExprFuncCall(call.name(), call.type(), args, call.location());
	}

	private static Expression simplify(ExprArrayAccess access) {
		return new ExprArrayAccess(simplify(access.varAccess()), access.type(), simplify(access.index()));
	}

	private static Expression simplify(ExprUnary unary) {
		final Expression expression = simplify(unary.expression());
		final Type type = expression.typeNotNull();
		final Location location = unary.location();

		if (expression instanceof ExprIntLiteral literal) {
			final int value = literal.value();
			return switch (unary.op()) {
				case Com -> new ExprIntLiteral(~value, type, location);
				case Neg -> new ExprIntLiteral(-value, type, location);
				default -> throw new UnsupportedOperationException();
			};
		}

		if (expression instanceof ExprBoolLiteral literal) {
			final boolean value = literal.value();
			return switch (unary.op()) {
				case NotLog -> new ExprBoolLiteral(!value, location);
				default -> throw new UnsupportedOperationException();
			};
		}

		return new ExprUnary(unary.op(), expression, unary.typeNotNull(), location);
	}
}
