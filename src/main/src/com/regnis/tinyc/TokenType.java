package com.regnis.tinyc;

/**
 * @author Thomas Singer
 */
public enum TokenType {
	EOF, WHITESPACE, COMMENT,
	INT_LITERAL, TRUE, FALSE, STRING,
	COMMA, SEMI, EQUAL, PLUS, PLUS_PLUS, MINUS, MINUS_MINUS, STAR, SLASH, EXCL, AMP, AMP_AMP, PIPE, PIPE_PIPE, CARET, TILDE, DOT, PERCENT,
	L_PAREN, R_PAREN,
	L_BRACE, R_BRACE,
	L_BRACKET, R_BRACKET,
	LT, LT_EQ, EQ_EQ, GT_EQ, GT, EXCL_EQ,
	IDENTIFIER,
	IF, ELSE,
	FOR, WHILE, BREAK, CONTINUE,
	RETURN,
	TYPEDEF,
	INCLUDE, ASM
}
