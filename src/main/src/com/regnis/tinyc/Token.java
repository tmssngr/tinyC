package com.regnis.tinyc;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record Token(@NotNull TokenType type, int intValue, @NotNull String text, @NotNull Location location) {
}
