package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class LSAlgorithmLoggerImpl implements LSAlgorithmLogger {

	private final List<LSIntervalFactory.Indices> blockBoundaries;

	private int maxPos;

	public LSAlgorithmLoggerImpl(@NotNull List<LSIntervalFactory.Indices> blockBoundaries) {
		this.blockBoundaries = blockBoundaries;
	}

	@Override
	public void initialize(@NotNull List<LSInterval> intervals) {
		maxPos = 0;
		for (LSInterval interval : intervals) {
			maxPos = Math.max(maxPos, interval.getTo());
		}
	}

	@Override
	public void log(String title, LSInterval current) {
		log(title);
		log(current);
	}

	@Override
	public void log(String title, List<LSInterval> intervals) {
		if (intervals.size() > 0) {
			log(title);
			for (LSInterval interval : intervals) {
				log(interval);
			}
		}
	}

	@Override
	public void log(LSInterval interval) {
		final StringBuilder buffer = new StringBuilder();
		buffer.append(interval.rangesAsString(maxPos, blockBoundaries));
		final IRVar var = interval.varNullable();
		if (var != null) {
			buffer.append("  ");
			buffer.append(var);
			buffer.append(":");
			buffer.append(var.type());
		}
		final int register = interval.register();
		if (register >= 0) {
			buffer.append("  r");
			buffer.append(register);
		}
		log(buffer.toString());
	}

	@Override
	public void log(String msg) {
		System.out.println(msg);
	}
}
