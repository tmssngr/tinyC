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
	public static String expectedBoolExpression() {
		return "Expected bool expression";
	}

	@NotNull
	public static String expectedIntegerType(Type type) {
		return "Expected integer type, but got " + type;
	}

	@NotNull
	public static String duplicateArgumentName(String name) {
		return "Duplicate definition of argument '" + name + "'";
	}

	@NotNull
	public static String breakContinueOnlyAllowedWithinWhileOrFor() {
		return "'break' and 'continue' are only allowed in 'for' or 'while' loops";
	}

	@NotNull
	public static String addressOfArray() {
		return "The address of an array is not supported";
	}

	@NotNull
	public static String expectedAddressableObject() {
		return "The address-of-operator only works on scalar variables or array elements";
	}

	@NotNull
	public static String expectedRootElement() {
		return "Expected typedef, global variable declaration or function declaration";
	}

	@NotNull
	public static String cantRedefineDefaultTypes() {
		return "Can't redefine default types";
	}

	@NotNull
	public static String typeAlreadyDefined(String name, Location location) {
		return "The type '" + name + "' has already been defined at " + location;
	}

	@NotNull
	public static String memberAlreadyDefinedAt(String name, Location location) {
		return "The member '" + name + "' has already been defined at " + location;
	}

	@NotNull
	public static String expectedStruct(String name) {
		return "Expected struct type, but got '" + name + "'";
	}

	@NotNull
	public static String structDoesNotHaveMember(String struct, String member) {
		return "Type '" + struct + "' does not have member '" + member + "'";
	}
}
