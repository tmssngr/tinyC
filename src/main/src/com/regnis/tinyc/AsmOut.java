package com.regnis.tinyc;

import com.regnis.tinyc.ir.*;

import java.io.*;
import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public abstract class AsmOut {
	public abstract void write(@NotNull IRProgram program) throws IOException;

	private static final String INDENTATION = "        ";

	private final BufferedWriter writer;

	@SuppressWarnings("unused") private boolean debug;

	protected AsmOut(@NotNull BufferedWriter writer) {
		this.writer = writer;
	}

	protected final void writeAsm(List<String> asmLines) throws IOException {
		for (String line : asmLines) {
			writeLines(line, line.contains(":") ? "" : INDENTATION);
		}
	}

	protected final void writeLines(String text, @Nullable String leading) throws IOException {
		final String[] lines = text.split("\\r?\\n");
		for (String line : lines) {
			if (leading != null && line.length() > 0) {
				write(leading);
			}
			write(line);
			writeNL();
		}
	}

	protected final void writeNL() throws IOException {
		write(System.lineSeparator());
	}

	private void write(String text) throws IOException {
		writer.write(text);
		if (debug) {
			System.out.print(text);
		}
	}

	protected final void writeLabel(String label) throws IOException {
		write(label + ":");
		writeNL();
	}

	protected final void writeComment(String s) throws IOException {
		writeIndented("; " + s);
	}

	protected final void writeIndented(String text) throws IOException {
		writeLines(text, INDENTATION);
	}

	protected final void writeLines(String text) throws IOException {
		writeLines(text, null);
	}
}
