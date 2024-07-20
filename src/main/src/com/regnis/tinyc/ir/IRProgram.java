package com.regnis.tinyc.ir;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRProgram(@NotNull List<IRFunction> functions,
                        @NotNull List<IRGlobalVar> globalVars,
                        @NotNull List<IRStringLiteral> stringLiterals) {
}
