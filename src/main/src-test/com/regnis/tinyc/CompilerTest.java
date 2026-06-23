package com.regnis.tinyc;

import java.io.*;
import java.nio.file.*;

import org.jetbrains.annotations.*;
import org.junit.*;

import static org.junit.Assert.assertEquals;

/**
 * @author Thomas Singer
 */
public class CompilerTest {

	@Test
	public void testBasics() throws IOException, InterruptedException {
		assertEquals("""
				             01234
				             """, compileAndRun("basics.c"));
	}

	@Test
	public void testArithmetics() throws IOException, InterruptedException {
		assertEquals("""
				             485
				             21
				             0
				             100
				             232
				             5
				             2
				             4
				             """, compileAndRun("arithmetics.c"));
	}

	@Test
	public void testComparison() throws IOException, InterruptedException {
		assertEquals("""
				             < (signed)
				             1
				             0
				             < (unsigned)
				             1
				             0
				             <= (signed)
				             1
				             0
				             <= (unsigned)
				             1
				             0
				             ==
				             0
				             0
				             !=
				             1
				             1
				             >= (signed)
				             0
				             1
				             >= (unsigned)
				             0
				             1
				             > (signed)
				             0
				             1
				             > (unsigned)
				             0
				             1
				             """, compileAndRun("comparison.c"));
	}

	@Test
	public void testIfElse() throws IOException, InterruptedException {
		assertEquals("""
				             1
				             """, compileAndRun("ifelse.c"));
	}

	@Test
	public void testWhile() throws IOException, InterruptedException {
		assertEquals("""
				             5
				             4
				             3
				             2
				             1
				             0
				             1
				             2
				             3
				             4
				             """, compileAndRun("while.c"));
	}

	@Test
	public void testTypes() throws IOException, InterruptedException {
		assertEquals("""
				             250
				             251
				             252
				             253
				             254
				             255
				             0
				             1
				             4
				             """, compileAndRun("types.c"));
	}

	@Test
	public void testCall() throws IOException, InterruptedException {
		assertEquals("""
				             1
				             2
				             3
				             4
				             5
				             """, compileAndRun("call.c"));
	}

	@Test
	public void testPointers() throws IOException, InterruptedException {
		assertEquals("""
				             10
				             9
				             8
				             """, compileAndRun("pointers.c"));
	}

	@Test
	public void testGlobalVars() throws IOException, InterruptedException {
		assertEquals("""
				             63
				             63
				             """, compileAndRun("global vars.c"));
	}

	@Test
	public void testArrays() throws IOException, InterruptedException {
		assertEquals("""
				             35
				             """, compileAndRun("arrays.c"));
	}

	@Test
	public void testStrings() throws IOException, InterruptedException {
		assertEquals("""
				             hello world
				             12
				             ello world
				             104
				             """, compileAndRun("strings.c"));
	}

	@Test
	public void testOperators() throws IOException, InterruptedException {
		assertEquals("""
				             Bit-&:
				             0
				             0
				             0
				             1

				             Bit-|:
				             0
				             1
				             1
				             1

				             Bit-^:
				             0
				             2
				             1
				             3

				             Logic-&&:
				             0
				             0
				             0
				             1

				             Logic-||:
				             0
				             1
				             1
				             1

				             Logic-!:
				             1
				             0

				             misc:
				             3
				             1
				             0
				             65535
				             65535
				             254
				             """, compileAndRun("operators.c"));
	}

	@Test
	public void testLocalVars() throws IOException, InterruptedException {
		assertEquals("""
				             10
				             """, compileAndRun("localvars.c"));
	}

	@Test
	public void testStructs() throws IOException, InterruptedException {
		assertEquals("""
				             1
				             2
				             1
				             """, compileAndRun("structs.c"));
	}

	@Test
	public void testPrintAsciiListing() throws IOException, InterruptedException {
		assertEquals("""
				              x 01234567 89ABCDEF
				             20  !"#$%&' ()*+,-./
				             30 01234567 89:;<=>?
				             40 @ABCDEFG HIJKLMNO
				             50 PQRSTUVW XYZ[\\]^_
				             60 `abcdefg hijklmno
				             70 pqrstuvw xyz{|}~
				             """, compileAndRun("print-ascii-listing.c"));
	}

	@Test
	public void testRule110() throws IOException, InterruptedException {
		assertEquals("""
				             |                             *|
				             |                            **|
				             |                           ***|
				             |                          ** *|
				             |                         *****|
				             |                        **   *|
				             |                       ***  **|
				             |                      ** * ***|
				             |                     ******* *|
				             |                    **     ***|
				             |                   ***    ** *|
				             |                  ** *   *****|
				             |                 *****  **   *|
				             |                **   * ***  **|
				             |               ***  **** * ***|
				             |              ** * **  ***** *|
				             |             ******** **   ***|
				             |            **      ****  ** *|
				             |           ***     **  * *****|
				             |          ** *    *** ****   *|
				             |         *****   ** ***  *  **|
				             |        **   *  ***** * ** ***|
				             |       ***  ** **   ******** *|
				             |      ** * ******  **      ***|
				             |     *******    * ***     ** *|
				             |    **     *   **** *    *****|
				             |   ***    **  **  ***   **   *|
				             |  ** *   *** *** ** *  ***  **|
				             | *****  ** *** ****** ** * ***|
				             """, compileAndRun("rule110.c"));
	}

	@Test
	public void testPrng() throws IOException, InterruptedException {
		assertEquals("""
				             9
				             239
				             147
				             212
				             45
				             64
				             9
				             69
				             191
				             108
				             60
				             84
				             156
				             112
				             48
				             39
				             147
				             120
				             197
				             13
				             13
				             172
				             247
				             209
				             194
				             53
				             160
				             249
				             146
				             26
				             25
				             45
				             147
				             8
				             14
				             23
				             132
				             247
				             163
				             53
				             68
				             213
				             20
				             217
				             139
				             76
				             206
				             134
				             89
				             54
				             """, compileAndRun("prng.c"));
	}

	@Test
	public void testFibonacci() throws IOException, InterruptedException {
		assertEquals("""
				             1
				             1
				             2
				             3
				             5
				             8
				             13
				             21
				             34
				             55
				             89
				             144
				             233
				             377
				             610
				             987
				             """, compileAndRun("fibonacci.c"));
	}

	@Test
	public void testUnused() throws IOException, InterruptedException {
		assertEquals("", compileAndRun("unused.c"));
	}

	@Test
	public void testCallingConvention() throws IOException, InterruptedException {
		assertEquals("""
				             1
				             2
				             3
				             4
				             5
				             6
				             7
				             8
				             36
				             """, compileAndRun("calling-convention.c"));
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

	@NotNull
	private static Path absolutePath(String fileName) {
		return Path.of("src/main/resources-test/compiler", fileName);
	}

	private static String compileAndRun(String fileName) throws IOException, InterruptedException {
		final Path inputFile = absolutePath(fileName);
		final Path outputFile = Utils.replaceExtensionWith(inputFile, "", ".out");
		final Path exeFile = Compiler.compile(inputFile);
		return launchExe(exeFile, outputFile);
	}

	private static String launchExe(Path exeFile, Path outputFile) throws IOException, InterruptedException {
		final ProcessBuilder processBuilder = new ProcessBuilder(exeFile.toString());
		processBuilder.redirectOutput(outputFile.toFile());
		processBuilder.redirectError(ProcessBuilder.Redirect.INHERIT);
		final int result = Utils.execute(processBuilder);
		assertEquals(0, result);

		return Files.readString(outputFile);
	}
}
