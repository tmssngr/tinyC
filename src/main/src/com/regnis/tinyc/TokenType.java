package com.regnis.tinyc;

/**
 * @author Thomas Singer
 */
public enum TokenType {
	EOF, WHITESPACE, COMMENT,
	INT_LITERAL,
	COMMA, SEMI, EQUAL, PLUS, MINUS, STAR, SLASH, EXCL, AMP,
	L_PAREN, R_PAREN,
	L_BRACE, R_BRACE,
	LT, LT_EQ, EQ_EQ, GT_EQ, GT, EXCL_EQ,
	STRING,
	IDENTIFIER,
	FOR, IF, ELSE, WHILE, RETURN;
}
