package com.regnis.tinyc.ast;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record StringLiteral(@NotNull String text, int index) {
}
