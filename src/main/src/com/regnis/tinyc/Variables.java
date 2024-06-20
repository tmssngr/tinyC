package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;

import java.util.*;

/**
 * @author Thomas Singer
 */
public class Variables {
	public static Variables detectFrom(AstNode root) {
		final Set<String> variableNames = new LinkedHashSet<>();
		processNode(root, variableNames);
		return new Variables(variableNames);
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
		switch (node.type()) {
		case VarLhs -> variableNames.add(node.text());
		case VarRead -> {
			final String text = node.text();
			if (!variableNames.contains(text)) {
				throw new SyntaxException("Unknown variable " + text, node.location());
			}
		}
		}
	}
}
