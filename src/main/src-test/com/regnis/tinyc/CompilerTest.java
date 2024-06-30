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
		compileAndRun("00 arithmetics.input");
	}

	@Test
	public void testComparison() throws IOException, InterruptedException {
		compileAndRun("01 comparison.input");
	}

	@Test
	public void testIfElse() throws IOException, InterruptedException {
		compileAndRun("02 ifelse.input");
	}

	@Test
	public void testWhile() throws IOException, InterruptedException {
		compileAndRun("03 while.input");
	}

	@Test
	public void testTypes() throws IOException, InterruptedException {
		compileAndRun("04 types.input");
	}

	@Test
	public void testCall() throws IOException, InterruptedException {
		compileAndRun("05 call.input");
	}

	@Test
	public void testPointers() throws IOException, InterruptedException {
		compileAndRun("06 pointers.input");
	}

	@Test
	public void testGlobalVars() throws IOException, InterruptedException {
		compileAndRun("07 global vars.input");
	}

	private void compileAndRun(String fileName) throws IOException, InterruptedException {
		Compiler.compileAndRun(Path.of("src/main/resources-test", fileName));
	}
}
