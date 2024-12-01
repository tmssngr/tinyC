package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;

import java.util.*;

/**
 * @author Thomas Singer
 */
public class UnusedFunctionRemover {

	public static Program removeUnusedFunctions(Program program) {
		final UnusedFunctionRemover remover = new UnusedFunctionRemover(program);
		remover.collectUsedItems();
		return remover.removeUnused();
	}

	private final Map<String, Function> functionMap = new HashMap<>();
	private final Set<String> usedFunctions = new HashSet<>();
	private final Set<String> usedGlobalVars = new HashSet<>();
	private final Set<String> pendingFunctions = new LinkedHashSet<>();
	private final Program program;

	private UnusedFunctionRemover(Program program) {
		this.program = program;
		for (Function function : program.functions()) {
			functionMap.put(function.name(), function);
		}
		pendingFunctions.add("main");
	}

	private void collectUsedItems() {
		while (pendingFunctions.size() > 0) {
			final Iterator<String> iterator = pendingFunctions.iterator();
			final String name = iterator.next();
			iterator.remove();
			final Function function = functionMap.get(name);
			if (function == null) {
				throw new SyntaxException("Function " + name + " was not found", new Location(-1, -1));
			}

			usedFunctions.add(name);
			process(function.statements());
		}
	}

	private Program removeUnused() {
		final List<Statement> globalVars = new ArrayList<>();
		for (Statement statement : program.globalVars()) {
			globalVars.add(statement);
		}

		final List<Function> functions = new ArrayList<>();
		for (Function function : program.functions()) {
			if (usedFunctions.contains(function.name())) {
				functions.add(function);
			}
		}

		final List<Variable> globalVariables = new ArrayList<>();
		for (Variable variable : program.globalVariables()) {
			globalVariables.add(variable);
		}
		return new Program(program.typeDefs(), globalVars, functions, globalVariables, program.stringLiterals());
	}

	private void process(List<Statement> statements) {
		for (Statement statement : statements) {
			process(statement);
		}
	}

	private void process(Statement statement) {
		switch (statement) {
		case StmtCompound compound -> process(compound.statements());
		case StmtExpr expr -> process(expr.expression());
		case StmtIf ifStatement -> {
			process(ifStatement.condition());
			process(ifStatement.thenStatements());
			process(ifStatement.elseStatements());
		}
		case StmtLoop loop -> {
			process(loop.condition());
			process(loop.bodyStatements());
			process(loop.iteration());
		}
		case StmtReturn stmtReturn -> {
			final Expression expression = stmtReturn.expression();
			if (expression != null) {
				process(expression);
			}
		}
		case StmtBreakContinue ignored -> {
		}
		default -> throw new UnsupportedOperationException(statement.getClass().toString());
		}
	}

	private void process(Expression expression) {
		switch (expression) {
		case ExprVarAccess access -> {
			if (access.scope() == VariableScope.global) {
				usedGlobalVars.add(access.varName());
			}
		}
		case ExprArrayAccess access -> {
			process(access.index());
			process(access.varAccess());
		}
		case ExprMemberAccess access -> process(access.expression());
		case ExprBinary binary -> {
			process(binary.left());
			process(binary.right());
		}
		case ExprCast cast -> process(cast.expression());
		case ExprUnary unary -> process(unary.expression());
		case ExprFuncCall call -> {
			for (Expression argExpression : call.argExpressions()) {
				process(argExpression);
			}

			final String name = call.name();
			if (!usedFunctions.contains(name)) {
				pendingFunctions.add(name);
			}
		}
		case ExprStringLiteral ignored -> {
		}
		case ExprIntLiteral ignored -> {
		}
		case ExprBoolLiteral ignored -> {
		}
		default -> throw new UnsupportedOperationException(expression.getClass().toString());
		}
	}
}
