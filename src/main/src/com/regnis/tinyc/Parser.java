package com.regnis.tinyc;

import com.regnis.tinyc.ast.Function;
import com.regnis.tinyc.ast.*;

import java.io.*;
import java.nio.file.*;
import java.util.*;
import java.util.function.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class Parser {

	public static Program parse(String input, Set<String> defines) {
		return parse(new IncludeHandler() {
			@Override
			public void parse(@NotNull String fileName, @NotNull Location location, @NotNull Consumer<TypeDef> typeDefs, @NotNull Consumer<Statement> globalVars, @NotNull Consumer<Function> functions) {
				throw new RuntimeException("Includes are not supported");
			}

			@Override
			public void parse(@NotNull Consumer<TypeDef> typeDefs, @NotNull Consumer<Statement> globalVars, @NotNull Consumer<Function> functions) {
				final Parser parser = new Parser(new Lexer(input), this, defines);
				parser.parse(typeDefs, globalVars, functions);
			}
		});
	}

	public static Program parse(Path inputFile, Set<String> defines) throws IOException {
		try {
			return parse(new FileIncludeHandler(inputFile, null, defines));
		}
		catch (UncheckedIOException e) {
			throw e.getCause();
		}
	}

	private final Map<String, Expression> constants = new HashMap<>();
	private final Lexer lexer;
	private final IncludeHandler includeHandler;
	private final Set<String> defines;

	private int openIfDefCount;
	private TokenType token;

	private Parser(@NotNull Lexer lexer, @NotNull IncludeHandler includeHandler, @NotNull Set<String> defines) {
		this.lexer = lexer;
		this.includeHandler = includeHandler;
		this.defines = defines;

		consume();
	}

	public void parse(@NotNull Consumer<TypeDef> typeDefs, @NotNull Consumer<Statement> globalVars, @NotNull Consumer<Function> functions) {
		while (token != TokenType.EOF) {
			Location location = getLocation();
			if (token == TokenType.IDENTIFIER) {
				final String type = consumeIdentifier();
				final String typeString = getTypeString(type);
				final String name = consumeIdentifier();
				if (isConsume(TokenType.L_PAREN)) {
					final List<Function.Arg> args = new ArrayList<>();
					while (!isConsume(TokenType.R_PAREN)) {
						final Location argLocation = getLocation();
						final String identifier = consumeIdentifier();
						final String argType = getTypeString(identifier);
						final String argName = consumeIdentifier();
						args.add(new Function.Arg(argType, argName, argLocation));
						if (token != TokenType.R_PAREN) {
							consume(TokenType.COMMA);
						}
					}

					if (isConsume(TokenType.ASM)) {
						final List<String> asmLines = getAsmLines();
						functions.accept(Function.createAsmInstance(name, typeString, args, asmLines, location));
						continue;
					}

					final List<Statement> statements = getStatements();
					functions.accept(Function.createInstance(name, typeString, args, statements, location));
					continue;
				}

				if (isConsume(TokenType.EQUAL)) {
					final Expression expression = getExpression();
					consume(TokenType.SEMI);
					globalVars.accept(new StmtVarDeclaration(typeString, name, expression, location));
					continue;
				}
				if (isConsume(TokenType.SEMI)) {
					globalVars.accept(new StmtVarDeclaration(typeString, name, null, location));
					continue;
				}
				if (isConsume(TokenType.L_BRACKET)) {
					final StmtArrayDeclaration array = getArrayDeclaration(typeString, name, location);
					consume(TokenType.SEMI);
					globalVars.accept(array);
					continue;
				}
			}
			else if (isConsume(TokenType.TYPEDEF)) {
				final String typeName = consumeIdentifier();
				consume(TokenType.L_PAREN);
				final List<TypeDef.Part> parts = new ArrayList<>();
				do {
					final Location partLocation = getLocation();
					String partType = consumeIdentifier();
					partType = getTypeString(partType);
					final String partName = consumeIdentifier();
					parts.add(new TypeDef.Part(partName, partType, null, partLocation));
				}
				while (isConsume(TokenType.COMMA));
				consume(TokenType.R_PAREN);
				consume(TokenType.SEMI);
				typeDefs.accept(new TypeDef(typeName, null, parts, location));
				continue;
			}
			else if (isConsume(TokenType.INCLUDE)) {
				expectType(TokenType.STRING, null);
				final String fileName = consumeText();
				includeHandler.parse(fileName, location, typeDefs, globalVars, functions);
				continue;
			}
			else if (isConsume(TokenType.CONST)) {
				location = getLocation();
				final String name = consumeIdentifier();
				final Expression prevExpr = constants.get(name);
				if (prevExpr != null) {
					throw new SyntaxException(Messages.constantAlreadyDefinedAt(name, prevExpr.location()), location);
				}
				consume(TokenType.EQUAL);
				final Expression expression = getExpression();
				consume(TokenType.SEMI);
				final Expression resolvedExpression = resolveConstExpression(expression);
				constants.put(name, resolvedExpression);
				continue;
			}
			else if (isConsume(TokenType.IFDEF)) {
				final String name = consumeIdentifier();
				if (defines.contains(name)) {
					openIfDefCount++;
					continue;
				}

				while (true) {
					if (token == TokenType.EOF) {
						throw new SyntaxException(Messages.unclosedIfdef(), location);
					}
					if (token == TokenType.END) {
						break;
					}
					consume();
				}
				consume(TokenType.END);
				continue;
			}
			else if (isConsume(TokenType.END)) {
				if (openIfDefCount == 0) {
					throw new SyntaxException(Messages.endWithoutIfdef(), location);
				}

				openIfDefCount--;
				continue;
			}

			throw new SyntaxException(Messages.expectedRootElement(), location);
		}

		if (openIfDefCount > 0) {
			throw new SyntaxException(Messages.unclosedIfdef(), getLocation());
		}
	}

	private Expression resolveConstExpression(Expression expression) {
		if (expression instanceof ExprIntLiteral
		    || expression instanceof ExprBoolLiteral) {
			return expression;
		}

		if (expression instanceof ExprVarAccess access) {
			final String name = access.varName();
			final Expression result = constants.get(name);
			if (result == null) {
				throw new SyntaxException(Messages.unknownConstant(name), access.location());
			}
			return result;
		}

		if (expression instanceof ExprUnary unary) {
			final Expression expr = resolveConstExpression(unary.expression());
			switch (unary.op()) {
			case Com -> {
				if (expr instanceof ExprIntLiteral literal) {
					return new ExprIntLiteral(~literal.value(), literal.location());
				}
			}
			case Neg -> {
				if (expr instanceof ExprIntLiteral literal) {
					return new ExprIntLiteral(-literal.value(), literal.location());
				}
			}
			case NotLog -> {
				if (expr instanceof ExprBoolLiteral literal) {
					return new ExprBoolLiteral(!literal.value(), literal.location());
				}
			}
			}
		}

		if (expression instanceof ExprBinary binary) {
			final Expression left = resolveConstExpression(binary.left());
			final Expression right = resolveConstExpression(binary.right());
			if (left instanceof ExprIntLiteral leftLit
			    && right instanceof ExprIntLiteral rightLit) {
				switch (binary.op()) {
				case Add -> {
					return new ExprIntLiteral(leftLit.value() + rightLit.value(), binary.location());
				}
				case Sub -> {
					return new ExprIntLiteral(leftLit.value() - rightLit.value(), binary.location());
				}
				case Multiply -> {
					return new ExprIntLiteral(leftLit.value() * rightLit.value(), binary.location());
				}
				case Divide -> {
					return new ExprIntLiteral(leftLit.value() / rightLit.value(), binary.location());
				}
				case Mod -> {
					return new ExprIntLiteral(leftLit.value() % rightLit.value(), binary.location());
				}
				case And -> {
					return new ExprIntLiteral(leftLit.value() & rightLit.value(), binary.location());
				}
				case Or -> {
					return new ExprIntLiteral(leftLit.value() | rightLit.value(), binary.location());
				}
				case Xor -> {
					return new ExprIntLiteral(leftLit.value() ^ rightLit.value(), binary.location());
				}
				case Lt -> {
					return new ExprBoolLiteral(leftLit.value() < rightLit.value(), binary.location());
				}
				case LtEq -> {
					return new ExprBoolLiteral(leftLit.value() <= rightLit.value(), binary.location());
				}
				case Equals -> {
					return new ExprBoolLiteral(leftLit.value() == rightLit.value(), binary.location());
				}
				case NotEquals -> {
					return new ExprBoolLiteral(leftLit.value() != rightLit.value(), binary.location());
				}
				case GtEq -> {
					return new ExprBoolLiteral(leftLit.value() >= rightLit.value(), binary.location());
				}
				case Gt -> {
					return new ExprBoolLiteral(leftLit.value() > rightLit.value(), binary.location());
				}
				}
			}
			else if (left instanceof ExprBoolLiteral leftLit
			         && right instanceof ExprBoolLiteral rightLit) {
				switch (binary.op()) {
				case And, AndLog -> {
					return new ExprBoolLiteral(leftLit.value() & rightLit.value(), binary.location());
				}
				case Or, OrLog -> {
					return new ExprBoolLiteral(leftLit.value() | rightLit.value(), binary.location());
				}
				case Xor -> {
					return new ExprBoolLiteral(leftLit.value() ^ rightLit.value(), binary.location());
				}
				case Equals -> {
					return new ExprBoolLiteral(leftLit.value() == rightLit.value(), binary.location());
				}
				case NotEquals -> {
					return new ExprBoolLiteral(leftLit.value() != rightLit.value(), binary.location());
				}
				}
			}
		}

		throw new SyntaxException(Messages.expressionNotSupportedInConstant(), expression.location());
	}

	private List<String> getAsmLines() {
		consume(TokenType.L_BRACE);
		final List<String> lines = new ArrayList<>();
		do {
			expectType(TokenType.STRING, null);
			final String s = consumeText();
			lines.add(s);
		}
		while (!isConsume(TokenType.R_BRACE));
		return lines;
	}

	private List<Statement> getStatements() {
		final Statement statement = getStatement();
		if (statement == null) {
			throw new SyntaxException(Messages.expectedStatement(), getLocation());
		}
		return statement instanceof StmtCompound c
				? c.statements()
				: List.of(statement);
	}

	@Nullable
	private Statement getStatement() {
		return switch (token) {
			case IF -> handleIf();
			case FOR -> handleFor();
			case WHILE -> handleWhile();
			case RETURN -> handleReturn();
			case BREAK -> handleBreak();
			case CONTINUE -> handleContinue();
			case L_BRACE -> handleCompound();
			default -> {
				final Location location = getLocation();
				final Statement statement = getVarDeclarationOrExpressionStatement(location);
				//noinspection IfCanBeSwitch
				if (statement == null) {
					yield null;
				}

				if (statement instanceof StmtVarDeclaration
				    || statement instanceof StmtArrayDeclaration) {
					consume(TokenType.SEMI);
					yield statement;
				}

				if (statement instanceof StmtExpr expr) {
					final Expression expression = expr.expression();
					if (expression instanceof ExprFuncCall) {
						consume(TokenType.SEMI);
						yield statement;
					}

					if (expression instanceof ExprBinary binary
					    && binary.op().kind == ExprBinary.OpKind.Assign) {
						consume(TokenType.SEMI);
						yield statement;
					}
				}
				throw new SyntaxException(Messages.expectedStatement(), location);
			}
		};
	}

	@NotNull
	private List<Expression> getCallArgExpressions() {
		final List<Expression> argExpressions = new ArrayList<>();
		while (!isConsume(TokenType.R_PAREN)) {
			final Expression expression = getExpression();
			argExpressions.add(expression);
			if (token != TokenType.R_PAREN) {
				consume(TokenType.COMMA);
			}
		}
		return argExpressions;
	}

	@Nullable
	private Statement getSimpleStatement() {
		final Location location = getLocation();
		final Statement statement = getVarDeclarationOrExpressionStatement(location);
		if (statement == null || statement instanceof StmtVarDeclaration) {
			return statement;
		}

		if (statement instanceof StmtExpr expr
		    && expr.expression() instanceof ExprBinary binary
		    && binary.op().kind == ExprBinary.OpKind.Assign) {
			return statement;
		}

		throw new SyntaxException("Expected var declaration or assignment", location);
	}

	@Nullable
	private Statement getVarDeclarationOrExpressionStatement(Location location) {
		final Expression primary;
		if (token == TokenType.IDENTIFIER) {
			final String identifier1 = consumeIdentifier();
			final String typeString = getTypeString(identifier1);
			if (token == TokenType.IDENTIFIER) {
				final String identifier2 = consumeIdentifier();
				if (isConsume(TokenType.L_BRACKET)) {
					return getArrayDeclaration(typeString, identifier2, location);
				}

				Expression expression = null;
				if (isConsume(TokenType.EQUAL)) {
					expression = getExpression();
				}
				return new StmtVarDeclaration(typeString, identifier2, expression, location);
			}

			primary = getExpressionPrimaryDot(identifier1, location);
		}
		else {
			primary = getExpressionPrimary(location);
			if (primary == null) {
				return null;
			}
		}

		final Expression expression = getExpression(primary, 0);
		return new StmtExpr(expression);
	}

	@NotNull
	private StmtArrayDeclaration getArrayDeclaration(String typeString, String name, Location location) {
		final Expression expression = getExpression();
		final Expression resolvedExpression = resolveConstExpression(expression);
		if (resolvedExpression instanceof ExprIntLiteral literal) {
			final int size = literal.value();
			if (size > 0) {
				consume(TokenType.R_BRACKET);
				return new StmtArrayDeclaration(typeString, name, size, location);
			}
		}

		throw new SyntaxException(Messages.expectedIntegerConstant(), expression.location());
	}

	@NotNull
	private String getTypeString(String identifier) {
		final StringBuilder typeBuilder = new StringBuilder(identifier);
		while (isConsume(TokenType.STAR)) {
			typeBuilder.append("*");
		}
		return typeBuilder.toString();
	}

	private Statement handleCompound() {
		consume(TokenType.L_BRACE);
		final List<Statement> statements = new ArrayList<>();
		while (true) {
			final Statement statement = getStatement();
			if (statement == null) {
				break;
			}

			statements.add(statement);
		}
		consume(TokenType.R_BRACE, Messages.expectedStatement());
		return new StmtCompound(statements);
	}

	@NotNull
	private StmtIf handleIf() {
		final Location location = getLocation();
		consume(TokenType.IF);
		consume(TokenType.L_PAREN);
		final Expression condition = getExpression();
		consume(TokenType.R_PAREN);
		final List<Statement> thenStatements = getStatements();
		List<Statement> elseStatements = List.of();
		if (isConsume(TokenType.ELSE)) {
			elseStatements = getStatements();
		}
		return new StmtIf(condition, thenStatements, elseStatements, location);
	}

	@NotNull
	private Statement handleFor() {
		final Location location = getLocation();
		consume(TokenType.FOR);
		consume(TokenType.L_PAREN);
		final List<Statement> initialization = getCommaSeparatedSimpleStatements();
		consume(TokenType.SEMI);
		final Expression condition;
		if (isConsume(TokenType.SEMI)) {
			condition = new ExprIntLiteral(1, location);
		}
		else {
			condition = getExpression();
			consume(TokenType.SEMI);
		}
		final List<Statement> iterate = getCommaSeparatedSimpleStatements();
		consume(TokenType.R_PAREN);
		final List<Statement> bodyStatements = getStatements();
		if (initialization.isEmpty()) {
			return new StmtLoop(condition, bodyStatements, iterate, location);
		}

		initialization.add(new StmtLoop(condition, bodyStatements, iterate, location));
		return new StmtCompound(initialization);
	}

	@NotNull
	private List<Statement> getCommaSeparatedSimpleStatements() {
		final List<Statement> statements = new ArrayList<>();
		while (true) {
			final Statement statement = getSimpleStatement();
			if (statement != null) {
				statements.add(statement);
				if (token == TokenType.COMMA) {
					consume();
					continue;
				}
			}
			break;
		}
		return statements;
	}

	@NotNull
	private Statement handleWhile() {
		final Location location = getLocation();
		consume(TokenType.WHILE);
		consume(TokenType.L_PAREN);
		final Expression condition = getExpression();
		consume(TokenType.R_PAREN);
		final List<Statement> bodyStatements = getStatements();
		return new StmtLoop(condition, bodyStatements, List.of(), location);
	}

	@NotNull
	private StmtBreakContinue handleBreak() {
		final Location location = getLocation();
		consume(TokenType.BREAK);
		consume(TokenType.SEMI);
		return new StmtBreakContinue(true, location);
	}

	@NotNull
	private StmtBreakContinue handleContinue() {
		final Location location = getLocation();
		consume(TokenType.CONTINUE);
		consume(TokenType.SEMI);
		return new StmtBreakContinue(false, location);
	}

	@NotNull
	private StmtReturn handleReturn() {
		final Location location = getLocation();
		consume(TokenType.RETURN);
		Expression expression = null;
		if (!isConsume(TokenType.SEMI)) {
			expression = getExpression();
			consume(TokenType.SEMI);
		}
		return new StmtReturn(expression, location);
	}

	@NotNull
	private Expression getExpression() {
		return getExpression(0);
	}

	@NotNull
	private Expression getExpression(int minPrecedence) {
		final Location location = getLocation();
		final Expression primary = getExpressionPrimaryNotNull(location);
		return getExpression(primary, minPrecedence);
	}

	@NotNull
	private Expression getExpression(@NotNull Expression left, int minPrecedence) {
		while (true) {
			final int precedence = getPrecedence(token);
			if (precedence <= minPrecedence) {
				return left;
			}

			final Location location = getLocation();
			final TokenType operationToken = token;
			consume();
			final Expression right = getExpression(precedence);
			left = switch (operationToken) {
				case PLUS -> new ExprBinary(ExprBinary.Op.Add, left, right, location);
				case MINUS -> new ExprBinary(ExprBinary.Op.Sub, left, right, location);
				case STAR -> new ExprBinary(ExprBinary.Op.Multiply, left, right, location);
				case SLASH -> new ExprBinary(ExprBinary.Op.Divide, left, right, location);
				case PERCENT -> new ExprBinary(ExprBinary.Op.Mod, left, right, location);
				case LT_LT -> new ExprBinary(ExprBinary.Op.ShiftLeft, left, right, location);
				case GT_GT -> new ExprBinary(ExprBinary.Op.ShiftRight, left, right, location);

				case EQUAL -> new ExprBinary(ExprBinary.Op.Assign, left, right, location);
				case EXCL_EQ -> new ExprBinary(ExprBinary.Op.NotEquals, left, right, location);

				case LT -> new ExprBinary(ExprBinary.Op.Lt, left, right, location);
				case LT_EQ -> new ExprBinary(ExprBinary.Op.LtEq, left, right, location);
				case EQ_EQ -> new ExprBinary(ExprBinary.Op.Equals, left, right, location);
				case GT_EQ -> new ExprBinary(ExprBinary.Op.GtEq, left, right, location);
				case GT -> new ExprBinary(ExprBinary.Op.Gt, left, right, location);

				case AMP -> new ExprBinary(ExprBinary.Op.And, left, right, location);
				case AMP_AMP -> new ExprBinary(ExprBinary.Op.AndLog, left, right, location);
				case PIPE -> new ExprBinary(ExprBinary.Op.Or, left, right, location);
				case PIPE_PIPE -> new ExprBinary(ExprBinary.Op.OrLog, left, right, location);
				case CARET -> new ExprBinary(ExprBinary.Op.Xor, left, right, location);
				default -> throw new IllegalStateException("Unsupported operation " + operationToken);
			};
		}
	}

	@NotNull
	private Expression getExpressionPrimaryNotNull(Location location) {
		final Expression primary = getExpressionPrimary(location);
		if (primary == null) {
			throw new SyntaxException(Messages.expectedExpression(), location);
		}
		return primary;
	}

	@Nullable
	private Expression getExpressionPrimary(Location location) {
		return switch (token) {
			case INT_LITERAL -> new ExprIntLiteral(consumeIntValue(), location);
			case TRUE, FALSE -> {
				final boolean value = token == TokenType.TRUE;
				consume();
				yield new ExprBoolLiteral(value, location);
			}
			case STRING -> new ExprStringLiteral(consumeText(), -1, location);
			case L_PAREN -> getExpressionInParenthesis();
			case IDENTIFIER -> {
				final String identifier = consumeIdentifier();
				yield getExpressionPrimaryDot(identifier, location);
			}
			case AMP -> getUnary(ExprUnary.Op.AddrOf, location);
			case STAR -> getUnary(ExprUnary.Op.Deref, location);
			case MINUS -> getUnary(ExprUnary.Op.Neg, location);
			case TILDE -> getUnary(ExprUnary.Op.Com, location);
			case EXCL -> getUnary(ExprUnary.Op.NotLog, location);
			default -> null;
		};
	}

	@NotNull
	private ExprUnary getUnary(ExprUnary.Op op, Location location) {
		consume();
		final Location exprLocation = getLocation();
		final Expression expression = getExpressionPrimaryNotNull(exprLocation);
		return new ExprUnary(op, expression, location);
	}

	@NotNull
	private Expression getExpressionPrimaryDot(String identifier, Location location) {
		Expression expression = getExpressionPrimary(identifier, location);
		if (isConsume(TokenType.DOT)) {
			final Location memberLocation = getLocation();
			final String member = consumeIdentifier();
			expression = new ExprMemberAccess(expression, member, null, memberLocation);
		}
		return expression;
	}

	@NotNull
	private Expression getExpressionPrimary(String identifier, Location location) {
		if (isConsume(TokenType.L_PAREN)) {
			final List<Expression> args = getCallArgExpressions();
			return new ExprFuncCall(identifier, args, location);
		}

		final Expression constantExpression = constants.get(identifier);
		if (constantExpression != null) {
			if (constantExpression instanceof ExprBoolLiteral literal) {
				return new ExprBoolLiteral(literal.value(), location);
			}
			if (constantExpression instanceof ExprIntLiteral literal) {
				return new ExprIntLiteral(literal.value(), location);
			}
			throw new IllegalStateException(String.valueOf(constantExpression));
		}

		final ExprVarAccess varAccess = new ExprVarAccess(identifier, location);
		if (isConsume(TokenType.L_BRACKET)) {
			final Expression expression = getExpression();
			consume(TokenType.R_BRACKET);
			return new ExprArrayAccess(varAccess, null, expression);
		}
		return varAccess;
	}

	@NotNull
	private Expression getExpressionInParenthesis() {
		consume(TokenType.L_PAREN);
		final Location location = getLocation();
		final Expression primary;
		if (token == TokenType.IDENTIFIER) {
			final String identifier = consumeIdentifier();
			if (isConsume(TokenType.R_PAREN)) {
				final Expression expression = getExpressionPrimaryNotNull(getLocation());
				return ExprCast.cast(identifier, expression, location);
			}

			primary = getExpressionPrimaryDot(identifier, location);
		}
		else {
			primary = getExpressionPrimaryNotNull(location);
		}
		final Expression expression = getExpression(primary, 0);
		consume(TokenType.R_PAREN);
		return expression;
	}

	private int consumeIntValue() {
		final int value = getIntValue();
		consume();
		return value;
	}

	@NotNull
	private String consumeIdentifier() {
		expectType(TokenType.IDENTIFIER, null);
		return consumeText();
	}

	@NotNull
	private String consumeText() {
		final String text = getText();
		consume();
		return text;
	}

	private void expectType(@NotNull TokenType type, @Nullable String message) {
		if (token != type) {
			if (message == null) {
				message = "Expected " + type + " but got " + token;
			}
			throw new SyntaxException(message, getLocation());
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

	private boolean isConsume(@NotNull TokenType type) {
		if (token != type) {
			return false;
		}

		consume();
		return true;
	}

	private void consume(@NotNull TokenType type, @NotNull String errorMessage) {
		expectType(type, errorMessage);
		consume();
	}

	private void consume(@NotNull TokenType type) {
		expectType(type, null);
		consume();
	}

	private void consume() {
		do {
			token = lexer.next();
		}
		while (token == TokenType.WHITESPACE || token == TokenType.COMMENT);
	}

	// see https://en.cppreference.com/w/c/language/operator_precedence
	private static int getPrecedence(TokenType token) {
		return switch (token) {
			case EQUAL -> 1;
			case PIPE_PIPE -> 2;
			case AMP_AMP -> 3;
			case PIPE -> 4;
			case CARET -> 5;
			case AMP -> 6;
			case EQ_EQ, EXCL_EQ -> 7;
			case LT, LT_EQ, GT_EQ, GT -> 8;
			case LT_LT, GT_GT -> 9;
			case PLUS, MINUS -> 10;
			case STAR, SLASH, PERCENT -> 11;
			default -> 0;
		};
	}

	@NotNull
	private static Program parse(IncludeHandler handler) {
		final List<TypeDef> typeDefs = new ArrayList<>();
		final List<Statement> globalVars = new ArrayList<>();
		final List<Function> functions = new ArrayList<>();
		handler.parse(typeDefs::add, globalVars::add, functions::add);
		return new Program(typeDefs, globalVars, functions, List.of(), List.of());
	}

	private interface IncludeHandler {
		void parse(@NotNull String fileName, @NotNull Location location, @NotNull Consumer<TypeDef> typeDefs, @NotNull Consumer<Statement> globalVars, @NotNull Consumer<Function> functions);

		void parse(@NotNull Consumer<TypeDef> typeDefs, @NotNull Consumer<Statement> globalVars, @NotNull Consumer<Function> functions);
	}

	private static final class FileIncludeHandler implements IncludeHandler {
		private final Path file;
		private final FileIncludeHandler parent;
		private final Set<String> defines;

		public FileIncludeHandler(@NotNull Path file, @Nullable FileIncludeHandler parent, @NotNull Set<String> defines) {
			this.file = file;
			this.parent = parent;
			this.defines = defines;
		}

		@Override
		public void parse(@NotNull String fileName, @NotNull Location location, @NotNull Consumer<TypeDef> typeDefs, @NotNull Consumer<Statement> globalVars, @NotNull Consumer<Function> functions) {
			final Path includeFile = file.resolveSibling(fileName);
			if (alreadyIncluded(includeFile)) {
				throw new SyntaxException("File '" + fileName + "' is included recursively", location);
			}

			final FileIncludeHandler handler = new FileIncludeHandler(includeFile, this, defines);
			handler.parse(typeDefs, globalVars, functions);
		}

		public void parse(@NotNull Consumer<TypeDef> typeDefs, @NotNull Consumer<Statement> globalVars, @NotNull Consumer<Function> functions) {
			try (final BufferedReader reader = Files.newBufferedReader(file)) {
				new Parser(new Lexer(() -> {
					try {
						return reader.read();
					}
					catch (IOException ex) {
						throw new UncheckedIOException(ex);
					}
				}), this, defines).parse(typeDefs, globalVars, functions);
			}
			catch (IOException e) {
				throw new UncheckedIOException(e);
			}
		}

		private boolean alreadyIncluded(Path file) {
			for (FileIncludeHandler handler = this; handler != null; handler = handler.parent) {
				if (handler.file.equals(file)) {
					return true;
				}
			}
			return false;
		}
	}
}
