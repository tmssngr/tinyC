package com.regnis.tinyc;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
final class IfDefHandling {
	private final List<IfDef> openIfDefs = new ArrayList<>();
	private final Set<String> defines;

	private boolean skipping;

	public IfDefHandling(@NotNull Set<String> defines) {
		this.defines = defines;
	}

	public void processIfDef(@NotNull String name, @NotNull Location location) {
		final boolean defined = defines.contains(name);
		final boolean skipElse = skipping || defined;
		openIfDefs.add(new IfDef(location, skipElse, skipping));
		skipping |= !defined;
	}

	public void processElse(@NotNull Location location) {
		if (openIfDefs.isEmpty()) {
			throw new SyntaxException(Messages.elseWithoutIfdef(), location);
		}

		final IfDef ifDef = openIfDefs.getLast();
		if (ifDef.elseLocation != null) {
			throw new SyntaxException(Messages.duplicateElse(ifDef.elseLocation), location);
		}

		ifDef.elseLocation = location;
		skipping = ifDef.skipElseBranch;
	}

	public void processEndIf(@NotNull Location location) {
		if (openIfDefs.isEmpty()) {
			throw new SyntaxException(Messages.endifWithoutIfdef(), location);
		}

		final IfDef ifDef = openIfDefs.removeLast();
		skipping = ifDef.skipAfterEnd;
	}

	public boolean isSkip() {
		return skipping;
	}

	public void eof() {
		if (openIfDefs.isEmpty()) {
			return;
		}

		final IfDef ifDef = openIfDefs.removeLast();
		throw new SyntaxException(Messages.unclosedIfdef(), ifDef.ifDefLocation);
	}

	private static final class IfDef {
		private final Location ifDefLocation;
		private final boolean skipAfterEnd;
		private final boolean skipElseBranch;

		private Location elseLocation;

		public IfDef(@NotNull Location location, boolean skipElseBranch, boolean skipAfterEnd) {
			ifDefLocation = location;
			this.skipElseBranch = skipElseBranch;
			this.skipAfterEnd = skipAfterEnd;
		}
	}
}
