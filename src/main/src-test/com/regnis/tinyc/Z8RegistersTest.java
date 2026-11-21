package com.regnis.tinyc;

import org.junit.*;

import static org.junit.Assert.*;

public class Z8RegistersTest {

	@Test
	public void testDefaultWorkingWindow() {
		final Z8Registers registers = Z8Registers.DEFAULT;
		assertEquals(16, registers.registerCount());
		for (int register = 0; register < 16; register++) {
			assertEquals(0x20 + register, registers.getPhysicalAddress(register));
			assertTrue(registers.isWorkingRegister(register));
		}
		assertTrue(registers.isValidGroup(0, 8, false));
		assertTrue(registers.isValidGroup(14, 2, true));
		assertFalse(registers.isValidGroup(13, 2, true));
		assertFalse(registers.isValidGroup(15, 2, false));
		assertFalse(registers.isWorkingRegister(-1));
		assertFalse(registers.isWorkingRegister(16));
	}

	@Test
	public void testPhysicalGroupsAcrossGaps() {
		final int[] additionalAddresses = {0x40, 0x42, 0x43, 0x44, 0x45};
		final Z8Registers registers = new Z8Registers(additionalAddresses);
		additionalAddresses[0] = 0x50;

		assertEquals(0x40, registers.getPhysicalAddress(16));
		assertFalse(registers.isWorkingRegister(16));
		assertFalse(registers.isValidGroup(15, 2, false));
		assertFalse(registers.isValidGroup(16, 2, false));
		assertTrue(registers.isValidGroup(17, 4, false));
		assertTrue(registers.isValidGroup(17, 2, true));
		assertFalse(registers.isValidGroup(18, 2, true));
		assertFalse(registers.isValidGroup(20, 2, false));
		assertFalse(registers.isValidGroup(-1, 1, false));
		assertFalse(registers.isValidGroup(0, 0, false));
		assertFalse(registers.isValidGroup(0, -1, false));
	}

	@Test
	public void testUnavailableAndDuplicateAddresses() {
		for (int address : new int[]{-1, 0, 3, 0x12, 0x13, 0x14, 0x15,
		                             0x30, 0x31, 0x5B, 0x5C, 0x74, 0x75, 0x76, 0x77,
		                             0xE0, 0xEF, 0xF0, 0xFD, 0xFE, 0xFF, 256}) {
			assertUnavailable(address);
		}
		assertUnavailable(0x20);
		assertUnavailable(0x40, 0x40);
	}

	private static void assertUnavailable(int... addresses) {
		try {
			new Z8Registers(addresses);
			fail("Expected unavailable register addresses to be rejected");
		}
		catch (IllegalArgumentException expected) {
		}
	}
}
