package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;

import java.io.*;
import java.nio.file.*;
import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public class Compiler {

	public static void compileAndRun(@NotNull Path inputFile) throws IOException, InterruptedException {
		final Path outputFile = useExtension(inputFile, ".out");
		compileAndRun(inputFile, outputFile);
	}

	public static void compileAndRun(@NotNull Path inputFile, @Nullable Path outputFile) throws IOException, InterruptedException {
		final Program program = parse(inputFile);
		final TypeChecker checker = new TypeChecker(Type.I64);
		final Program programTyped = checker.check(program);

		final Path asmFile = useExtension(inputFile, ".asm");
		final Path exeFile = useExtension(inputFile, ".exe");
		Files.deleteIfExists(asmFile);
		Files.deleteIfExists(exeFile);

		try (final BufferedWriter writer = Files.newBufferedWriter(asmFile)) {
			final X86Win64 output = new X86Win64(writer);
			output.write(programTyped);
		}

		if (!launchFasm(asmFile)) {
			throw new IOException("Failed to compile");
		}

		launchExe(exeFile, outputFile);
	}

	private static Path useExtension(Path path, String extension) {
		final String fileName = path.getFileName().toString();
		final int dotIndex = fileName.lastIndexOf('.');
		final String derivedName = dotIndex > 1 ? fileName.substring(0, dotIndex) + extension
				: fileName + extension;
		return path.resolveSibling(derivedName);
	}

	private static Program parse(Path inputFile) throws IOException {
		try (BufferedReader reader = Files.newBufferedReader(inputFile)) {
			final Parser parser = new Parser(new Lexer(() -> {
				try {
					return reader.read();
				}
				catch (IOException ex) {
					throw new UncheckedIOException(ex);
				}
			}));
			return parser.parse();
		}
	}

	private static boolean launchFasm(Path asmFile) throws IOException, InterruptedException {
		final Path fasmDir = Path.of("C:\\Users\\tom\\Apps\\fasm");
		final ProcessBuilder processBuilder = new ProcessBuilder(List.of(
				fasmDir.resolve("FASM.EXE").toString(),
				asmFile.toString()
		));
		processBuilder.redirectOutput(ProcessBuilder.Redirect.INHERIT);
		processBuilder.redirectError(ProcessBuilder.Redirect.INHERIT);
		processBuilder.environment().put("INCLUDE",
		                                 fasmDir.resolve("INCLUDE").toString());
		final Process process = processBuilder.start();
		final int result = process.waitFor();
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
		final Process process = processBuilder.start();
		final int result = process.waitFor();
		if (result == 0) {
			System.out.println("OK");
			return;
		}

		System.err.println("Error " + result);
	}
}
