package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.io.*;
import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class ProgramWriter {
	private static final String INDENTATION = "\t";

	private final BufferedWriter writer;

	private int indentationLevel;

	public ProgramWriter(@NotNull BufferedWriter writer) {
		this.writer = writer;
	}

	public void write(Program program) throws IOException {
		writeVariables("", program.globalVariables());

		boolean addEmptyLine = false;
		for (Function function : program.functions()) {
			if (addEmptyLine) {
				writeln("");
			}
			writeFunction(function);
			addEmptyLine = true;
		}
	}

	private void writeFunction(Function function) throws IOException {
		write(function.returnTypeNotNull().toString());
		write(" ");
		write(function.name());
		write("(");
		boolean addComma = false;
		for (Function.Arg arg : function.args()) {
			if (addComma) {
				write(", ");
			}
			write(arg.typeNotNull().toString());
			write(" ");
			write(arg.name());
			addComma = true;
		}
		writeln(") {");
		writeVariables(INDENTATION, function.localVars());
		writeStatements(function.statements());
		writeln("}");
	}

	private void writeVariables(String indentation, List<Variable> variables) throws IOException {
		boolean printed = false;
		for (Variable variable : variables) {
			if (variable.scope() == VariableScope.argument) {
				continue;
			}

			printed = true;
			write(indentation);
			write(variable.type().toString());
			write(" ");
			write(variable.name());
			if (variable.isArray()) {
				write("[");
				write(String.valueOf(variable.arraySize()));
				write("]");
			}
			writeln(";");
		}
		if (printed) {
			writeln("");
		}
	}

	private void writeStatements(List<Statement> statements) throws IOException {
		indentationLevel++;
		try {
			for (Statement statement : statements) {
				writeIndentation();
				if (writeStatement(statement)) {
					writeln(";");
				}
			}
		}
		finally {
			indentationLevel--;
		}
	}

	private boolean writeStatement(Statement statement) throws IOException {
		return switch (statement) {
			case StmtExpr expr -> {
				writeExpression(expr.expression());
				yield true;
			}
			case StmtIf stmtIf -> {
				writeIf(stmtIf);
				yield false;
			}
			case StmtLoop loop -> {
				writeLoop(loop);
				yield false;
			}
			case StmtReturn ret -> {
				writeReturn(ret);
				yield true;
			}
			case StmtBreakContinue breakContinue -> {
				writeBreakContinue(breakContinue);
				yield true;
			}
			default -> throw new UnsupportedOperationException(String.valueOf(statement));
		};
	}

	private void writeIndentation() throws IOException {
		for (int i = 0; i < indentationLevel; i++) {
			write(INDENTATION);
		}
	}

	private void writeIf(StmtIf stmtIf) throws IOException {
		write("if (");
		writeExpression(stmtIf.condition());
		writeln(") {");
		writeStatements(stmtIf.thenStatements());
		writeIndentation();
		writeln("}");
		if (stmtIf.elseStatements().size() > 0) {
			writeIndentation();
			writeln("else {");
			writeStatements(stmtIf.elseStatements());
			writeIndentation();
			writeln("}");
		}
	}

	private void writeLoop(StmtLoop loop) throws IOException {
		if (loop.iteration().size() > 0) {
			write("for (; ");
			writeExpression(loop.condition());
			write("; ");
			boolean writeComma = false;
			for (Statement statement : loop.iteration()) {
				if (writeComma) {
					write(", ");
				}
				writeStatement(statement);
				writeComma = true;
			}
		}
		else {
			write("while (");
			writeExpression(loop.condition());
		}
		writeln(") {");
		writeStatements(loop.bodyStatements());
		writeIndentation();
		writeln("}");
	}

	private void writeReturn(StmtReturn ret) throws IOException {
		write("return");
		if (ret.expression() == null) {
			return;
		}

		write(" ");
		writeExpression(ret.expression());
	}

	private void writeBreakContinue(StmtBreakContinue breakContinue) throws IOException {
		if (breakContinue.isBreak()) {
			write("break");
		}
		else {
			write("continue");
		}
	}

	private void writeExpressionMaybeInParentesis(Expression expression) throws IOException {
		final boolean addParentesis = !(expression instanceof ExprVarAccess)
		                              && !(expression instanceof ExprArrayAccess)
		                              && !(expression instanceof ExprIntLiteral);
		if (addParentesis) {
			write("(");
		}
		writeExpression(expression);
		if (addParentesis) {
			write(")");
		}
	}

	private void writeExpression(Expression expression) throws IOException {
		switch (expression) {
		case ExprIntLiteral literal -> write(String.valueOf(literal.value()));
		case ExprBoolLiteral literal -> write(String.valueOf(literal.value()));
		case ExprStringLiteral literal -> write(Utils.escape(literal.text()));
		case ExprBinary binary -> writeBinary(binary);
		case ExprVarAccess access -> write(access.varName());
		case ExprArrayAccess access -> writeArrayAccess(access);
		case ExprMemberAccess access -> writeMemberAccess(access);
		case ExprCast cast -> writeCast(cast);
		case ExprFuncCall call -> writeCall(call);
		case ExprUnary unary -> writeUnary(unary);
		default -> throw new UnsupportedOperationException(expression.toUserString());
		}
	}

	private void writeBinary(ExprBinary binary) throws IOException {
		if (binary.op() == ExprBinary.Op.Assign) {
			writeExpression(binary.left());
			write(" ");
			write(binary.op().toString());
			write(" ");
			writeExpression(binary.right());
			return;
		}

		writeExpressionMaybeInParentesis(binary.left());
		write(" ");
		write(binary.op().toString());
		write(" ");
		writeExpressionMaybeInParentesis(binary.right());
	}

	private void writeUnary(ExprUnary unary) throws IOException {
		write(unary.op().toString());
		writeExpressionMaybeInParentesis(unary.expression());
	}

	private void writeArrayAccess(ExprArrayAccess access) throws IOException {
		write(access.varAccess().varName());
		write("[");
		writeExpression(access.index());
		write("]");
	}

	private void writeMemberAccess(ExprMemberAccess access) throws IOException {
		writeExpression(access.expression());
		write(".");
		write(access.member());
	}

	private void writeCast(ExprCast cast) throws IOException {
		write("(");
		write(cast.typeNotNull().toString());
		write(")");
		final Expression expression = cast.expression();
		writeExpressionMaybeInParentesis(expression);
	}

	private void writeCall(ExprFuncCall call) throws IOException {
		write(call.name());
		write("(");
		boolean writeComma = false;
		for (Expression expression : call.argExpressions()) {
			if (writeComma) {
				write(", ");
			}
			writeExpression(expression);
			writeComma = true;
		}
		write(")");
	}

	private void writeln(String text) throws IOException {
		write(text);
		writer.newLine();
	}

	private void write(String text) throws IOException {
		writer.write(text);
	}
}
