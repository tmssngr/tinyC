package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public class Variables {

	public static Variables detectFrom(Program program) {
		final Variables variables = new Variables();
		for (StmtDeclaration globalVar : program.globalVars()) {
			variables.processDeclaration(globalVar);
		}
		for (Function function : program.functions()) {
			variables.processStatement(function.statement());
		}
		return variables;
	}

	private final Map<String, Variable> names = new LinkedHashMap<>();
	private final Map<String, Integer> stringLiterals = new LinkedHashMap<>();

	private Variables() {
	}

	@NotNull
	public List<String> getVarNames() {
		final List<String> strings = new ArrayList<>();
		for (Map.Entry<String, Variable> entry : names.entrySet()) {
			strings.add(entry.getKey());
		}
		return Collections.unmodifiableList(strings);
	}

	@NotNull
	public Variable get(@NotNull String name) {
		return names.get(name);
	}

	@NotNull
	public List<String> getStringLiterals() {
		return Collections.unmodifiableList(new ArrayList<>(stringLiterals.keySet()));
	}

	public int getStringIndex(@NotNull ExprStringLiteral literal) {
		return stringLiterals.get(literal.text());
	}

	public int count() {
		return names.size();
	}

	private void processStatement(@Nullable Statement statement) {
		switch (statement) {
		case StmtDeclaration declaration -> processDeclaration(declaration);
		case StmtCompound compound -> processStatements(compound.statements());
		case StmtIf ifStatement -> {
			processExpression(ifStatement.condition());
			processStatement(ifStatement.thenStatement());
			processStatement(ifStatement.elseStatement());
		}
		case StmtWhile whileStatement -> {
			processExpression(whileStatement.condition());
			processStatement(whileStatement.bodyStatement());
		}
		case StmtFor forStatement -> {
			processExpression(forStatement.condition());
			processStatements(forStatement.initialization());
			processStatement(forStatement.bodyStatement());
			processStatements(forStatement.iteration());
		}
		case StmtExpr expr -> processExpression(expr.expression());
		case StmtReturn stmtReturn -> {
			final Expression expression = stmtReturn.expression();
			if (expression != null) {
				processExpression(expression);
			}
		}
		case null, default -> {
		}
		}
	}

	private void processStatements(List<Statement> compound) {
		for (Statement childStatement : compound) {
			processStatement(childStatement);
		}
	}

	private void processDeclaration(StmtDeclaration declaration) {
		final int index = names.size();
		if (declaration instanceof StmtVarDeclaration varDeclaration) {
			names.put(varDeclaration.varName(), new Variable(varDeclaration.type(), index, 0));
			processExpression(varDeclaration.expression());
		}
		else if (declaration instanceof StmtArrayDeclaration arrayDeclaration) {
			names.put(arrayDeclaration.varName(), new Variable(arrayDeclaration.type(), index, arrayDeclaration.size()));
		}
		else {
			throw new UnsupportedOperationException();
		}
	}

	private void processExpression(@NotNull Expression expression) {
		switch (expression) {
		case ExprStringLiteral stringLiteral -> stringLiterals.put(stringLiteral.text(), stringLiterals.size());
		case ExprCast cast -> processExpression(cast.expression());
		case ExprUnary deref -> processExpression(deref.expression());
		case ExprBinary binary -> {
			processExpression(binary.left());
			processExpression(binary.right());
		}
		case ExprFuncCall funcCall -> {
			for (Expression argExpression : funcCall.argExpressions()) {
				processExpression(argExpression);
			}
		}
		default -> {
		}
		}
	}

	public record Variable(Type type, int index, int count) {
		public boolean isScalar() {
			return count == 0;
		}
	}
}
