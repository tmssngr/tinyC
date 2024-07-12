package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public class Messages {
	public static String unexpectedToken(TokenType token) {
		return "Unexpected token " + token;
	}

	@NotNull
	public static String expectedLValue() {
		return "Expected expression to be an l-value";
	}

	@NotNull
	public static String operationNotSupportedForTypes(ExprBinary.Op op, Type leftType, Type rightType) {
		return "Operation " + op + " is not supported for " + leftType + " and " + rightType;
	}

	@NotNull
	public static String cantCastFromTo(Type type1, Type type2) {
		return "Can't cast from " + type1 + " to " + type2;
	}

	@NotNull
	public static String functionAlreadDeclaredAt(String name, Location location) {
		return "Function '" + name + "' has already been declared at " + location;
	}

	@NotNull
	public static String functionMustReturnType(@Nullable Type expectedReturnType) {
		return "The function must return type " + expectedReturnType;
	}

	@NotNull
	public static String undeclaredVariable(String varName) {
		return "Undeclared variable '" + varName + "'";
	}

	@NotNull
	public static String returnExpectedExpressionOfType(Type expectedReturnType) {
		return "Expected expression of type '" + expectedReturnType + "'";
	}

	@NotNull
	public static String cantReturnAnythingFromVoidFunction() {
		return "Can't return anything from a void function";
	}

	@NotNull
	public static String undeclaredFunction(String name) {
		return "Undeclared function '" + name + "'";
	}

	@NotNull
	public static String functionNeedsXArgumentsButGotY(String name, int x, int y) {
		return "Function '" + name + "' needs " + x + " arguments, but got " + y;
	}

	@NotNull
	public static String variableAlreadyDeclaredAt(String varName, Location location) {
		return "Variable '" + varName + "' has already been declared at " + location;
	}

	@NotNull
	public static String unknownType(@NotNull String type) {
		return "Unknown type '" + type + "'";
	}

	@NotNull
	public static String expectedPointerButGot(Type type) {
		return "Expected pointer but got '" + type + "'";
	}

	@NotNull
	public static String arraysAreImmutable() {
		return "Array variables are immutable";
	}

	@NotNull
	public static String expectedExpression() {
		return "Expected expression";
	}

	@NotNull
	public static String arrayIndexMustBeInt() {
		return "The index of an array must be an integer value";
	}

	@NotNull
	public static String logicOperatorsOnlySupportedOnBoolean() {
		return "Logic operations are only supported on boolean type";
	}
}
