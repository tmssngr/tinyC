package com.regnis.tinyc;

import java.io.*;
import java.nio.file.*;
import java.util.*;

/**
 * @author Thomas Singer
 */
public class Main {

	public static void main(String[] args) throws IOException, InterruptedException {
		final Path asmFile = Path.of("output.asm");
		try (final BufferedWriter writer = Files.newBufferedWriter(asmFile)) {
			final X86Win64 output = new X86Win64(writer);
			output.write();
		}

		if (!launchFasm(asmFile)) {
			return;
		}

		launchExe(Path.of("output.exe"));
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

	private static void launchExe(Path exeFile) throws IOException, InterruptedException {
		final ProcessBuilder processBuilder = new ProcessBuilder(exeFile.toString());
		processBuilder.redirectOutput(ProcessBuilder.Redirect.INHERIT);
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
