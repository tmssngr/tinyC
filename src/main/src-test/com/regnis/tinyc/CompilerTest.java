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
		compileAndRun("00 basics.c");
	}

	@Test
	public void testArithmetics() throws IOException, InterruptedException {
		compileAndRun("00 arithmetics.c");
	}

	@Test
	public void testComparison() throws IOException, InterruptedException {
		compileAndRun("01 comparison.c");
	}

	@Test
	public void testIfElse() throws IOException, InterruptedException {
		compileAndRun("02 ifelse.c");
	}

	@Test
	public void testWhile() throws IOException, InterruptedException {
		compileAndRun("03 while.c");
	}

	@Test
	public void testTypes() throws IOException, InterruptedException {
		compileAndRun("04 types.c");
	}

	@Test
	public void testCall() throws IOException, InterruptedException {
		compileAndRun("05 call.c");
	}

	@Test
	public void testPointers() throws IOException, InterruptedException {
		compileAndRun("06 pointers.c");
	}

	@Test
	public void testGlobalVars() throws IOException, InterruptedException {
		compileAndRun("07 global vars.c");
	}

	@Test
	public void testArrays() throws IOException, InterruptedException {
		compileAndRun("08 arrays.c");
	}

	@Test
	public void testStrings() throws IOException, InterruptedException {
		compileAndRun("09 strings.c");
	}

	@Test
	public void testOperators() throws IOException, InterruptedException {
		compileAndRun("10 operators.c");
	}

	@Test
	public void testLocalVars() throws IOException, InterruptedException {
		compileAndRun("11 localvars.c");
	}

	@Test
	public void testStructs() throws IOException, InterruptedException {
		compileAndRun("12 structs.c");
	}

	@Test
	public void testInclude() throws IOException, InterruptedException {
		compileAndRun("13 include.c");
	}

	@Test
	public void testPrintAsciiListing() throws IOException, InterruptedException {
		compileAndRun("14 print-ascii-listing.c");
	}

	@Test
	public void testRule110() throws IOException, InterruptedException {
		compileAndRun("15 rule110.c");
	}

	@Test
	public void testCfgNoReturn() throws IOException, InterruptedException {
		final Path inputFile = absolutePath("16 cfg-no-return.c");
		Compiler.compile(inputFile);
	}

	@Test
	public void testSpill() throws IOException, InterruptedException {
		compileAndRun("17 spill.c");
	}

	@Test
	public void testPrng() throws IOException, InterruptedException {
		compileAndRun("18 prng.c");
	}

	@Test
	public void testMine() throws IOException, InterruptedException {
		final Path inputFile = absolutePath("19 mine.c");
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
