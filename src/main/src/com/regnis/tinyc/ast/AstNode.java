package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

/**
 * @author Thomas Singer
 */
public record AstNode(NodeType type, AstNode left, AstNode right, int value, String text, Location location) {

	@Override
	public String toString() {
		return switch (type) {
			case IntLit -> String.valueOf(value);
			case VarRead -> text;
			case Print -> "print " + left;
			case VarLhs -> "@" + text;
			case Assign -> right + " := " + left;
			case Add -> left + " + " + right;
			case Sub -> left + " - " + right;
			case Multiply -> left + " * " + right;
			case Divide -> left + " / " + right;
			//noinspection UnnecessaryDefault
			default -> String.valueOf(type);
		};
	}

	public static AstNode intLiteral(int value, Location location) {
		return new AstNode(NodeType.IntLit, null, null, value, "", location);
	}

	public static AstNode varRead(String text, Location location) {
		return new AstNode(NodeType.VarRead, null, null, 0, text, location);
	}

	public static AstNode print(AstNode expression, Location location) {
		return new AstNode(NodeType.Print, expression, null, 0, "", location);
	}

	public static AstNode assign(AstNode expression, AstNode lhs, Location location) {
		return new AstNode(NodeType.Assign, expression, lhs, 0, "", location);
	}

	public static AstNode add(AstNode left, AstNode right, Location location) {
		return new AstNode(NodeType.Add, left, right, 0, "", location);
	}

	public static AstNode sub(AstNode left, AstNode right, Location location) {
		return new AstNode(NodeType.Sub, left, right, 0, "", location);
	}

	public static AstNode multiply(AstNode left, AstNode right, Location location) {
		return new AstNode(NodeType.Multiply, left, right, 0, "", location);
	}

	public static AstNode divide(AstNode left, AstNode right, Location location) {
		return new AstNode(NodeType.Divide, left, right, 0, "", location);
	}

	public static AstNode lhs(String name, Location location) {
		return new AstNode(NodeType.VarLhs, null, null, 0, name, location);
	}
}
