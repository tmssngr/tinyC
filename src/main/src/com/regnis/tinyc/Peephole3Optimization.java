package com.regnis.tinyc;

import java.io.*;
import java.util.*;

/**
 * @author Thomas Singer
 */
public abstract class Peephole3Optimization<E> {

	protected abstract void handle(E item1, E item2, E item3);

	private final List<E> items;
	private final PrintStream debugOut;

	private int i;

	public Peephole3Optimization(List<E> items) {
		this.items = items;
		debugOut = System.out;
	}

	public void process() {
		i = 0;
		for (; i < items.size() - 2; i++) {
			final E i1 = items.get(i);
			final E i2 = items.get(i + 1);
			final E i3 = items.get(i + 2);
			handle(i1, i2, i3);
		}
	}

	protected void remove() {
		items.remove(i);
	}

	protected void removeNext() {
		items.remove(i + 1);
	}

	protected void insert(E item) {
		items.add(i, item);
	}

	protected void replace(E item) {
		remove();
		insert(item);
	}

	protected void again() {
		i--;
	}

	protected void again2() {
		i = Math.max(-1, i - 2);
	}

	protected void debug(String name) {
		print(name);
	}

	protected void printError() {
		print("error", true);
	}

	private void print(String name) {
		print(name, false);
	}

	private void print(String name, boolean printCurrentPosition) {
		if (debugOut == null) {
			return;
		}

		debugOut.println(name);

		int index = 0;
		for (E item : items) {
//			stream.print(index);
//			stream.print(" ");
			debugOut.print(item);
			if (printCurrentPosition) {
				if (index == i) {
					debugOut.print("   // <-- current");
				}
			}
			debugOut.println();
			index++;
		}
		debugOut.println();
	}
}
