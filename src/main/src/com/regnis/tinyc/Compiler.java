package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.io.*;
import java.nio.file.*;
import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public class Compiler {

	public static void main(String[] args) throws IOException, InterruptedException {
		if (args.length != 1) {
			System.out.println("file.c is missing");
			return;
		}

		compile(Paths.get(args[0]));
	}

	public static void compileAndRun(@NotNull Path inputFile) throws IOException, InterruptedException {
		final Path outputFile = useExtension(inputFile, ".out");
		compileAndRun(inputFile, outputFile);
	}

	public static void compileAndRun(@NotNull Path inputFile, @Nullable Path outputFile) throws IOException, InterruptedException {
		final Path exeFile = compile(inputFile);
		launchExe(exeFile, outputFile);
	}

	@NotNull
	private static Path compile(@NotNull Path inputFile) throws IOException, InterruptedException {
		final Program parsedProgram = Parser.parse(inputFile, Set.of("X86_64"));

		final TypeChecker checker = new TypeChecker(Type.I64);
		final Program typedProgram = checker.check(parsedProgram);

		Program program = UnusedFunctionRemover.removeUnusedFunctions(typedProgram);

		final Path astFile = useExtension(inputFile, ".ast");
		final Path astSimpleFile = useExtension(inputFile, ".asts");
		final Path irFile = useExtension(inputFile, ".ir");
		final Path asmFile = useExtension(inputFile, ".asm");
		final Path exeFile = useExtension(inputFile, ".exe");
		Files.deleteIfExists(astFile);
		Files.deleteIfExists(irFile);
		Files.deleteIfExists(asmFile);
		Files.deleteIfExists(exeFile);

		write(program, astFile);

		program = ArithmeticSimplifier.simplify(program);

		write(program, astSimpleFile);

		IRProgram irProgram = IRGenerator.convert(program);
		write(irProgram, irFile);

		final List<IRFunction> functions = new ArrayList<>();
		for (IRFunction function : irProgram.functions()) {
			if (function.asmLines().isEmpty()) {
				final List<IRInstruction> instructions = IROptimizer.optimize(function.instructions());

				final IRFunction optimizedFunction = function.derive(instructions);
				functions.add(optimizedFunction);
			}
			else {
				functions.add(function);
			}
		}

		irProgram = irProgram.derive(functions);

		try (final BufferedWriter writer = Files.newBufferedWriter(asmFile)) {
			final X86Win64 output = new X86Win64(writer);
			output.write(irProgram);
		}

		if (!launchFasm(asmFile)) {
			throw new IOException("Failed to compile");
		}
		return exeFile;
	}

	private static Path useExtension(Path path, String extension) {
		final String fileName = path.getFileName().toString();
		final int dotIndex = fileName.lastIndexOf('.');
		final String derivedName = dotIndex > 1 ? fileName.substring(0, dotIndex) + extension
				: fileName + extension;
		return path.resolveSibling(derivedName);
	}

	private static void write(Program program, Path file) throws IOException {
		try (final BufferedWriter writer = Files.newBufferedWriter(file)) {
			final ProgramWriter irWriter = new ProgramWriter(writer);
			irWriter.write(program);
		}
	}

	private static void write(IRProgram program, Path file) throws IOException {
		try (final BufferedWriter writer = Files.newBufferedWriter(file)) {
			final IRWriter irWriter = new IRWriter(writer);
			irWriter.write(program);
		}
	}

	private static boolean launchFasm(Path asmFile) throws IOException, InterruptedException {
		final Path fasmDir = Path.of(System.getProperty("user.home"), "Apps/fasm");
		final ProcessBuilder processBuilder = new ProcessBuilder(List.of(
				fasmDir.resolve("FASM.EXE").toString(),
				asmFile.toString()
		));
		processBuilder.redirectOutput(ProcessBuilder.Redirect.INHERIT);
		processBuilder.redirectError(ProcessBuilder.Redirect.INHERIT);
		processBuilder.environment().put("INCLUDE",
		                                 fasmDir.resolve("INCLUDE").toString());
		final int result = execute(processBuilder);
		if (result == 0) {
			return true;
		}

		System.err.println("Fasm failed " + result);
		return false;
	}

	private static void launchExe(Path exeFile, @Nullable Path outputFile) throws IOException, InterruptedException {
		final ProcessBuilder processBuilder = new ProcessBuilder(exeFile.toString());
		if (outputFile != null) {
			processBuilder.redirectOutput(outputFile.toFile());
		}
		else {
			processBuilder.redirectOutput(ProcessBuilder.Redirect.INHERIT);
		}
		processBuilder.redirectError(ProcessBuilder.Redirect.INHERIT);
		final int result = execute(processBuilder);
		if (result == 0) {
			System.out.println("OK");
			return;
		}

		System.err.println("Error " + result);
	}

	private static int execute(ProcessBuilder processBuilder) throws IOException, InterruptedException {
		final long start = System.currentTimeMillis();
		final Process process = processBuilder.start();
		final long stop = System.currentTimeMillis();
		System.out.println(processBuilder.command().getFirst() + ": " + (stop - start) + "ms");
		return process.waitFor();
	}
}
