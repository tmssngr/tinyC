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

	public Statement parse() {
		final Statement statement = getStatementNotNull();
		expectType(TokenType.EOF);
		return statement;
	}

	@Nullable
	private Statement getStatement() {
		Statement statement = getSimpleStatement();
		if (statement != null) {
			consume(TokenType.SEMI);
		}
		else {
			statement = switch (token) {
				case FOR -> handleFor();
				case IF -> handleIf();
				case PRINT -> handlePrint();
				case WHILE -> handleWhile();
				case L_BRACE -> handleCompound();
				default -> null;
			};
		}
		return statement;
	}

	@NotNull
	private Statement getStatementNotNull() {
		final Statement statement = getStatement();
		if (statement == null) {
			throw new SyntaxException("Expected statement, but got " + token, getLocation());
		}
		return statement;
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
		return new Statement.Compound(statements);
	}

	@NotNull
	private Statement.If handleIf() {
		final Location location = getLocation();
		consume(TokenType.IF);
		consume(TokenType.L_PAREN);
		final AstNode condition = getExpression();
		consume(TokenType.R_PAREN);
		final Statement thenStatement = getStatementNotNull();
		Statement elseStatements = null;
		if (isConsume(TokenType.ELSE)) {
			elseStatements = getStatementNotNull();
		}
		return new Statement.If(condition, thenStatement, elseStatements, location);
	}

	@NotNull
	private Statement.For handleFor() {
		final Location location = getLocation();
		consume(TokenType.FOR);
		consume(TokenType.L_PAREN);
		final List<SimpleStatement> initialization = getCommaSeparatedSimpleStatements();
		consume(TokenType.SEMI);
		final AstNode condition;
		if (token == TokenType.SEMI) {
			condition = null;
		}
		else {
			condition = getExpression();
			consume(TokenType.SEMI);
		}
		final List<SimpleStatement> iterate = getCommaSeparatedSimpleStatements();
		consume(TokenType.R_PAREN);
		final Statement body = getStatementNotNull();
		return new Statement.For(initialization, condition, body, iterate, location);
	}

	@NotNull
	private List<SimpleStatement> getCommaSeparatedSimpleStatements() {
		final List<SimpleStatement> statements = new ArrayList<>();
		while (true) {
			final SimpleStatement statement = getSimpleStatement();
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
	private Statement.While handleWhile() {
		final Location location = getLocation();
		consume(TokenType.WHILE);
		consume(TokenType.L_PAREN);
		final AstNode condition = getExpression();
		consume(TokenType.R_PAREN);
		final Statement bodyStatement = getStatementNotNull();
		return new Statement.While(condition, bodyStatement, location);
	}

	@NotNull
	private Statement.Print handlePrint() {
		final Location location = getLocation();
		consume(TokenType.PRINT);
		final AstNode expression = getExpression();
		consume(TokenType.SEMI);
		return new Statement.Print(expression, location);
	}

	@Nullable
	private SimpleStatement getSimpleStatement() {
		return switch (token) {
			case VAR -> handleVar();
			case IDENTIFIER -> handleIdentifier();
			default -> null;
		};
	}

	@NotNull
	private SimpleStatement.Assign handleVar() {
		final Location location = getLocation();
		consume(TokenType.VAR);
		final String varName = consumeIdentifier();
		consume(TokenType.EQUAL);
		final AstNode expression = getExpression();
		return new SimpleStatement.Assign(varName, expression, location);
	}

	@NotNull
	private SimpleStatement.Assign handleIdentifier() {
		final Location location = getLocation();
		final String varName = consumeIdentifier();
		consume(TokenType.EQUAL);
		final AstNode expression = getExpression();
		return new SimpleStatement.Assign(varName, expression, location);
	}

	@NotNull
	private AstNode getExpression() {
		return getExpression(0);
	}

	@NotNull
	private AstNode getExpression(int minPrecedence) {
		Location location = getLocation();
		AstNode left;
		if (token == TokenType.INT_LITERAL) {
			left = AstNode.intLiteral(consumeIntValue(), location);
		}
		else if (token == TokenType.IDENTIFIER) {
			left = AstNode.varRead(consumeText(), location);
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
			final AstNode right = getExpression(precedence);
			left = switch (operationToken) {
				case PLUS -> AstNode.add(left, right, location);
				case MINUS -> AstNode.sub(left, right, location);
				case STAR -> AstNode.multiply(left, right, location);
				case SLASH -> AstNode.divide(left, right, location);
				case LT -> AstNode.lt(left, right, location);
				case LT_EQ -> AstNode.lteq(left, right, location);
				case EQ_EQ -> AstNode.eqeq(left, right, location);
				case EXCL_EQ -> AstNode.neq(left, right, location);
				case GT_EQ -> AstNode.gteq(left, right, location);
				case GT -> AstNode.gt(left, right, location);
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
