package com.regnis.tinyc.ast;

/**
 * @author Thomas Singer
 */
public record AstNode(NodeType type, AstNode left, AstNode right, int value, String name) {
	public static AstNode intLiteral(int value) {
		return new AstNode(NodeType.IntLit, null, null, value, "");
	}

	public static AstNode assign(AstNode expression, AstNode lhs) {
		return new AstNode(NodeType.Assign, expression, lhs, 0, "");
	}

	public static AstNode add(AstNode left, AstNode right) {
		return new AstNode(NodeType.Add, left, right, 0, "");
	}

	public static AstNode sub(AstNode left, AstNode right) {
		return new AstNode(NodeType.Sub, left, right, 0, "");
	}

	public static AstNode multiply(AstNode left, AstNode right) {
		return new AstNode(NodeType.Multiply, left, right, 0, "");
	}

	public static AstNode divide(AstNode left, AstNode right) {
		return new AstNode(NodeType.Divide, left, right, 0, "");
	}

	public static AstNode lhs(String name) {
		return new AstNode(NodeType.VarAssign, null, null, 0, name);
	}
}
