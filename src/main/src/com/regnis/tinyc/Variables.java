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

	private Variables() {
	}

	public List<String> getVarNames() {
		final List<String> strings = new ArrayList<>();
		for (Map.Entry<String, Variable> entry : names.entrySet()) {
			strings.add(entry.getKey());
		}
		return strings;
	}

	@NotNull
	public Variable get(String name) {
		return names.get(name);
	}

	public int count() {
		return names.size();
	}

	private void processStatement(@Nullable Statement statement) {
		switch (statement) {
		case StmtDeclaration declaration -> processDeclaration(declaration);
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

	private void processDeclaration(StmtDeclaration declaration) {
		final int index = names.size();
		if (declaration instanceof StmtVarDeclaration varDeclaration) {
			names.put(varDeclaration.varName(), new Variable(varDeclaration.type(), index, 1));
		}
		else if (declaration instanceof StmtArrayDeclaration arrayDeclaration) {
			names.put(arrayDeclaration.varName(), new Variable(arrayDeclaration.type(), index, arrayDeclaration.size()));
		}
		else {
			throw new UnsupportedOperationException();
		}
	}

	public record Variable(Type type, int index, int count) {
	}
}
