package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public class Parser {

	private final Lexer lexer;

	private TokenType token;

	public Parser(@NotNull Lexer lexer) {
		this.lexer = lexer;

		consume();
	}

	@NotNull
	public Statement getStatementNotNull() {
		final Statement statement = getStatement();
		if (statement == null) {
			throw new SyntaxException("Expected statement, but got " + token, getLocation());
		}
		return statement;
	}

	@NotNull
	public Program parse() {
		final List<Function> functions = new ArrayList<>();
		final List<StmtDeclaration> globalVars = new ArrayList<>();
		while (token != TokenType.EOF) {
			final Location location = getLocation();
			final String type = consumeIdentifier();
			final String typeString = getTypeString(type);
			final String name = consumeIdentifier();
			if (isConsume(TokenType.L_PAREN)) {
				final List<Function.Arg> args = new ArrayList<>();
				while (!isConsume(TokenType.R_PAREN)) {
					final Location argLocation = getLocation();
					final String identifier = consumeIdentifier();
					final String argType = getTypeString(identifier);
					final String argName = consumeIdentifier();
					args.add(new Function.Arg(argType, argName, argLocation));
					if (token != TokenType.R_PAREN) {
						consume(TokenType.COMMA);
					}
				}
				final Statement statement = getStatementNotNull();
				functions.add(new Function(typeString, name, args, statement, location));
				continue;
			}

			if (isConsume(TokenType.EQUAL)) {
				final Expression expression = getExpression();
				consume(TokenType.SEMI);
				globalVars.add(new StmtDeclaration(typeString, name, expression, location));
				continue;
			}

			throw new SyntaxException("Expected method or global variable declaration", location);
		}
		return new Program(globalVars, functions);
	}

	@Nullable
	private Statement getStatement() {
		return switch (token) {
			case FOR -> handleFor();
			case IF -> handleIf();
			case RETURN -> handleReturn();
			case WHILE -> handleWhile();
			case L_BRACE -> handleCompound();
			case IDENTIFIER -> {
				final Location location = getLocation();
				final String identifier = consumeIdentifier();
				if (isConsume(TokenType.L_PAREN)) {
					// method call
					final List<Expression> argExpressions = getCallArgExpressions();
					consume(TokenType.SEMI);
					yield new StmtExpr(new ExprFuncCall(identifier, argExpressions, location));
				}

				final Statement.Simple declarationOrAssignment = getDeclarationOrAssignment(identifier, location);
				consume(TokenType.SEMI);
				yield declarationOrAssignment;
			}
			default -> null;
		};
	}

	@NotNull
	private List<Expression> getCallArgExpressions() {
		final List<Expression> argExpressions = new ArrayList<>();
		while (!isConsume(TokenType.R_PAREN)) {
			final Expression expression = getExpression();
			argExpressions.add(expression);
			if (token != TokenType.R_PAREN) {
				consume(TokenType.COMMA);
			}
		}
		return argExpressions;
	}

	@Nullable
	private Statement.Simple getSimpleStatement() {
		if (token == TokenType.IDENTIFIER) {
			final Location location = getLocation();
			final String identifier = consumeIdentifier();
			return getDeclarationOrAssignment(identifier, location);
		}

		return null;
	}

	@NotNull
	private Statement.Simple getDeclarationOrAssignment(String identifier1, Location location) {
		if (isConsume(TokenType.EQUAL)) {
			final Expression expression = getExpression();
			return new StmtAssign(identifier1, expression, location);
		}

		final String typeString = getTypeString(identifier1);
		final String identifier2 = consumeIdentifier();
		consume(TokenType.EQUAL);
		final Expression expression = getExpression();
		return new StmtDeclaration(typeString, identifier2, expression, location);
	}

	@NotNull
	private String getTypeString(String identifier) {
		final StringBuilder typeBuilder = new StringBuilder(identifier);
		while (isConsume(TokenType.STAR)) {
			typeBuilder.append("*");
		}
		return typeBuilder.toString();
	}

	private Statement handleCompound() {
		consume(TokenType.L_BRACE);
		final List<Statement> statements = new ArrayList<>();
		while (true) {
			final Statement statement = getStatement();
			if (statement == null) {
				break;
			}

			statements.add(statement);
		}
		consume(TokenType.R_BRACE);
		return new StmtCompound(statements);
	}

	@NotNull
	private StmtIf handleIf() {
		final Location location = getLocation();
		consume(TokenType.IF);
		consume(TokenType.L_PAREN);
		final Expression condition = getExpression();
		consume(TokenType.R_PAREN);
		final Statement thenStatement = getStatementNotNull();
		Statement elseStatements = null;
		if (isConsume(TokenType.ELSE)) {
			elseStatements = getStatementNotNull();
		}
		return new StmtIf(condition, thenStatement, elseStatements, location);
	}

	@NotNull
	private StmtFor handleFor() {
		final Location location = getLocation();
		consume(TokenType.FOR);
		consume(TokenType.L_PAREN);
		final List<Statement.Simple> initialization = getCommaSeparatedSimpleStatements();
		consume(TokenType.SEMI);
		final Expression condition;
		if (token == TokenType.SEMI) {
			condition = new ExprIntLiteral(1, location);
		}
		else {
			condition = getExpression();
			consume(TokenType.SEMI);
		}
		final List<Statement.Simple> iterate = getCommaSeparatedSimpleStatements();
		consume(TokenType.R_PAREN);
		final Statement body = getStatementNotNull();
		return new StmtFor(initialization, condition, body, iterate, location);
	}

	@NotNull
	private List<Statement.Simple> getCommaSeparatedSimpleStatements() {
		final List<Statement.Simple> statements = new ArrayList<>();
		while (true) {
			final Statement.Simple statement = getSimpleStatement();
			if (statement != null) {
				statements.add(statement);
				if (token == TokenType.COMMA) {
					consume();
					continue;
				}
			}
			break;
		}
		return statements;
	}

	@NotNull
	private StmtWhile handleWhile() {
		final Location location = getLocation();
		consume(TokenType.WHILE);
		consume(TokenType.L_PAREN);
		final Expression condition = getExpression();
		consume(TokenType.R_PAREN);
		final Statement bodyStatement = getStatementNotNull();
		return new StmtWhile(condition, bodyStatement, location);
	}

	@NotNull
	private StmtReturn handleReturn() {
		final Location location = getLocation();
		consume(TokenType.RETURN);
		Expression expression = null;
		if (!isConsume(TokenType.SEMI)) {
			expression = getExpression();
			consume(TokenType.SEMI);
		}
		return new StmtReturn(expression, location);
	}

	@NotNull
	private Expression getExpression() {
		return getExpression(0);
	}

	@NotNull
	private Expression getExpression(int minPrecedence) {
		Location location = getLocation();
		Expression left;
		if (token == TokenType.INT_LITERAL) {
			left = new ExprIntLiteral(consumeIntValue(), location);
		}
		else if (token == TokenType.IDENTIFIER) {
			final String name = consumeText();
			if (isConsume(TokenType.L_PAREN)) {
				final List<Expression> args = getCallArgExpressions();
				left = new ExprFuncCall(name, args, location);
			}
			else {
				left = new ExprVarRead(name, location);
			}
		}
		else if (isConsume(TokenType.AMP)) {
			final String name = consumeIdentifier();
			left = new ExprAddrOf(name, location);
		}
		else if (isConsume(TokenType.STAR)) {
			final String name = consumeIdentifier();
			left = new ExprDeref(name, location);
		}
		else {
			throw new SyntaxException("Expected int literal but got " + token, location);
		}

		while (true) {
			final int precedence = getPrecedence(token);
			if (precedence <= minPrecedence) {
				return left;
			}

			location = getLocation();
			final TokenType operationToken = token;
			consume();
			final Expression right = getExpression(precedence);
			left = switch (operationToken) {
				case PLUS -> new ExprBinary(ExprBinary.Op.Add, left, right, location);
				case MINUS -> new ExprBinary(ExprBinary.Op.Sub, left, right, location);
				case STAR -> new ExprBinary(ExprBinary.Op.Multiply, left, right, location);
				case SLASH -> new ExprBinary(ExprBinary.Op.Divide, left, right, location);
				case LT -> new ExprBinary(ExprBinary.Op.Lt, left, right, location);
				case LT_EQ -> new ExprBinary(ExprBinary.Op.LtEq, left, right, location);
				case EQ_EQ -> new ExprBinary(ExprBinary.Op.Equals, left, right, location);
				case EXCL_EQ -> new ExprBinary(ExprBinary.Op.NotEquals, left, right, location);
				case GT_EQ -> new ExprBinary(ExprBinary.Op.GtEq, left, right, location);
				case GT -> new ExprBinary(ExprBinary.Op.Gt, left, right, location);
				default -> throw new IllegalStateException("Unsupported operation " + operationToken);
			};
		}
	}

	private int consumeIntValue() {
		final int value = getIntValue();
		consume();
		return value;
	}

	@NotNull
	private String consumeIdentifier() {
		expectType(TokenType.IDENTIFIER);
		return consumeText();
	}

	@NotNull
	private String consumeText() {
		final String text = getText();
		consume();
		return text;
	}

	private void expectType(@NotNull TokenType type) {
		if (token != type) {
			throw new SyntaxException("Expected " + type + " but got " + token, getLocation());
		}
	}

	private int getIntValue() {
		return lexer.getIntValue();
	}

	@NotNull
	private String getText() {
		return lexer.getText();
	}

	@NotNull
	private Location getLocation() {
		return lexer.getLocation();
	}

	private boolean isConsume(@NotNull TokenType type) {
		if (token != type) {
			return false;
		}

		consume();
		return true;
	}

	private void consume(@NotNull TokenType type) {
		expectType(type);
		consume();
	}

	private void consume() {
		do {
			token = lexer.next();
//			System.out.println(token);
		}
		while (token == TokenType.WHITESPACE || token == TokenType.COMMENT);
	}

	private static int getPrecedence(TokenType token) {
		return switch (token) {
			case LT, LT_EQ, EQ_EQ, EXCL_EQ, GT_EQ, GT -> 1;
			case PLUS, MINUS -> 2;
			case STAR, SLASH -> 3;
			default -> 0;
		};
	}
}
