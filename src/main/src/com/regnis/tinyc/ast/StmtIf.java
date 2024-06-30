package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record StmtIf(@NotNull Expression condition, @NotNull Statement thenStatement, @Nullable Statement elseStatement, @NotNull Location location) implements Statement {
}
