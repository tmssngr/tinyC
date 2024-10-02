package com.regnis.tinyc;

import java.io.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public abstract class TextWriter {

	private final BufferedWriter writer;

	public TextWriter(@NotNull BufferedWriter writer) {
		this.writer = writer;
	}

	protected void writeIndentation() throws IOException {
		write("\t");
	}

	protected void writeln() throws IOException {
		writeln("");
	}

	protected void writeln(String text) throws IOException {
		write(text);
		writer.newLine();
	}

	protected void write(String str) throws IOException {
		writer.write(str);
	}
}
