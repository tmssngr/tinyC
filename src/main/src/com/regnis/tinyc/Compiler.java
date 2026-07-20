package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.cfg.*;
import com.regnis.tinyc.ir.*;
import com.regnis.tinyc.linearscanregalloc.*;

import java.io.*;
import java.nio.file.*;
import java.nio.file.attribute.*;
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

	@NotNull
	public static Path compile(@NotNull Path inputFile) throws IOException, InterruptedException {
		final String subdirWin = "windows/";
		final String subdirLinux = "linux/";
		final String subdirZ8 = "z8/";
		final Path asmFileWin = compile(inputFile, subdirWin, TargetArchitecture.WIN_X86_64);
		final Path asmFileLinux = compile(inputFile, subdirLinux, TargetArchitecture.LINUX_X86_64);
		final Path asmFileZ8 = compile(inputFile, subdirLinux, TargetArchitecture.Z8);
		final Path asmFile;
		final Path exeFile;
		if (Utils.IS_WINDOWS) {
			asmFile = asmFileWin;
			exeFile = useExtension(inputFile, subdirWin, ".exe");
		}
		else {
			asmFile = asmFileLinux;
			exeFile = useExtension(inputFile, subdirLinux, ".bin");
		}
		Files.deleteIfExists(exeFile);
		if (!launchFasm(asmFile, exeFile)) {
			throw new IOException("Failed to compile");
		}

		if (!Utils.IS_WINDOWS) {
			final Set<PosixFilePermission> permissions = Files.getPosixFilePermissions(exeFile);
			permissions.add(PosixFilePermission.OWNER_EXECUTE);
			Files.setPosixFilePermissions(exeFile, permissions);
		}
		return exeFile;
	}

	@NotNull
	private static Path compile(@NotNull Path inputFile, String subdir, TargetArchitecture architecture) throws IOException, InterruptedException {
		final Program parsedProgram = Parser.parse(inputFile, architecture.defines);

		final TypeChecker checker = new TypeChecker(architecture.architecture.getPointerIntType());
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

		IRProgram irProgram = IRGenerator.convert(program, architecture.architecture.getPointerIntType());
		irProgram = CleanupGlobalUnusedVariables.process(irProgram);
		irProgram = IROptimizer.branchAndLabelOptimizations(irProgram);
		write(irProgram, irFile);

		final List<IRFunction> functions = new ArrayList<>();
		try (final BufferedWriter cfgWriter = Files.newBufferedWriter(cfgFile)) {
			final IRWriter irWriter = new IRWriter(cfgWriter);
			try (final BufferedWriter writer = Files.newBufferedWriter(dotFile)) {
				final DotWriter dotWriter = new DotWriter(writer);
				dotWriter.begin();
				for (IRFunction function : irProgram.functions()) {
					final Pair<IRFunction, ControlFlowGraph> result = RemoveNotLiveResults.run(function);
					function = result.first();
					final ControlFlowGraph cfg = result.second();
					irWriter.write(cfg);
					dotWriter.writeCfg(cfg);
					function = LSRegAlloc.process(function, architecture.architecture);
					final List<IRInstruction> optimizedInstructions = IROptimizer.optimize(function.instructions());
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
		final Path file = Utils.replaceExtensionWith(path, subdir, extension);
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
		Utils.execute(processBuilder);
	}

	private static boolean launchFasm(Path asmFile, Path exeFile) throws IOException, InterruptedException {
		String fasmName = "fasm";
		if (Utils.IS_WINDOWS) {
			fasmName += ".exe";
		}
		final String fasmHomeString = System.getenv("FASM_HOME");
		Path fasmHome = null;
		if (fasmHomeString != null) {
			fasmHome = Paths.get(fasmHomeString);
			fasmName = fasmHome.resolve(fasmName).toString();
		}
		final ProcessBuilder processBuilder = new ProcessBuilder(List.of(
				fasmName,
				asmFile.toString(),
				exeFile.toString()
		));
		processBuilder.redirectOutput(ProcessBuilder.Redirect.INHERIT);
		processBuilder.redirectError(ProcessBuilder.Redirect.INHERIT);
		if (fasmHome != null) {
			processBuilder.environment().put("INCLUDE",
			                                 fasmHome.resolve("INCLUDE").toString());
		}
		final int result = Utils.execute(processBuilder);
		if (result == 0) {
			return true;
		}

		System.err.println("Fasm failed " + result);
		return false;
	}
}
