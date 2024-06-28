package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record Expression(NodeType type, Expression left, Expression right, int value, String text, Location location) {

	@Override
	public String toString() {
		return switch (type) {
			case IntLit -> String.valueOf(value);
			case VarRead -> text;
			case Assign -> right + " := " + left;
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

	public static Expression intLiteral(int value, Location location) {
		return new Expression(NodeType.IntLit, null, null, value, "", location);
	}

	public static Expression varRead(String text, Location location) {
		return new Expression(NodeType.VarRead, null, null, 0, text, location);
	}

	public static Expression add(Expression left, Expression right, Location location) {
		return binOp(NodeType.Add, left, right, location);
	}

	public static Expression sub(Expression left, Expression right, Location location) {
		return binOp(NodeType.Sub, left, right, location);
	}

	public static Expression multiply(Expression left, Expression right, Location location) {
		return binOp(NodeType.Multiply, left, right, location);
	}

	public static Expression divide(Expression left, Expression right, Location location) {
		return binOp(NodeType.Divide, left, right, location);
	}

	public static Expression lt(Expression left, Expression right, Location location) {
		return binOp(NodeType.Lt, left, right, location);
	}

	public static Expression lteq(Expression left, Expression right, Location location) {
		return binOp(NodeType.LtEq, left, right, location);
	}

	public static Expression eqeq(Expression left, Expression right, Location location) {
		return binOp(NodeType.Equals, left, right, location);
	}

	public static Expression neq(Expression left, Expression right, Location location) {
		return binOp(NodeType.NotEquals, left, right, location);
	}

	public static Expression gteq(Expression left, Expression right, Location location) {
		return binOp(NodeType.GtEq, left, right, location);
	}

	public static Expression gt(Expression left, Expression right, Location location) {
		return binOp(NodeType.Gt, left, right, location);
	}

	@NotNull
	private static Expression binOp(NodeType type, Expression left, Expression right, Location location) {
		return new Expression(type, left, right, 0, "", location);
	}
}
