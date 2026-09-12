package com.regnis.tinyc;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record Message(boolean isError, @NotNull String message, @NotNull Location location) {
	@NotNull
	public static Message error(@NotNull String message, @NotNull Location location) {
		return new Message(true, message, location);
	}

	@NotNull
	public static Message warn(@NotNull String message, @NotNull Location location) {
		return new Message(false, message, location);
	}

	@NotNull
	@Override
	public String toString() {
		final StringBuilder buffer = new StringBuilder();
		buffer.append(location);
		buffer.append(": ");
		if (isError) {
			buffer.append("error");
		}
		else {
			buffer.append("warning");
		}
		buffer.append(": ");
		buffer.append(message);
		return buffer.toString();
	}
}
