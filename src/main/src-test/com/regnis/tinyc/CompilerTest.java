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

	@Test
	public void testIfElse() throws IOException, InterruptedException {
		compileAndRun("ifelse.input");
	}

	@Test
	public void testWhile() throws IOException, InterruptedException {
		compileAndRun("while.input");
	}

	@Test
	public void testTypes() throws IOException, InterruptedException {
		compileAndRun("types.input");
	}

	private void compileAndRun(String fileName) throws IOException, InterruptedException {
		Compiler.compileAndRun(Path.of("src/main/resources-test", fileName));
	}
}
