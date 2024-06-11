package com.regnis.tinyc;

/**
 * @author Thomas Singer
 */
public enum TokenType {
	EOF, WHITESPACE, COMMENT,
	INT_LITERAL,
	COMMA, L_PAREN, R_PAREN,ASSIGN, PLUS, MINUS,
	STRING, VAR,
	IDENTIFIER
}
