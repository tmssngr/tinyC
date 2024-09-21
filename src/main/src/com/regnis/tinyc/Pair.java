package com.regnis.tinyc;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record Pair<A, B>(@NotNull A first, @NotNull B second) {
}
