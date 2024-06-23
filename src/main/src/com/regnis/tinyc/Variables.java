package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;

import java.util.*;

/**
 * @author Thomas Singer
 */
public class Variables {

	public static Variables detectFrom(Statement statement) {
		final Set<String> variableNames = new LinkedHashSet<>();
		processNode(statement, variableNames);
		return new Variables(variableNames);
	}

	private static void processNode(Statement statement, Set<String> variableNames) {
		if (statement instanceof SimpleStatement simpleStatement) {
			detectFrom(simpleStatement, variableNames);
		}
		else if (statement instanceof Statement.Compound compound) {
			for (Statement childStatement : compound.statements()) {
				processNode(childStatement, variableNames);
			}
		}
		else if (statement instanceof Statement.Print print) {
			processNode(print.expression(), variableNames);
		}
		else if (statement instanceof Statement.If ifStatement) {
			processNode(ifStatement.condition(), variableNames);
			processNode(ifStatement.thenStatement(), variableNames);
			processNode(ifStatement.elseStatement(), variableNames);
		}
		else if (statement instanceof Statement.While whileStatement) {
			processNode(whileStatement.condition(), variableNames);
			processNode(whileStatement.bodyStatement(), variableNames);
		}
		else if (statement instanceof Statement.For forStatement) {
			for (SimpleStatement simpleStatement : forStatement.initialization()) {
				detectFrom(simpleStatement, variableNames);
			}
			processNode(forStatement.condition(), variableNames);
			processNode(forStatement.bodyStatement(), variableNames);
			for (SimpleStatement simpleStatement : forStatement.iteration()) {
				detectFrom(simpleStatement, variableNames);
			}
		}
		else {
			throw new UnsupportedOperationException(statement.toString());
		}
	}

	private static void detectFrom(SimpleStatement statement, Set<String> variableNames) {
		if (statement instanceof SimpleStatement.Assign assign) {
			processNode(assign.expression(), variableNames);
			variableNames.add(assign.varName());
		}
		else {
			throw new UnsupportedOperationException(statement.toString());
		}
	}

	private final List<String> names;

	private Variables(Set<String> names) {
		this.names = new ArrayList<>(names);
	}

	public int indexOf(String name) {
		return names.indexOf(name);
	}

	public int count() {
		return names.size();
	}

	private static void processNode(AstNode node, Set<String> variableNames) {
		if (node == null) {
			return;
		}

		processNode(node.left(), variableNames);
		processNode(node.right(), variableNames);
		if (node.type() == NodeType.VarRead) {
			final String text = node.text();
			if (!variableNames.contains(text)) {
				throw new SyntaxException("Unknown variable " + text, node.location());
			}
		}
	}
}
