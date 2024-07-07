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
		for (StmtVarDeclaration globalVar : program.globalVars()) {
			variables.processDeclaration(globalVar);
		}
		for (Function function : program.functions()) {
			variables.processStatement(function.statement());
		}
		return variables;
	}

	private final Map<String, Pair<Type, Integer>> names = new LinkedHashMap<>();

	private Variables() {
	}

	public List<String> getVarNames() {
		final List<String> strings = new ArrayList<>();
		for (Map.Entry<String, Pair<Type, Integer>> entry : names.entrySet()) {
			strings.add(entry.getKey());
		}
		return strings;
	}

	@NotNull
	public Pair<Type, Integer> get(String name) {
		return names.get(name);
	}

	public int count() {
		return names.size();
	}

	private void processStatement(@Nullable Statement statement) {
		switch (statement) {
		case StmtVarDeclaration declaration -> processDeclaration(declaration);
		case StmtCompound compound -> processStatements(compound.statements());
		case StmtIf ifStatement -> {
			processStatement(ifStatement.thenStatement());
			processStatement(ifStatement.elseStatement());
		}
		case StmtWhile whileStatement -> {
			processStatement(whileStatement.bodyStatement());
		}
		case StmtFor forStatement -> {
			processStatements(forStatement.initialization());
			processStatement(forStatement.bodyStatement());
			processStatements(forStatement.iteration());
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

	private void processDeclaration(StmtVarDeclaration declaration) {
		names.put(declaration.varName(), new Pair<>(declaration.type(), names.size()));
	}
}
