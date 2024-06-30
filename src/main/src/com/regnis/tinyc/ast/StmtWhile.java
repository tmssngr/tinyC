package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record StmtWhile(@NotNull Expression condition, @NotNull Statement bodyStatement, @NotNull Location location) implements Statement {
}
