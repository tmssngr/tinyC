package com.regnis.tinyc;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class Lexer {

	private final CharSource source;

	private int line;
	private int column;
	private int chr;
	private int intValue;
	private String text;
	private Location location;

	public Lexer(@NotNull String text) {
		this(new CharSource() {
			private int index;

			@Override
			public int next() {
				return index == text.length()
						? -1
						: text.charAt(index++);
			}
		});
	}

	public Lexer(@NotNull CharSource source) {
		this.source = source;

		chr = source.next();
	}

	public TokenType next() {
		text = null;
		intValue = 0;
		location = new Location(line, column);

		if (chr < 0) {
			return TokenType.EOF;
		}

		if (isWhitespace()) {
			text = detectWhitespace();
			return TokenType.WHITESPACE;
		}
		if (isConsume('/')) {
			if (chr == '/') {
				text = detectLineComment();
				return TokenType.COMMENT;
			}

			if (chr == '*') {
				text = detectBlockComment();
				return TokenType.COMMENT;
			}

			return TokenType.SLASH;
		}

		if (isConsume(';')) {
			return TokenType.SEMI;
		}
		if (isConsume(',')) {
			return TokenType.COMMA;
		}
		if (isConsume('+')) {
			if (isConsume('+')) {
				return TokenType.PLUS_PLUS;
			}
			return TokenType.PLUS;
		}
		if (isConsume('-')) {
			if (isConsume('-')) {
				return TokenType.MINUS_MINUS;
			}
			return TokenType.MINUS;
		}
		if (isConsume('*')) {
			return TokenType.STAR;
		}
		if (isConsume('!')) {
			return isConsume('=')
					? TokenType.EXCL_EQ
					: TokenType.EXCL;
		}
		if (isConsume('=')) {
			return isConsume('=')
					? TokenType.EQ_EQ
					: TokenType.EQUAL;
		}
		if (isConsume('<')) {
			return isConsume('=')
					? TokenType.LT_EQ
					: TokenType.LT;
		}
		if (isConsume('>')) {
			return isConsume('=')
					? TokenType.GT_EQ
					: TokenType.GT;
		}
		if (isConsume('(')) {
			return TokenType.L_PAREN;
		}
		if (isConsume(')')) {
			return TokenType.R_PAREN;
		}
		if (isConsume('{')) {
			return TokenType.L_BRACE;
		}
		if (isConsume('}')) {
			return TokenType.R_BRACE;
		}
		if (isConsume('[')) {
			return TokenType.L_BRACKET;
		}
		if (isConsume(']')) {
			return TokenType.R_BRACKET;
		}
		if (isConsume('"')) {
			text = detectStringOrChar('"');
			return TokenType.STRING;
		}
		if (isConsume('\'')) {
			final String text = detectStringOrChar('\'');
			intValue = text.charAt(0);
			return TokenType.INT_LITERAL;
		}
		if (isConsume('&')) {
			if (isConsume('&')) {
				return TokenType.AMP_AMP;
			}
			return TokenType.AMP;
		}
		if (isConsume('|')) {
			if (isConsume('|')) {
				return TokenType.PIPE_PIPE;
			}
			return TokenType.PIPE;
		}
		if (isConsume('^')) {
			return TokenType.CARET;
		}
		if (isConsume('~')) {
			return TokenType.TILDE;
		}
		if (isConsume('.')) {
			return TokenType.DOT;
		}

		final StringBuilder buffer = new StringBuilder();
		do {
			append(buffer);
			consume();
		}
		while (chr >= 0
		       && isIdentifierChar(chr)
		       && !isWhitespace()
		       && !isLineBreak()
		);
		text = buffer.toString();

		if (detectInt(text)) {
			return TokenType.INT_LITERAL;
		}

		return switch (text) {
			case "true" -> TokenType.TRUE;
			case "false" -> TokenType.FALSE;
			case "return" -> TokenType.RETURN;
			case "if" -> TokenType.IF;
			case "else" -> TokenType.ELSE;
			case "for" -> TokenType.FOR;
			case "while" -> TokenType.WHILE;
			case "break" -> TokenType.BREAK;
			case "continue" -> TokenType.CONTINUE;
			case "typedef" -> TokenType.TYPEDEF;
			default -> TokenType.IDENTIFIER;
		};
	}

	@NotNull
	public String getText() {
		return text;
	}

	public int getIntValue() {
		return intValue;
	}

	public Location getLocation() {
		return location;
	}

	private boolean detectInt(String text) {
		try {
			intValue = Integer.parseInt(text);
			return true;
		}
		catch (NumberFormatException ignored) {
		}

		if (text.startsWith("0b")) {
			final String possibleNumberString = text.substring(2).replace("_", "");
			try {
				intValue = Integer.parseInt(possibleNumberString, 2);
				return true;
			}
			catch (NumberFormatException ignored) {
				throw new InvalidTokenException("Invalid number", location);
			}
		}

		if (text.startsWith("0x")) {
			final String possibleNumberString = text.substring(2);
			try {
				intValue = Integer.parseInt(possibleNumberString,
				                            16);
				return true;
			}
			catch (NumberFormatException ignored) {
			}
		}
		return false;
	}

	private String detectWhitespace() {
		final StringBuilder buffer = new StringBuilder();
		do {
			append(buffer);
			consume();
		}
		while (isWhitespace());
		return buffer.toString();
	}

	private String detectLineComment() {
		final StringBuilder buffer = new StringBuilder();
		buffer.append("/");
		do {
			append(buffer);
			consume();
		}
		while (chr >= 0 && !isLineBreak());
		return buffer.toString();
	}

	private String detectBlockComment() {
		final StringBuilder buffer = new StringBuilder();
		buffer.append("/*");
		int prev = 0;
		while (true) {
			consume();
			if (chr < 0) {
				throw new InvalidTokenException("Block comment needs to be closed", location);
			}

			append(buffer);
			if (prev == '*' && chr == '/') {
				consume();
				return buffer.toString();
			}

			prev = chr;
		}
	}

	private String detectStringOrChar(char endChar) {
		final StringBuilder buffer = new StringBuilder();
		Location escapeStartLocation = null;
		while (true) {
			if (chr < 0 || isLineBreak()) {
				if (endChar == '\'') {
					throw new InvalidTokenException("A char must end with a quote", location);
				}
				throw new InvalidTokenException("String must end with a double-quote", new Location(line, column));
			}

			if (escapeStartLocation != null) {
				switch (chr) {
				case 't' -> consumeAppend('\t', buffer);
				case 'n' -> consumeAppend('\n', buffer);
				case 'r' -> consumeAppend('\r', buffer);
				case '0' -> consumeAppend(0, buffer);
				case 'x' -> {
					consume();
					boolean tooShort = true;
					int hexValue = 0;
					while (true) {
						if (chr < 0) {
							if (tooShort) {
								throw new InvalidTokenException("Invalid char escape", escapeStartLocation);
							}
							break;
						}

						final int nibble = toHexNibble(chr);
						if (nibble < 0) {
							if (tooShort) {
								throw new InvalidTokenException("Invalid char escape", escapeStartLocation);
							}
							break;
						}

						consume();
						hexValue = (16 * hexValue + nibble) & 0xFFFF;
						tooShort = false;
					}
					append(hexValue, buffer);
				}
				default -> consumeAppend(chr, buffer);
				}
				escapeStartLocation = null;
				continue;
			}

			if (chr == endChar) {
				consume();
				break;
			}

			if (chr == '\\') {
				escapeStartLocation = new Location(line, column);
			}
			else {
				append(buffer);
			}
			consume();
		}
		if (buffer.isEmpty()) {
			throw new InvalidTokenException("An empty string can only be done with L\"\"", location);
		}
		return buffer.toString();
	}

	private int toHexNibble(int chr) {
		if (chr < '0') {
			return -1;
		}
		if (chr <= '9') {
			return chr - '0';
		}
		if (chr < 'A') {
			return -1;
		}
		if (chr <= 'F') {
			return chr - 'A' + 10;
		}
		if (chr < 'a') {
			return -1;
		}
		if (chr <= 'f') {
			return chr - 'a' + 10;
		}
		return -1;
	}

	private boolean isConsume(int chr) {
		if (this.chr != chr) {
			return false;
		}
		consume();
		return true;
	}

	private void consume() {
		if (chr < 0) {
			return;
		}

		final int prevChr = chr;
		chr = source.next();

		if (prevChr == '\n') {
			line++;
			column = 0;
		}
		else {
			column++;
		}
	}

	private boolean isWhitespace() {
		return " \t\r\n".indexOf(chr) >= 0;
	}

	private boolean isLineBreak() {
		return "\r\n".indexOf(chr) >= 0;
	}

	private void append(StringBuilder buffer) {
		append(chr, buffer);
	}

	private void consumeAppend(int chr, StringBuilder buffer) {
		append(chr, buffer);
		consume();
	}

	private static void append(int chr, StringBuilder buffer) {
		buffer.append((char)chr);
	}

	private static boolean isIdentifierChar(int chr) {
		return isInInterval(chr, '0', '9')
		       || isInInterval(chr, 'A', 'Z')
		       || isInInterval(chr, 'a', 'z');
	}

	private static boolean isInInterval(int chr, char from, char to) {
		return from <= chr && chr <= to;
	}
}
