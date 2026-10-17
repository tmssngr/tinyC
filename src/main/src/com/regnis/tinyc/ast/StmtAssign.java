package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record StmtAssign(@NotNull Expression left, @NotNull Expression right, @NotNull Location location) implements Statement {
}
