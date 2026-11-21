package com.regnis.tinyc;

import org.jetbrains.annotations.*;

/**
 * Maps allocator indices to physical byte registers. The first sixteen indices
 * always describe the working register window used by the calling convention.
 */
public final class Z8Registers {

	public static final int WORKING_REGISTER_BASE = 0x20;
	public static final int WORKING_REGISTER_COUNT = 16;
	public static final int STACK_SCRATCH_HIGH = 0x30;
	public static final int STACK_SCRATCH_LOW = 0x31;
	public static final Z8Registers DEFAULT = new Z8Registers();

	private final int[] physicalAddresses;

	/**
	 * Additional addresses form an explicit allowlist and must be verified against
	 * the target CPU and OS register map. Known backend/runtime reservations are
	 * rejected here. The default allowlist contains only %20 through %2F.
	 */
	public Z8Registers(@NotNull int... additionalAddresses) {
		physicalAddresses = new int[WORKING_REGISTER_COUNT + additionalAddresses.length];
		final boolean[] usedAddresses = new boolean[256];
		for (int register = 0; register < WORKING_REGISTER_COUNT; register++) {
			final int address = WORKING_REGISTER_BASE + register;
			physicalAddresses[register] = address;
			usedAddresses[address] = true;
		}
		for (int index = 0; index < additionalAddresses.length; index++) {
			final int address = additionalAddresses[index];
			if (isReservedAddress(address)) {
				throw new IllegalArgumentException("Unavailable Z8 register address: " + address);
			}
			if (usedAddresses[address]) {
				throw new IllegalArgumentException("Duplicate Z8 register address: " + address);
			}
			physicalAddresses[WORKING_REGISTER_COUNT + index] = address;
			usedAddresses[address] = true;
		}
	}

	public int registerCount() {
		return physicalAddresses.length;
	}

	public int getPhysicalAddress(int register) {
		return physicalAddresses[register];
	}

	public boolean isWorkingRegister(int register) {
		return register >= 0 && register < WORKING_REGISTER_COUNT;
	}

	/**
	 * A value occupies consecutive allocator indices and physical byte addresses.
	 * Pointer pairs additionally require an even physical starting address.
	 */
	public boolean isValidGroup(int register, int byteCount, boolean evenStart) {
		if (register < 0 || byteCount <= 0 || register > physicalAddresses.length - byteCount) {
			return false;
		}
		final int address = physicalAddresses[register];
		if (evenStart && (address & 1) != 0) {
			return false;
		}
		for (int offset = 1; offset < byteCount; offset++) {
			if (physicalAddresses[register + offset] != address + offset) {
				return false;
			}
		}
		return true;
	}

	private static boolean isReservedAddress(int address) {
		// %00-%03 are ports. %E0-%EF alias the working window and %F0-%FF
		// contain peripheral and control registers.
		if (address < 0x04 || address >= 0xE0) {
			return true;
		}
		return switch (address) {
			// ROM arithmetic operands/results in Z8AsmWriter.mulDivMod.
			case 0x12, 0x13, 0x14, 0x15 -> true;
			case STACK_SCRATCH_HIGH, STACK_SCRATCH_LOW -> true;
			// Cursor and random-generator state in z8.tc and random.tc.
			case 0x5B, 0x5C, 0x74, 0x75, 0x76, 0x77 -> true;
			default -> false;
		};
	}
}
