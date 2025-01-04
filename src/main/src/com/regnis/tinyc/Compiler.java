package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.cfg.*;
import com.regnis.tinyc.ir.*;
import com.regnis.tinyc.linearscanregalloc.*;

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
		final Path outputFile = useExtension(inputFile, "", ".out");
		compileAndRun(inputFile, outputFile);
	}

	public static void compileAndRun(@NotNull Path inputFile, @Nullable Path outputFile) throws IOException, InterruptedException {
		final Path exeFile = compile(inputFile);
		launchExe(exeFile, outputFile);
	}

	@NotNull
	public static Path compile(@NotNull Path inputFile) throws IOException, InterruptedException {
		compile(inputFile, "z8/", TargetArchitecture.Z8);

		return compileWinX86_64(inputFile);
	}

	@NotNull
	private static Path compileWinX86_64(@NotNull Path inputFile) throws IOException, InterruptedException {
		final String subdir = "";
		final Path exeFile = useExtension(inputFile, subdir, ".exe");
		Files.deleteIfExists(exeFile);
		final Path asmFile = compile(inputFile, subdir, TargetArchitecture.WIN_X86_64);
		if (!launchFasm(asmFile)) {
			throw new IOException("Failed to compile");
		}
		return exeFile;
	}

	@NotNull
	private static Path compile(@NotNull Path inputFile, String subdir, TargetArchitecture architecture) throws IOException, InterruptedException {
		final Program parsedProgram = Parser.parse(inputFile, architecture.defines);

		final TypeChecker checker = new TypeChecker(architecture.pointerIntType);
		final Program typedProgram = checker.check(parsedProgram);

		Program program = UnusedFunctionRemover.removeUnusedFunctions(typedProgram);

		final Path astFile = useExtension(inputFile, subdir, ".ast");
		final Path astSimpleFile = useExtension(inputFile, subdir, ".asts");
		final Path irFile = useExtension(inputFile, subdir, ".ir");
		final Path irRegFile = useExtension(inputFile, subdir, ".irr");
		final Path dotFile = useExtension(inputFile, subdir, ".dot");
		final Path svgFile = useExtension(inputFile, subdir, ".svg");
		final Path cfgFile = useExtension(inputFile, subdir, ".cfg");
		final Path asmFile = useExtension(inputFile, subdir, ".asm");
		Files.deleteIfExists(astFile);
		Files.deleteIfExists(irFile);
		Files.deleteIfExists(irRegFile);
		Files.deleteIfExists(dotFile);
		Files.deleteIfExists(svgFile);
		Files.deleteIfExists(cfgFile);
		Files.deleteIfExists(asmFile);

		write(program, astFile);

		program = ArithmeticSimplifier.simplify(program);

		write(program, astSimpleFile);

		IRProgram irProgram = IRGenerator.convert(program);
		irProgram = CleanupGlobalUnusedVariables.process(irProgram);
		write(irProgram, irFile);

		final List<IRFunction> functions = new ArrayList<>();
		try (final BufferedWriter cfgWriter = Files.newBufferedWriter(cfgFile)) {
			final IRWriter irWriter = new IRWriter(cfgWriter);
			try (final BufferedWriter writer = Files.newBufferedWriter(dotFile)) {
				final DotWriter dotWriter = new DotWriter(writer);
				dotWriter.begin();
				for (IRFunction function : irProgram.functions()) {
					final String name = function.name();
					final ControlFlowGraph cfg = CfgGenerator.create(name, function.instructions());
					DetectVarLiveness.process(cfg, true);
					irWriter.write(cfg);
					dotWriter.writeCfg(cfg);
					final List<IRInstruction> instructions = LSRegAlloc.process(function, architecture.architecture);
					final List<IRInstruction> optimizedInstructions = IROptimizer.optimize(instructions);
					final IRFunction optimizedFunction = CleanupLocalUnusedVariables.optimize(function.derive(optimizedInstructions));
					functions.add(optimizedFunction);
				}
				dotWriter.end();
			}
		}
		launchGraphViz(dotFile, svgFile);

		irProgram = irProgram.derive(functions);
		write(irProgram, irRegFile);

		try (final BufferedWriter writer = Files.newBufferedWriter(asmFile)) {
			final AsmWriter output = architecture.createAsmWriter(writer);
			output.write(irProgram);
		}

		return asmFile;
	}

	private static Path useExtension(Path path, String subdir, String extension) throws IOException {
		final String fileName = path.getFileName().toString();
		final int dotIndex = fileName.lastIndexOf('.');
		final String derivedName = dotIndex > 1 ? fileName.substring(0, dotIndex) + extension
				: fileName + extension;
		final Path file = path.resolveSibling(subdir + derivedName);
		Files.createDirectories(file.getParent());
		return file;
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

	private static void launchGraphViz(Path dotFile, Path svgFile) throws IOException, InterruptedException {
		if (true) {
			return;
		}
		final Path dotExeFile = Path.of(System.getProperty("user.home"), "Apps/graphviz/bin/dot.exe");
		final ProcessBuilder processBuilder = new ProcessBuilder(List.of(
				dotExeFile.toString(),
				"-Tsvg",
				dotFile.toString(),
				"-o",
				svgFile.toString()
		));
		processBuilder.redirectOutput(ProcessBuilder.Redirect.INHERIT);
		processBuilder.redirectError(ProcessBuilder.Redirect.INHERIT);
		execute(processBuilder);
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
