package com.regnis.tinyc.ir;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRDebugComment(@NotNull List<Object> debugInfos) implements IRInstruction {
}
