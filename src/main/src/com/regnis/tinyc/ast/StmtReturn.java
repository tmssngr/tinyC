package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record StmtReturn(@Nullable Expression expression, @NotNull Location location) implements Statement {
}
