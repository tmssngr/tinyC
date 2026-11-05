package com.regnis.tinyc;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class IfDefPreprocessorLexer implements Lexer {

	private final Lexer lexer;
	private final IfDefHandling ifDefHandling;

	public IfDefPreprocessorLexer(@NotNull Lexer lexer, @NotNull IfDefHandling ifDefHandling) {
		this.lexer = lexer;
		this.ifDefHandling = ifDefHandling;
	}

	@Override
	public Token next() {
		while (true) {
			final Token token = lexer.next();
			switch (token.type()) {
			case HASH_IFDEF -> {
				final String name = expectToken(TokenType.IDENTIFIER).text();
				expectToken(TokenType.LINEBREAK);
				ifDefHandling.processIfDef(name, token.location());
			}
			case HASH_ELSE -> {
				expectToken(TokenType.LINEBREAK);
				ifDefHandling.processElse(token.location());
			}
			case HASH_ENDIF -> {
				expectToken(TokenType.LINEBREAK);
				ifDefHandling.processEndIf(token.location());
			}
			case EOF -> {
				ifDefHandling.eof();
				return token;
			}
			default -> {
				if (!ifDefHandling.isSkip()) {
					return token;
				}
			}
			}
		}
	}

	private Token expectToken(TokenType expectedType) {
		final Token token = nextSignificantToken();
		if (token.type() != expectedType) {
			throw new SyntaxException("Expected " + expectedType + " but got " + token.type(), token.location());
		}
		return token;
	}

	private Token nextSignificantToken() {
		while (true) {
			final Token token = lexer.next();
			if (token.type() != TokenType.WHITESPACE && token.type() != TokenType.COMMENT) {
				return token;
			}
		}
	}
}
