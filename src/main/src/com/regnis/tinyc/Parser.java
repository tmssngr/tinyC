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
			case VAR -> nodes.add(handleVar());
			default -> throw new SyntaxException("Unexpected token " + token, getLocation());
			}

			consume();
		}
		return nodes;
	}

	private AstNode handleVar() {
		consume(TokenType.VAR);
		final String varName = consumeIdentifier();
		consume(TokenType.ASSIGN);
		final AstNode expression = getExpression();
		consume(TokenType.SEMI);
		return AstNode.assign(expression, AstNode.lhs(varName));
	}

	private AstNode getExpression() {
		AstNode left;
		if (token == TokenType.INT_LITERAL) {
			left = AstNode.intLiteral(consumeIntValue());
		}
		else {
			throw new SyntaxException("Expected int literal", getLocation());
		}

		while (true) {
			switch (token) {
			case PLUS -> {
				final AstNode right = getExpression();
				left = AstNode.plus(left, right);
			}
			case MINUS -> {
				final AstNode right = getExpression();
				left = AstNode.minus(left, right);
			}
			default -> {
				return left;
			}
			}
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

	private void consume(@NotNull TokenType type) {
		expectType(type);
		consume();
	}

	private void consume() {
		do {
			token = lexer.next();
		}
		while (token == TokenType.WHITESPACE || token == TokenType.COMMENT);
	}
}
