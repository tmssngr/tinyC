package com.regnis.tinyc.linearscanregalloc;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
interface LSAlgorithmLogger {
	LSAlgorithmLogger DUMMY = new LSAlgorithmLogger() {
		@Override
		public void initialize(@NotNull List<LSInterval> intervals) {
		}

		@Override
		public void log(String title, LSInterval current) {
		}

		@Override
		public void log(String title, List<LSInterval> intervals) {
		}

		@Override
		public void log(LSInterval interval) {
		}

		@Override
		public void log(String msg) {
		}
	};

	void initialize(@NotNull List<LSInterval> intervals);

	void log(String title, LSInterval current);

	void log(String title, List<LSInterval> intervals);

	void log(LSInterval interval);

	void log(String msg);
}
