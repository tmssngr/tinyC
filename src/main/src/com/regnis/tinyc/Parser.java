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

	@NotNull
	public Statement getStatementNotNull() {
		final Statement statement = getStatement();
		if (statement == null) {
			throw new SyntaxException(Messages.unexpectedToken(token), getLocation());
		}
		return statement;
	}

	@NotNull
	public Program parse() {
		final List<Function> functions = new ArrayList<>();
		final List<StmtDeclaration> globalVars = new ArrayList<>();
		while (token != TokenType.EOF) {
			final Location location = getLocation();
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
				final Statement statement = getStatementNotNull();
				functions.add(new Function(typeString, name, args, statement, location));
				continue;
			}

			if (isConsume(TokenType.EQUAL)) {
				final Expression expression = getExpression();
				consume(TokenType.SEMI);
				globalVars.add(new StmtVarDeclaration(typeString, name, expression, location));
				continue;
			}
			if (isConsume(TokenType.SEMI)) {
				globalVars.add(new StmtVarDeclaration(typeString, name, new ExprIntLiteral(0, location), location));
				continue;
			}
			if (isConsume(TokenType.L_BRACKET)) {
				final StmtArrayDeclaration array = getArrayDeclaration(typeString, name, location);
				consume(TokenType.SEMI);
				globalVars.add(array);
				continue;
			}

			throw new SyntaxException("Expected method or global variable declaration", location);
		}
		return new Program(globalVars, functions);
	}

	@Nullable
	private Statement getStatement() {
		return switch (token) {
			case FOR -> handleFor();
			case IF -> handleIf();
			case RETURN -> handleReturn();
			case WHILE -> handleWhile();
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
				throw new SyntaxException("Unexpected expression", location);
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

				final Expression expression;
				if (isConsume(TokenType.EQUAL)) {
					expression = getExpression();
				}
				else {
					expression = new ExprIntLiteral(0, location);
				}
				return new StmtVarDeclaration(typeString, identifier2, expression, location);
			}

			primary = getExpressionPrimary(identifier1, location);
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
		final int size = consumeIntValue();
		if (size <= 0) {
			throw new SyntaxException("Arrays need a size > 0", location);
		}
		consume(TokenType.R_BRACKET);
		return new StmtArrayDeclaration(typeString, name, size, location);
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
		consume(TokenType.R_BRACE);
		return new StmtCompound(statements);
	}

	@NotNull
	private StmtIf handleIf() {
		final Location location = getLocation();
		consume(TokenType.IF);
		final Expression condition = getExpressionInParenthesis();
		final Statement thenStatement = getStatementNotNull();
		Statement elseStatements = null;
		if (isConsume(TokenType.ELSE)) {
			elseStatements = getStatementNotNull();
		}
		return new StmtIf(condition, thenStatement, elseStatements, location);
	}

	@NotNull
	private StmtFor handleFor() {
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
		final Statement body = getStatementNotNull();
		return new StmtFor(initialization, condition, body, iterate, location);
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
	private StmtWhile handleWhile() {
		final Location location = getLocation();
		consume(TokenType.WHILE);
		final Expression condition = getExpressionInParenthesis();
		final Statement bodyStatement = getStatementNotNull();
		return new StmtWhile(condition, bodyStatement, location);
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
			throw new SyntaxException(Messages.unexpectedToken(token), location);
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
			case STRING -> new ExprStringLiteral(consumeText(), location);
			case L_PAREN -> getExpressionInParenthesis();
			case IDENTIFIER -> {
				final String identifier = consumeIdentifier();
				yield getExpressionPrimary(identifier, location);
			}
			case AMP -> {
				consume(TokenType.AMP);
				final String name = consumeIdentifier();
				Expression arrayIndex = null;
				if (isConsume(TokenType.L_BRACKET)) {
					arrayIndex = getExpression();
					consume(TokenType.R_BRACKET);
				}
				yield new ExprAddrOf(name, arrayIndex, location);
			}
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
	private Expression getExpressionPrimary(String identifier, Location location) {
		if (isConsume(TokenType.L_PAREN)) {
			final List<Expression> args = getCallArgExpressions();
			return new ExprFuncCall(identifier, args, location);
		}
		if (isConsume(TokenType.L_BRACKET)) {
			final Expression expression = getExpression();
			consume(TokenType.R_BRACKET);
			return ExprVarAccess.array(identifier, expression, location);
		}
		return ExprVarAccess.scalar(identifier, location);
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

			primary = getExpressionPrimary(identifier, location);
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

	private boolean isConsume(@NotNull TokenType type) {
		if (token != type) {
			return false;
		}

		consume();
		return true;
	}

	private void consume(@NotNull TokenType type) {
		expectType(type);
		consume();
	}

	private void consume() {
		do {
			token = lexer.next();
//			System.out.println(token);
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
			case PLUS, MINUS -> 9;
			case STAR, SLASH -> 10;
			default -> 0;
		};
	}
}
