package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.cfg.*;
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
	public static Path compile(@NotNull Path inputFile) throws IOException, InterruptedException {
		final Program parsedProgram = Parser.parse(inputFile, Set.of("X86_64"));

		final TypeChecker checker = new TypeChecker(Type.I64);
		final Program typedProgram = checker.check(parsedProgram);

		Program program = UnusedFunctionRemover.removeUnusedFunctions(typedProgram);

		final Path astFile = useExtension(inputFile, ".ast");
		final Path astSimpleFile = useExtension(inputFile, ".asts");
		final Path irFile = useExtension(inputFile, ".ir");
		final Path irRegFile = useExtension(inputFile, ".irr");
		final Path dotFile = useExtension(inputFile, ".dot");
		final Path svgFile = useExtension(inputFile, ".svg");
		final Path cfgFile = useExtension(inputFile, ".cfg");
		final Path asmFile = useExtension(inputFile, ".asm");
		final Path exeFile = useExtension(inputFile, ".exe");
		Files.deleteIfExists(astFile);
		Files.deleteIfExists(irFile);
		Files.deleteIfExists(irRegFile);
		Files.deleteIfExists(dotFile);
		Files.deleteIfExists(svgFile);
		Files.deleteIfExists(cfgFile);
		Files.deleteIfExists(asmFile);
		Files.deleteIfExists(exeFile);

		write(program, astFile);

		program = ArithmeticSimplifier.simplify(program);

		write(program, astSimpleFile);

		IRProgram irProgram = IRGenerator.convert(program);
		irProgram = CleanupGlobalUnusedVariables.process(irProgram);
		write(irProgram, irFile);

		final int maxRegisters = 4;
		final List<IRFunction> functions = new ArrayList<>();
		try (final BufferedWriter cfgWriter = Files.newBufferedWriter(cfgFile)) {
			final IRWriter irWriter = new IRWriter(cfgWriter);
			try (final BufferedWriter writer = Files.newBufferedWriter(dotFile)) {
				final DotWriter dotWriter = new DotWriter(writer);
				dotWriter.begin();
				for (IRFunction function : irProgram.functions()) {
					final String name = function.name();
					ControlFlowGraph cfg = CfgGenerator.create(name, function.instructions());
					DetectVarLiveness.process(cfg);
					irWriter.write(cfg);
					dotWriter.writeCfg(cfg);
					cfg = LinearScanRegisterAllocation.process(cfg, function.varInfos(), maxRegisters);
					final List<IRInstruction> instructions = getFlattenInstructions(cfg.blocks());

					final IRFunction optimizedFunction = function.derive(instructions);
					functions.add(optimizedFunction);
				}
				dotWriter.end();
			}
		}
		launchGraphViz(dotFile, svgFile);

		irProgram = CleanupLocalUnusedVariables.process(irProgram.derive(functions));
		write(irProgram, irRegFile);

		try (final BufferedWriter writer = Files.newBufferedWriter(asmFile)) {
			final X86Win64 output = new X86Win64(writer);
			output.write(irProgram);
		}

		if (!launchFasm(asmFile)) {
			throw new IOException("Failed to compile");
		}
		return exeFile;
	}

	@NotNull
	private static List<IRInstruction> getFlattenInstructions(@NotNull List<BasicBlock> blocks) {
		final List<IRInstruction> instructions = new ArrayList<>();
		for (BasicBlock block : blocks) {
			if (block.name.startsWith("@")) {
				instructions.add(new IRLabel(block.name));
			}
			instructions.addAll(block.instructions());
		}

		return IROptimizer.optimize(instructions);
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
