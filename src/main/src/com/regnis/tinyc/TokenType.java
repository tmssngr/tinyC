package com.regnis.tinyc;

/**
 * @author Thomas Singer
 */
public enum TokenType {
	EOF, WHITESPACE, COMMENT,
	INT_LITERAL,
	COMMA, L_PAREN, R_PAREN, SEMI, ASSIGN, PLUS, MINUS, STAR, SLASH,
	STRING, VAR,
	PRINT, IDENTIFIER
}
