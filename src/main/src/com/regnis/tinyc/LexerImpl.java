package com.regnis.tinyc;

import java.util.function.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class LexerImpl implements Lexer {

	private final CharSource source;

	private int line;
	private int column;
	private int chr;

	public LexerImpl(@NotNull String text) {
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

	public LexerImpl(@NotNull CharSource source) {
		this.source = source;

		chr = source.next();
	}

	@Override
	public Token next() {
		final Location location = new Location(line, column);

		if (chr < 0) {
			return new Token(TokenType.EOF, 0, "", location);
		}

		if (isWhitespace()) {
			final String text = detect(this::isWhitespace);
			return new Token(TokenType.WHITESPACE, 0, text, location);
		}
		if (isLineBreak()) {
			final String text = detect(this::isLineBreak);
			return new Token(TokenType.LINEBREAK, 0, text, location);
		}
		if (isConsume('/')) {
			if (chr == '/') {
				final String text = detectLineComment();
				return new Token(TokenType.COMMENT, 0, text, location);
			}

			if (chr == '*') {
				final String text = detectBlockComment(location);
				return new Token(TokenType.COMMENT, 0, text, location);
			}

			return new Token(isConsume('=') ? TokenType.SLASH_EQ : TokenType.SLASH, 0, "", location);
		}

		if (isConsume(';')) {
			return new Token(TokenType.SEMI, 0, "", location);
		}
		if (isConsume(',')) {
			return new Token(TokenType.COMMA, 0, "", location);
		}
		if (isConsume('+')) {
			return new Token(isConsume('=') ? TokenType.PLUS_EQ : TokenType.PLUS, 0, "", location);
		}
		if (isConsume('-')) {
			return new Token(isConsume('=') ? TokenType.MINUS_EQ : TokenType.MINUS, 0, "", location);
		}
		if (isConsume('*')) {
			return new Token(isConsume('=') ? TokenType.STAR_EQ : TokenType.STAR, 0, "", location);
		}
		if (isConsume('%')) {
			return new Token(isConsume('=') ? TokenType.PERCENT_EQ : TokenType.PERCENT, 0, "", location);
		}
		if (isConsume('!')) {
			return new Token(isConsume('=') ? TokenType.EXCL_EQ : TokenType.EXCL, 0, "", location);
		}
		if (isConsume('=')) {
			return new Token(isConsume('=') ? TokenType.EQ_EQ : TokenType.EQUAL, 0, "", location);
		}
		if (isConsume('<')) {
			if (isConsume('<')) {
				return new Token(isConsume('=') ? TokenType.LT_LT_EQ : TokenType.LT_LT, 0, "", location);
			}
			if (isConsume('=')) {
				return new Token(TokenType.LT_EQ, 0, "", location);
			}
			return new Token(TokenType.LT, 0, "", location);
		}
		if (isConsume('>')) {
			if (isConsume('>')) {
				return new Token(isConsume('=') ? TokenType.GT_GT_EQ : TokenType.GT_GT, 0, "", location);
			}
			if (isConsume('=')) {
				return new Token(TokenType.GT_EQ, 0, "", location);
			}
			return new Token(TokenType.GT, 0, "", location);
		}
		if (isConsume('(')) {
			return new Token(TokenType.L_PAREN, 0, "", location);
		}
		if (isConsume(')')) {
			return new Token(TokenType.R_PAREN, 0, "", location);
		}
		if (isConsume('{')) {
			return new Token(TokenType.L_BRACE, 0, "", location);
		}
		if (isConsume('}')) {
			return new Token(TokenType.R_BRACE, 0, "", location);
		}
		if (isConsume('[')) {
			return new Token(TokenType.L_BRACKET, 0, "", location);
		}
		if (isConsume(']')) {
			return new Token(TokenType.R_BRACKET, 0, "", location);
		}
		if (isConsume('"')) {
			final String text = detectStringOrChar('"', location);
			return new Token(TokenType.STRING, 0, text, location);
		}
		if (isConsume('\'')) {
			final String text = detectStringOrChar('\'', location);
			final char value = text.charAt(0);
			return new Token(TokenType.INT_LITERAL, value, "", location);
		}
		if (isConsume('&')) {
			if (isConsume('=')) {
				return new Token(TokenType.AMP_EQ, 0, "", location);
			}
			if (isConsume('&')) {
				return new Token(TokenType.AMP_AMP, 0, "", location);
			}
			return new Token(TokenType.AMP, 0, "", location);
		}
		if (isConsume('|')) {
			if (isConsume('=')) {
				return new Token(TokenType.PIPE_EQ, 0, "", location);
			}
			if (isConsume('|')) {
				return new Token(TokenType.PIPE_PIPE, 0, "", location);
			}
			return new Token(TokenType.PIPE, 0, "", location);
		}
		if (isConsume('^')) {
			return new Token(isConsume('=') ? TokenType.CARET_EQ : TokenType.CARET, 0, "", location);
		}
		if (isConsume('~')) {
			return new Token(TokenType.TILDE, 0, "", location);
		}
		if (isConsume('.')) {
			return new Token(TokenType.DOT, 0, "", location);
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
		final String text = buffer.toString();

		final Token intLiteral = detectInt(text, location);
		if (intLiteral != null) {
			return intLiteral;
		}

		return new Token(switch (text) {
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
			case "struct" -> TokenType.STRUCT;
			case "#include" -> TokenType.HASH_INCLUDE;
			case "#ifdef" -> TokenType.HASH_IFDEF;
			case "#else" -> TokenType.HASH_ELSE;
			case "#endif" -> TokenType.HASH_ENDIF;
			case "asm" -> TokenType.ASM;
			case "const" -> TokenType.CONST;
			case "as" -> TokenType.AS;
			default -> TokenType.IDENTIFIER;
		}, 0, text, location);
	}

	@Nullable
	private Token detectInt(String text, Location location) {
		if (text.startsWith("0b")) {
			text = text.substring(2);
			final Token result = detectInt(text, 2,
			                               c -> c >= '0' && c <= '1', location);
			if (result != null) {
				return result;
			}
			throw new InvalidTokenException("Invalid number", location);
		}

		if (text.startsWith("0x")) {
			text = text.substring(2);
			final Token result = detectInt(text, 16,
			                               c -> {
				                               if (c >= '0' && c <= '9') {
					                               return true;
				                               }
				                               if (c >= 'A' && c <= 'F') {
					                               return true;
				                               }
				                               return c >= 'a' && c <= 'f';
			                               }, location);
			if (result != null) {
				return result;
			}
			throw new InvalidTokenException("Invalid number", location);
		}

		return detectInt(text, 10,
		                 c -> c >= '0' && c <= '9', location);
	}

	@Nullable
	private Token detectInt(String text, int radix, ValidCharPredicate charChecker, Location location) {
		final StringBuilder buffer = new StringBuilder();
		boolean lastWasUnderscore = false;
		String suffix = "";
		for (int i = 0; i < text.length(); i++) {
			final char c = text.charAt(i);
			if (charChecker.isValid(c)) {
				buffer.append(c);
				lastWasUnderscore = false;
				continue;
			}
			if (c == '_') {
				if (buffer.isEmpty()) {
					return null;
				}

				lastWasUnderscore = true;
				continue;
			}
			if (lastWasUnderscore || buffer.isEmpty()) {
				return null;
			}
			suffix = text.substring(i);
			break;
		}
		if (lastWasUnderscore) {
			return null;
		}

		try {
			final int value = Integer.parseInt(buffer.toString(), radix);
			return new Token(TokenType.INT_LITERAL, value, suffix, location);
		}
		catch (NumberFormatException e) {
			return null;
		}
	}

	private String detect(BooleanSupplier predicate) {
		final StringBuilder buffer = new StringBuilder();
		do {
			append(buffer);
			consume();
		}
		while (predicate.getAsBoolean());
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

	private String detectBlockComment(Location location) {
		final StringBuilder buffer = new StringBuilder();
		buffer.append("/*");
		int prev = 0;
		while (true) {
			consume();
			if (chr < 0) {
				throw new InvalidTokenException(Messages.unterminatedBlockComment(), location);
			}

			append(buffer);
			if (prev == '*' && chr == '/') {
				consume();
				return buffer.toString();
			}

			prev = chr;
		}
	}

	private String detectStringOrChar(char endChar, Location location) {
		final StringBuilder buffer = new StringBuilder();
		Location escapeStartLocation = null;
		while (true) {
			if (chr < 0 || isLineBreak()) {
				if (endChar == '\'') {
					throw new InvalidTokenException(Messages.unterminatedCharacterLiteral(), location);
				}
				throw new InvalidTokenException(Messages.unterminatedStringLiteral(), location);
			}

			if (chr == endChar && escapeStartLocation == null) {
				if (endChar == '\'' && buffer.length() != 1) {
					throw new InvalidTokenException(Messages.invalidCharLiteral(), new Location(line, column));
				}
				consume();
				break;
			}

			if (endChar == '\'' && buffer.length() > 0) {
				throw new InvalidTokenException(Messages.invalidCharLiteral(), new Location(line, column));
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

			if (chr == '\\') {
				escapeStartLocation = new Location(line, column);
			}
			else {
				append(buffer);
			}
			consume();
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
		return chr == ' ' || chr == '\t';
	}

	private boolean isLineBreak() {
		return chr == '\r' || chr == '\n';
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
		return Utils.isInInterval(chr, '0', '9')
		       || Utils.isInInterval(chr, 'A', 'Z')
		       || Utils.isInInterval(chr, 'a', 'z')
		       || chr == '_';
	}

	private interface ValidCharPredicate {
		boolean isValid(char chr);
	}
}
