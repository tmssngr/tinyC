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
			variables.processNode(function.statement());
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

	private void processNode(@Nullable Statement statement) {
		switch (statement) {
		case Statement.Simple simpleStatement -> detectFrom(simpleStatement);
		case StmtCompound compound -> {
			for (Statement childStatement : compound.statements()) {
				processNode(childStatement);
			}
		}
		case StmtIf ifStatement -> {
			processNode(ifStatement.thenStatement());
			processNode(ifStatement.elseStatement());
		}
		case StmtWhile whileStatement -> {
			processNode(whileStatement.bodyStatement());
		}
		case StmtFor forStatement -> {
			for (Statement.Simple simpleStatement : forStatement.initialization()) {
				detectFrom(simpleStatement);
			}
			processNode(forStatement.bodyStatement());
			for (Statement.Simple simpleStatement : forStatement.iteration()) {
				detectFrom(simpleStatement);
			}
		}
		case null, default -> {
		}
		}
	}

	private void detectFrom(Statement.Simple statement) {
		if (statement instanceof StmtDeclaration declaration) {
			processDeclaration(declaration);
		}
	}

	private void processDeclaration(StmtDeclaration declaration) {
		names.put(declaration.varName(), new Pair<>(declaration.type(), names.size()));
	}
}
