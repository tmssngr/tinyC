package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;

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

	public AstNode parse() {
		AstNode root = null;
		while (token != TokenType.EOF) {
			root = handleStatements(root);
		}
		return root;
	}

	@NotNull
	private AstNode handleStatements(@Nullable AstNode prev) {
		AstNode node = getSimpleStatement();
		if (node != null) {
			consume(TokenType.SEMI);
		}
		else {
			node = switch (token) {
				case FOR -> handleFor();
				case IF -> handleIf();
				case PRINT -> handlePrint();
				case WHILE -> handleWhile();
				default -> throw new SyntaxException("Unexpected token " + token, getLocation());
			};
		}
		return chain(prev, node);
	}

	@Nullable
	private AstNode chain(@Nullable AstNode prev, @Nullable AstNode node) {
		if (node == null) {
			return prev;
		}
		if (prev == null) {
			return node;
		}
		return AstNode.chain(prev, node);
	}

	@Nullable
	private AstNode getStatements() {
		AstNode node = null;
		while (token != TokenType.R_BRACE) {
			if (token == TokenType.EOF) {
				throw new SyntaxException("Unexpected end of file", getLocation());
			}

			node = handleStatements(node);
		}
		return node;
	}

	@NotNull
	private AstNode handleIf() {
		final Location location = getLocation();
		consume(TokenType.IF);
		consume(TokenType.L_PAREN);
		final AstNode condition = getExpression();
		consume(TokenType.R_PAREN);
		consume(TokenType.L_BRACE);
		final AstNode thenStatements = getStatements();
		consume(TokenType.R_BRACE);
		AstNode elseStatements = null;
		if (isConsume(TokenType.ELSE)) {
			consume(TokenType.L_BRACE);
			elseStatements = getStatements();
			consume(TokenType.R_BRACE);
		}
		return AstNode.ifElse(condition, AstNode.chain(thenStatements, elseStatements), location);
	}

	@NotNull
	private AstNode handleFor() {
		final Location location = getLocation();
		consume(TokenType.FOR);
		consume(TokenType.L_PAREN);
		final AstNode initialize = getCommaSeparatedSimpleStatements();
		consume(TokenType.SEMI);
		final AstNode condition;
		if (token == TokenType.SEMI) {
			condition = null;
		}
		else {
			condition = getExpression();
			consume(TokenType.SEMI);
		}
		final AstNode iterate = getCommaSeparatedSimpleStatements();
		consume(TokenType.R_PAREN);
		consume(TokenType.L_BRACE);
		final AstNode bodyStatements = chain(getStatements(), iterate);
		consume(TokenType.R_BRACE);
		return chain(initialize, AstNode.whileStatement(condition, bodyStatements, location));
	}

	@Nullable
	private AstNode getCommaSeparatedSimpleStatements() {
		AstNode iterate = null;
		while (true) {
			final AstNode simpleStatement = getSimpleStatement();
			if (simpleStatement != null) {
				iterate = chain(iterate, simpleStatement);
				if (token == TokenType.COMMA) {
					consume();
					continue;
				}
			}
			break;
		}
		return iterate;
	}

	@NotNull
	private AstNode handleWhile() {
		final Location location = getLocation();
		consume(TokenType.WHILE);
		consume(TokenType.L_PAREN);
		final AstNode condition = getExpression();
		consume(TokenType.R_PAREN);
		consume(TokenType.L_BRACE);
		final AstNode bodyStatements = getStatements();
		consume(TokenType.R_BRACE);
		return AstNode.whileStatement(condition, bodyStatements, location);
	}

	@NotNull
	private AstNode handlePrint() {
		final Location location = getLocation();
		consume(TokenType.PRINT);
		final AstNode expression = getExpression();
		consume(TokenType.SEMI);
		return AstNode.print(expression, location);
	}

	@Nullable
	private AstNode getSimpleStatement() {
		return switch (token) {
			case VAR -> handleVar();
			case IDENTIFIER -> handleIdentifier();
			default -> null;
		};
	}

	@NotNull
	private AstNode handleVar() {
		final Location location = getLocation();
		consume(TokenType.VAR);
		final String varName = consumeIdentifier();
		consume(TokenType.EQUAL);
		final AstNode expression = getExpression();
		return AstNode.assign(varName, expression, location);
	}

	@NotNull
	private AstNode handleIdentifier() {
		final Location location = getLocation();
		final String identifier = consumeIdentifier();
		consume(TokenType.EQUAL);
		final AstNode expression = getExpression();
		return AstNode.assign(identifier, expression, location);
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
