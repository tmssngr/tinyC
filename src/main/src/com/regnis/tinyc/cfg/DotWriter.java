package com.regnis.tinyc.cfg;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ir.*;

import java.io.*;
import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class DotWriter extends TextWriter {

	private int index;

	public DotWriter(@NotNull BufferedWriter writer) {
		super(writer);
	}

	public void begin() throws IOException {
		writeln("digraph program {");
		writeIndentation();
		writeln("edge[fontsize=\"10pt\"];");
	}

	public void writeCfg(ControlFlowGraph cfg) throws IOException {
		final String name = cfg.name();
		writeIndentation();
		writeln("subgraph fn_" + name + " {");
		for (BasicBlock block : cfg.blocks()) {
			writeBasicBlock(block, cfg);
		}
		writeIndentation();
		end();
		index++;
	}

	public void end() throws IOException {
		writeln("}");
	}

	private void writeBasicBlock(BasicBlock block, ControlFlowGraph cfg) throws IOException {
		writeIndentation();
		writeIndentation();
		write(nodeName(block));
		write(" [label=\"");
		write(getBlockName(block));
		write("\"");
		write(",shape=");
		final List<String> successors = block.successors();
		if (successors.isEmpty()) {
			write("oval");
		}
		else if (successors.size() == 1) {
			write("box");
		}
		else {
			write("hexagon");
		}

		if (successors.isEmpty()) {
			write(",style=filled,fillcolor=\"#fff5ee\"");
		}
		writeln("];");

		for (String successor : block.successors()) {
			final BasicBlock successorBlock = cfg.get(successor);
			writeIndentation();
			writeIndentation();
			write(nodeName(block));
			write(" -> ");
			write(nodeName(successorBlock));
			final Set<IRVar> liveBefore = successorBlock.getLiveBefore();
			if (liveBefore.size() > 0) {
				write(" [label=\"(");
				final List<String> names = liveBefore.stream().map(IRVar::name).sorted().toList();
				boolean addComma = false;
				for (String name : names) {
					if (addComma) {
						write(",");
					}
					write(name);
					addComma = true;
				}
				write(")\"]");
			}
			writeln(";");
		}
	}

	private String nodeName(BasicBlock block) {
		final String name = getBlockName(block);
		return "BasicBlock_" + index + "_" + name;
	}

	@NotNull
	private static String getBlockName(BasicBlock block) {
		return block.name.replace("@", "");
	}
}
