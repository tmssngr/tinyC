package com.regnis.tinyc;

/**
 * @author Thomas Singer
 */
public enum TokenType {
	EOF, WHITESPACE, COMMENT,
	INT_LITERAL,
	COMMA, L_PAREN, R_PAREN, SEMI, EQUAL, PLUS, MINUS, STAR, SLASH, EXCL,
	LT, LT_EQ, EQ_EQ, GT_EQ, GT, EXCL_EQ,
	STRING, VAR,
	PRINT, IDENTIFIER
}
