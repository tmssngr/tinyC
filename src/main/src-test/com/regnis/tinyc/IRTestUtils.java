package com.regnis.tinyc;

import com.regnis.tinyc.ir.*;

import java.util.*;

import org.junit.*;

/**
 * @author Thomas Singer
 */
public final class IRTestUtils {
	public static void assertEqualsInstructions(List<IRInstruction> expected, List<IRInstruction> actual) {
		TestUtils.assertEquals(expected, actual,
		                       IRTestUtils::assertEquals);
	}

	private static void assertEquals(IRInstruction expected, IRInstruction actual) {
		Assert.assertEquals(expected, actual);
	}
}
