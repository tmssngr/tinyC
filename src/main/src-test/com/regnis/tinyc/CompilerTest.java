package com.regnis.tinyc;

import java.io.*;
import java.nio.file.*;

import org.junit.*;

/**
 * @author Thomas Singer
 */
public class CompilerTest {

	@Test
	public void testArithmetics() throws IOException, InterruptedException {
		compileAndRun("arithmetics.input");
	}

	@Test
	public void testComparison() throws IOException, InterruptedException {
		compileAndRun("comparison.input");
	}

	private void compileAndRun(String fileName) throws IOException, InterruptedException {
		Main.compileAndRun(Path.of("src/main/resources-test", fileName));
	}
}
