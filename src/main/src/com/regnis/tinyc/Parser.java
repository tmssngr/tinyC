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

	public Program parse() {
		final List<Function> functions = new ArrayList<>();
		while (token != TokenType.EOF) {
			functions.add(getFunction());
		}
		return new Program(functions);
	}

	@NotNull
	public Statement getStatementNotNull() {
		final Statement statement = getStatement();
		if (statement == null) {
			throw new SyntaxException("Expected statement, but got " + token, getLocation());
		}
		return statement;
	}

	private Function getFunction() {
		final Location location = getLocation();
		final String type = consumeIdentifier();
		final String name = consumeIdentifier();
		consume(TokenType.L_PAREN);
		consume(TokenType.R_PAREN);
		final Statement statement = getStatementNotNull();
		return new Function(name, type, statement, location);
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
	private StmtPrint handlePrint() {
		final Location location = getLocation();
		consume(TokenType.PRINT);
		final Expression expression = getExpression();
		consume(TokenType.SEMI);
		return new StmtPrint(expression, location);
	}

	@Nullable
	private Statement.Simple getSimpleStatement() {
		final Location location = getLocation();
		if (token == TokenType.IDENTIFIER) {
			final String identifier1 = consumeIdentifier();
			if (isConsume(TokenType.EQUAL)) {
				final Expression expression = getExpression();
				return new StmtAssign(identifier1, expression, location);
			}

			final String identifier2 = consumeIdentifier();
			consume(TokenType.EQUAL);
			final Expression expression = getExpression();
			return new StmtDeclaration(identifier1, identifier2, expression, location);
		}

		if (isConsume(TokenType.VAR)) {
			final String identifier = consumeIdentifier();
			consume(TokenType.EQUAL);
			final Expression expression = getExpression();
			return new StmtDeclaration("", identifier, expression, location);
		}

		return null;
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
			String text = consumeText();
			left = new ExprVarRead(text, location);
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
