package com.regnis.tinyc;

import java.io.*;
import java.nio.file.*;

import org.jetbrains.annotations.*;
import org.junit.*;

/**
 * @author Thomas Singer
 */
public class CompilerTest {

	@Test
	public void testBasics() throws IOException, InterruptedException {
		compileAndRun("basics.c");
	}

	@Test
	public void testArithmetics() throws IOException, InterruptedException {
		compileAndRun("arithmetics.c");
	}

	@Test
	public void testComparison() throws IOException, InterruptedException {
		compileAndRun("comparison.c");
	}

	@Test
	public void testIfElse() throws IOException, InterruptedException {
		compileAndRun("ifelse.c");
	}

	@Test
	public void testWhile() throws IOException, InterruptedException {
		compileAndRun("while.c");
	}

	@Test
	public void testTypes() throws IOException, InterruptedException {
		compileAndRun("types.c");
	}

	@Test
	public void testCall() throws IOException, InterruptedException {
		compileAndRun("call.c");
	}

	@Test
	public void testPointers() throws IOException, InterruptedException {
		compileAndRun("pointers.c");
	}

	@Test
	public void testGlobalVars() throws IOException, InterruptedException {
		compileAndRun("global vars.c");
	}

	@Test
	public void testArrays() throws IOException, InterruptedException {
		compileAndRun("arrays.c");
	}

	@Test
	public void testStrings() throws IOException, InterruptedException {
		compileAndRun("strings.c");
	}

	@Test
	public void testOperators() throws IOException, InterruptedException {
		compileAndRun("operators.c");
	}

	@Test
	public void testLocalVars() throws IOException, InterruptedException {
		compileAndRun("localvars.c");
	}

	@Test
	public void testStructs() throws IOException, InterruptedException {
		compileAndRun("structs.c");
	}

	@Test
	public void testPrintAsciiListing() throws IOException, InterruptedException {
		compileAndRun("print-ascii-listing.c");
	}

	@Test
	public void testRule110() throws IOException, InterruptedException {
		compileAndRun("rule110.c");
	}

	@Test
	public void testPrng() throws IOException, InterruptedException {
		compileAndRun("prng.c");
	}

	@Test
	public void testMine() throws IOException, InterruptedException {
		final Path inputFile = absolutePath("mine.c");
		Compiler.compile(inputFile);
	}

	@Test
	public void testCfgNoReturn() throws IOException, InterruptedException {
		final Path inputFile = absolutePath("cfg-no-return.c");
		Compiler.compile(inputFile);
	}

	@Test
	public void testRegAlloc() throws IOException, InterruptedException {
		final Path inputFile = absolutePath("regalloc.c");
		Compiler.compile(inputFile);
	}

	private void compileAndRun(String fileName) throws IOException, InterruptedException {
		Compiler.compileAndRun(absolutePath(fileName));
	}

	@NotNull
	private Path absolutePath(String fileName) {
		return Path.of("src/main/resources-test", fileName);
	}
}
