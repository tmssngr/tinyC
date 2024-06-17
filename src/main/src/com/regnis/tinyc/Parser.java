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

	public List<AstNode> parse() {
		final List<AstNode> nodes = new ArrayList<>();
		while (token != TokenType.EOF) {
			switch (token) {
			case PRINT -> nodes.add(handlePrint());
			case VAR -> nodes.add(handleVar());
			default -> throw new SyntaxException("Unexpected token " + token, getLocation());
			}
		}
		return nodes;
	}

	private AstNode handlePrint() {
		final Location location = getLocation();
		consume(TokenType.PRINT);
		final AstNode expression = getExpression();
		consume(TokenType.SEMI);
		return AstNode.print(expression, location);
	}

	private AstNode handleVar() {
		final Location location = getLocation();
		consume(TokenType.VAR);
		final String varName = consumeIdentifier();
		consume(TokenType.ASSIGN);
		final AstNode expression = getExpression();
		consume(TokenType.SEMI);
		return AstNode.assign(expression, AstNode.lhs(varName, location), location);
	}

	private AstNode getExpression() {
		return getExpression(0);
	}

	private AstNode getExpression(int minPrecedence) {
		AstNode left;
		if (token == TokenType.INT_LITERAL) {
			left = AstNode.intLiteral(consumeIntValue(), getLocation());
		}
		else if (token == TokenType.IDENTIFIER) {
			left = AstNode.varRead(consumeText(), getLocation());
		}
		else {
			throw new SyntaxException("Expected int literal but got " + token, getLocation());
		}

		while (true) {
			switch (token) {
			case PLUS,
			     MINUS,
			     STAR,
			     SLASH -> {
				final int precedence = getPrecedence(token);
				if (precedence <= minPrecedence) {
					return left;
				}

				final Location location = getLocation();
				final TokenType operationToken = token;
				consume();
				final AstNode right = getExpression(precedence);
				left = switch (operationToken) {
					case PLUS -> AstNode.add(left, right, location);
					case MINUS -> AstNode.sub(left, right, location);
					case STAR -> AstNode.multiply(left, right, location);
					case SLASH -> AstNode.divide(left, right, location);
					default -> throw new IllegalStateException("Unsupported operation " + operationToken);
				};
			}
			default -> {
				return left;
			}
			}
		}
	}

	private static int getPrecedence(TokenType token) {
		return switch (token) {
			case PLUS, MINUS -> 1;
			case STAR, SLASH -> 2;
			default -> {
				throw new IllegalStateException("Unsupported operation " + token);
			}
		};
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
}
