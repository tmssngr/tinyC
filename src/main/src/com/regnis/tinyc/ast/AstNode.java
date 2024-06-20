package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

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
			case Chain -> left + ", " + right;
			case IfElse -> "if " + left;
			case While -> "while " + left;
			case Add -> left + " + " + right;
			case Sub -> left + " - " + right;
			case Multiply -> left + " * " + right;
			case Divide -> left + " / " + right;
			case Lt -> left + " < " + right;
			case LtEq -> left + " <= " + right;
			case Equals -> left + " == " + right;
			case NotEquals -> left + " != " + right;
			case GtEq -> left + " >= " + right;
			case Gt -> left + " > " + right;
			//noinspection UnnecessaryDefault
			default -> String.valueOf(type);
		};
	}

	public static AstNode chain(AstNode first, AstNode second) {
		return new AstNode(NodeType.Chain, first, second, 0, "", new Location(-1, -1));
	}

	public static AstNode ifElse(AstNode check, AstNode thenElseChain, Location location) {
		return new AstNode(NodeType.IfElse, check, thenElseChain, 0, "", location);
	}

	public static AstNode whileStatement(AstNode condition, AstNode body, Location location) {
		return new AstNode(NodeType.While, condition, body, 0, "", location);
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

	public static AstNode lhs(String name, Location location) {
		return new AstNode(NodeType.VarLhs, null, null, 0, name, location);
	}

	public static AstNode assign(AstNode expression, AstNode lhs, Location location) {
		return binOp(NodeType.Assign, expression, lhs, location);
	}

	public static AstNode add(AstNode left, AstNode right, Location location) {
		return binOp(NodeType.Add, left, right, location);
	}

	public static AstNode sub(AstNode left, AstNode right, Location location) {
		return binOp(NodeType.Sub, left, right, location);
	}

	public static AstNode multiply(AstNode left, AstNode right, Location location) {
		return binOp(NodeType.Multiply, left, right, location);
	}

	public static AstNode divide(AstNode left, AstNode right, Location location) {
		return binOp(NodeType.Divide, left, right, location);
	}

	public static AstNode lt(AstNode left, AstNode right, Location location) {
		return binOp(NodeType.Lt, left, right, location);
	}

	public static AstNode lteq(AstNode left, AstNode right, Location location) {
		return binOp(NodeType.LtEq, left, right, location);
	}

	public static AstNode eqeq(AstNode left, AstNode right, Location location) {
		return binOp(NodeType.Equals, left, right, location);
	}

	public static AstNode neq(AstNode left, AstNode right, Location location) {
		return binOp(NodeType.NotEquals, left, right, location);
	}

	public static AstNode gteq(AstNode left, AstNode right, Location location) {
		return binOp(NodeType.GtEq, left, right, location);
	}

	public static AstNode gt(AstNode left, AstNode right, Location location) {
		return binOp(NodeType.Gt, left, right, location);
	}

	@NotNull
	private static AstNode binOp(NodeType type, AstNode left, AstNode right, Location location) {
		return new AstNode(type, left, right, 0, "", location);
	}
}
