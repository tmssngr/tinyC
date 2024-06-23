package com.regnis.tinyc;

import java.io.*;
import java.nio.file.*;

/**
 * @author Thomas Singer
 */
public class Main {

	public static void main(String[] args) throws IOException, InterruptedException {
		if (args.length != 1) {
			return;
		}

		final Path inputFile = Path.of(args[0]);
		Compiler.compileAndRun(inputFile, null);
	}
}
