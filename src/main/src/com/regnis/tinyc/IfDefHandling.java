package com.regnis.tinyc;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class IfDefHandling {
	private final List<Location> openIfDefLocations = new ArrayList<>();
	private final Set<String> defines;

	private int skipIfDef;

	public IfDefHandling(@NotNull Set<String> defines) {
		this.defines = defines;
	}

	public void ifDef(@NotNull String name, @NotNull Location location) {
		openIfDefLocations.add(location);
		if (skipIfDef == 0 && !defines.contains(name)) {
			skipIfDef = openIfDefLocations.size();
		}
	}

	public void endif(@NotNull Location location) {
		if (openIfDefLocations.isEmpty()) {
			throw new SyntaxException(Messages.endifWithoutIfdef(), location);
		}

		if (openIfDefLocations.size() == skipIfDef) {
			skipIfDef = 0;
		}
		openIfDefLocations.removeLast();
	}

	public boolean isSkip() {
		return skipIfDef > 0;
	}

	public void eof() {
		if (openIfDefLocations.size() > 0) {
			throw new SyntaxException(Messages.unclosedIfdef(), openIfDefLocations.removeLast());
		}
	}
}
