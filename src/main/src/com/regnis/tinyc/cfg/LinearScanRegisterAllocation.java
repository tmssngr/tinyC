package com.regnis.tinyc.cfg;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;
import java.util.function.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class LinearScanRegisterAllocation {

	public static ControlFlowGraph process(ControlFlowGraph cfg) {
		final List<BasicBlock> blocks = new ArrayList<>();
		for (BasicBlock block : cfg.blocks()) {
			final LinearScanRegisterAllocation allocation = new LinearScanRegisterAllocation(block);
			final BasicBlock newBlock = allocation.process();
			blocks.add(newBlock);
		}
		return cfg.derive(blocks);
	}

	private final List<IRInstruction> instructions = new ArrayList<>();
	private final Register[] registers;
	private final BasicBlock block;

	public LinearScanRegisterAllocation(BasicBlock block) {
		this.block = block;
		final int maxRegisters = 4;
		registers = new Register[maxRegisters];
		for (int i = 0; i < registers.length; i++) {
			registers[i] = new Register(i);
		}
	}

	public BasicBlock process() {
		for (IRInstruction instruction : block.instructions) {
			process(instruction);
		}
		return new BasicBlock(block.name, instructions, block.predecessors, block.successors);
	}

	private void process(IRInstruction instruction) {
		maybeSpillRegisters(instruction);

		switch (instruction) {
		case IRLiteral literal -> processLiteral(literal);
		case IRString literal -> processString(literal);
		case IRAddrOf addrOf -> processAddrOf(addrOf);
		case IRAddrOfArray addrOfArray -> processAddrOfArray(addrOfArray);
		case IRArrayAccess access -> prcessArrayAccess(access);
		case IRBinary binary -> processBinary(binary);
		case IRCast cast -> processCast(cast);
		case IRUnary unary -> processUnary(unary);
		case IRCopy copy -> processCopy(copy);
		case IRMemLoad load -> processMemLoad(load);
		case IRMemStore store -> processMemStore(store);
		case IRCall call -> processCall(call);
		case IRRetValue retValue -> processRetValue(retValue);
		case IRBranch branch -> processBranch(branch);
		case IRJump jump -> processJump(jump);
		case IRComment ignored -> add(instruction);
		default -> {
			throw new UnsupportedOperationException(String.valueOf(instruction));
		}
		}
	}

	private void maybeSpillRegisters(IRInstruction instruction) {
		if (instruction instanceof IRComment
		    || instruction instanceof IRCall) {
			return;
		}

		final Set<LiveVar> liveBefore = block.getLiveBefore(instruction);
		final Set<LiveVar> lastUsed = block.getLastUsed(instruction);

		final Set<LiveVar> uses = new HashSet<>();
		final Set<LiveVar> defines = new HashSet<>();
		DetectVarLiveness.detectLiveness(instruction, uses, defines);
		final LiveVar[] registersUsedFor = new LiveVar[registers.length];
		for (LiveVar var : uses) {
			Utils.assertTrue(liveBefore.contains(var));

			Register register = findMatchingRegister(var);
			if (register == null) {
				register = maybeSpill(registersUsedFor, Set.of());
			}
			registersUsedFor[register.index] = var;
		}

		final int furtherNeeded = defines.size() - lastUsed.size();
		if (furtherNeeded > 0) {
			Utils.assertTrue(furtherNeeded == 1);
			maybeSpill(registersUsedFor, uses);
		}
	}

	@Nullable
	private Register findMatchingRegister(LiveVar var) {
		for (Register register : registers) {
			final IRVar regVar = register.var;
			if (regVar != null && LiveVar.equals(var, regVar)) {
				return register;
			}
		}
		return null;
	}

	@NotNull
	private Register maybeSpill(LiveVar[] occupiedRegisters, Set<LiveVar> dontSpill) {
		Utils.assertTrue(occupiedRegisters.length == registers.length);
		Register register = iterateRegistersUntil(occupiedRegisters,
		                                          r -> r.var == null);
		if (register != null) {
			return register;
		}

		register = iterateRegistersUntil(occupiedRegisters,
		                                 r -> {
			                                 final IRVar var = Objects.requireNonNull(r.var);
			                                 return !contains(var, dontSpill)
			                                        && !r.usedForWrite;
		                                 });
		if (register != null) {
			register.free();
			return register;
		}

		register = iterateRegistersUntil(occupiedRegisters,
		                                 r -> {
			                                 final IRVar var = Objects.requireNonNull(r.var);
			                                 return !contains(var, dontSpill);
		                                 });
		if (register == null) {
			throw new IllegalStateException("Failed to spill");
		}

		final IRVar var = Objects.requireNonNull(register.var);
		add(new IRComment("Spill " + var.name()));
		add(new IRCopy(var, IRVar.createRegisterVar(register.index, var.type()), Location.DUMMY));
		register.free();
		return register;
	}

	@Nullable
	private Register iterateRegistersUntil(LiveVar[] occupiedRegisters, Predicate<Register> predicate) {
		for (int i = 0; i < registers.length; i++) {
			if (occupiedRegisters[i] != null) {
				continue;
			}

			final Register register = registers[i];
			if (predicate.test(register)) {
				return register;
			}
		}
		return null;
	}

	private void processLiteral(IRLiteral instruction) {
		final IRVar target = instruction.target();
		if (!isGlobalOrLiveAfter(target, instruction)) {
			return;
		}

		final IRVar targetReg = targetRegister(target);
		add(new IRLiteral(targetReg, instruction.value(), instruction.location()));
	}

	private void processString(IRString instruction) {
		final IRVar target = instruction.target();
		if (!isGlobalOrLiveAfter(target, instruction)) {
			return;
		}

		final IRVar targetReg = targetRegister(target);
		add(new IRString(targetReg, instruction.stringIndex(), instruction.location()));
	}

	private void processAddrOf(IRAddrOf instruction) {
		final IRVar target = instruction.target();
		if (!isGlobalOrLiveAfter(target, instruction)) {
			return;
		}

		final IRVar source = instruction.source();
		assertIsLiveBefore(source, instruction);
		maybeStoreRegisterInMemory(source, instruction.location());
		final IRVar var = targetRegister(target);
		add(new IRAddrOf(var, source, instruction.location()));
	}

	private void processAddrOfArray(IRAddrOfArray instruction) {
		final IRVar target = instruction.addr();
		if (!isGlobalOrLiveAfter(target, instruction)) {
			return;
		}

		final IRVar index = loadIntoRegister(instruction.index(), instruction);
		IRVar arrayOrPointer = instruction.array();
		if (!instruction.varIsArray()) {
			arrayOrPointer = loadIntoRegister(arrayOrPointer, instruction);
		}
		freeLastUsed(instruction);
		final IRVar targetReg = targetRegister(target);
		add(new IRAddrOfArray(targetReg, arrayOrPointer, index, instruction.varIsArray(), instruction.location()));
	}

	private void prcessArrayAccess(IRArrayAccess instruction) {
		final IRVar target = instruction.addr();
		if (!isGlobalOrLiveAfter(target, instruction)) {
			return;
		}

		final IRVar index = loadIntoRegister(instruction.index(), instruction);
		freeLastUsed(instruction);
		final IRVar targetReg = targetRegister(target);
		add(new IRArrayAccess(targetReg, instruction.array(), index, instruction.location()));
	}

	private void processBinary(IRBinary instruction) {
		final IRVar target = instruction.target();
		if (!isGlobalOrLiveAfter(target, instruction)) {
			return;
		}

		final IRVar left = loadIntoRegister(instruction.left(), instruction);
		final IRVar right = loadIntoRegister(instruction.right(), instruction);
		freeLastUsed(instruction);
		final IRVar targetReg = targetRegister(target);
		add(new IRBinary(targetReg, instruction.op(), left, right, instruction.location()));
	}

	private void processCast(IRCast instruction) {
		final IRVar target = instruction.target();
		if (!isGlobalOrLiveAfter(target, instruction)) {
			return;
		}

		final IRVar source = loadIntoRegister(instruction.source(), instruction);
		freeLastUsed(instruction);
		final IRVar targetReg = targetRegister(target);
		add(new IRCast(targetReg, source, instruction.location()));
	}

	private void processUnary(IRUnary instruction) {
		final IRVar target = instruction.target();
		if (!isGlobalOrLiveAfter(target, instruction)) {
			return;
		}

		final IRVar source = loadIntoRegister(instruction.source(), instruction);
		freeLastUsed(instruction);
		final IRVar targetReg = targetRegister(target);
		add(new IRUnary(instruction.op(), targetReg, source));
	}

	private void processCopy(IRCopy instruction) {
		final IRVar target = instruction.target();
		if (!isGlobalOrLiveAfter(target, instruction)) {
			return;
		}

		final IRVar source = loadIntoRegister(instruction.source(), instruction);
		freeLastUsed(instruction);
		final IRVar targetReg = targetRegister(target);
		if (!Objects.equals(source, targetReg)) {
			add(new IRCopy(targetReg, source, instruction.location()));
		}
	}

	private void processMemLoad(IRMemLoad instruction) {
		final IRVar target = instruction.target();
		if (!isGlobalOrLiveAfter(target, instruction)) {
			return;
		}

		storeReferencedVars(instruction);

		final IRVar addr = loadIntoRegister(instruction.addr(), instruction);
		freeLastUsed(instruction);
		final IRVar targetReg = targetRegister(target);
		add(new IRMemLoad(targetReg, addr, instruction.location()));
	}

	private void processMemStore(IRMemStore instruction) {
		storeReferencedVars(instruction);

		final IRVar addr = loadIntoRegister(instruction.addr(), instruction);
		final IRVar value = loadIntoRegister(instruction.value(), instruction);
		freeLastUsed(instruction);
		add(new IRMemStore(addr, value, instruction.location()));
	}

	private void processCall(IRCall instruction) {
		final List<IRVar> args = new ArrayList<>();
		for (IRVar arg : instruction.args()) {
			final IRVar var = getVar(arg, instruction);
			args.add(var);
		}

		freeLastUsed(instruction);
		storeLiveWrittenVarsFromRegister(instruction);

		IRVar target = instruction.target();
		if (target != null) {
			if (isGlobalOrLiveAfter(target, instruction)) {
				target = mayBeStoreInRegister(target);
			}
			else {
				target = null;
			}
		}
		add(new IRCall(target, instruction.name(), args, instruction.location()));
	}

	private void processRetValue(IRRetValue instruction) {
		final IRVar var = loadIntoRegister(instruction.var(), instruction);
		freeLastUsed(instruction);
		storeLiveWrittenVarsFromRegister(instruction);
		add(new IRRetValue(var, instruction.location()));
	}

	private void processBranch(IRBranch instruction) {
		final IRVar condition = loadIntoRegister(instruction.conditionVar(), instruction);
		freeLastUsed(instruction);
		storeLiveWrittenVarsFromRegister(instruction);
		add(new IRBranch(condition, instruction.jumpOnTrue(), instruction.target(), instruction.nextLabel()));
	}

	private void processJump(IRJump instruction) {
		storeLiveWrittenVarsFromRegister(instruction);
		add(instruction);
	}

	private IRVar getVar(IRVar var, IRInstruction instruction) {
		assertIsLiveBefore(var, instruction);
		final int register = getRegister(var);
		return register >= 0
				? IRVar.createRegisterVar(register, var.type())
				: var;
	}

	private IRVar loadIntoRegister(IRVar var, IRInstruction instruction) {
		assertIsLiveBefore(var, instruction);
		final int register = getRegister(var);
		if (register >= 0) {
			return IRVar.createRegisterVar(register, var.type());
		}

		final IRVar regVar = useRegisterFor(var, false);
		add(new IRCopy(regVar, var, Location.DUMMY));
		return regVar;
	}

	@NotNull
	private IRVar targetRegister(IRVar var) {
		Utils.assertTrue(getRegister(var) < 0);
		return useRegisterFor(var, true);
	}

	@NotNull
	private IRVar useRegisterFor(IRVar var, boolean write) {
		final int register = getFreeRegister();
		registers[register].setUsed(var, write);
		return IRVar.createRegisterVar(register, var.type());
	}

	@NotNull
	private IRVar mayBeStoreInRegister(@NotNull IRVar target) {
		int register = getRegister(target);
		if (register < 0) {
			register = getFreeRegister();
			if (register < 0) {
				return target;
			}

			registers[register].setUsed(target, true);
		}
		return IRVar.createRegisterVar(register, target.type());
	}

	private int getFreeRegister() {
		for (int i = 0; i < registers.length; i++) {
			if (registers[i].isFree()) {
				return i;
			}
		}
		throw new UnsupportedOperationException("out of registers");
	}

	private void maybeStoreRegisterInMemory(IRVar var, Location location) {
		Utils.assertTrue(var.scope() != VariableScope.register);

		final int register = getRegister(var);
		if (register < 0) {
			return;
		}

		final IRVar registerVar = IRVar.createRegisterVar(register, var.type());
		add(new IRCopy(var, registerVar, location));
		registers[register].free();
	}

	private void storeLiveWrittenVarsFromRegister(IRInstruction instruction) {
		storeLiveWrittenVarsFromRegister(instruction, null);
	}

	private void storeReferencedVars(IRInstruction instruction) {
		storeLiveWrittenVarsFromRegister(instruction, var -> !var.canBeRegister());
	}

	private void storeLiveWrittenVarsFromRegister(IRInstruction instruction, @Nullable Predicate<IRVar> predicate) {
		for (int i = 0; i < registers.length; i++) {
			final Register register = registers[i];
			final IRVar var = register.var;
			if (var == null) {
				continue;
			}

			if (predicate != null && !predicate.test(var)) {
				continue;
			}

			Utils.assertTrue(isGlobalOrLiveAfter(var, instruction));
			if (register.usedForWrite) {
				add(new IRCopy(var, IRVar.createRegisterVar(i, var.type()), Location.DUMMY));
			}
			register.free();
		}
	}

	private void assertIsLiveBefore(IRVar var, IRInstruction instruction) {
		Utils.assertTrue(isLiveBefore(var, instruction));
	}

	private boolean isLiveBefore(IRVar var, IRInstruction instruction) {
		final Set<LiveVar> lives = block.getLiveBefore(instruction);
		return contains(var, lives);
	}

	private boolean isGlobalOrLiveAfter(IRVar var, IRInstruction instruction) {
		if (var.scope() == VariableScope.global) {
			return true;
		}

		final Set<LiveVar> live = block.getLiveAfter(instruction);
		return contains(var, live);
	}

	private void add(IRInstruction instruction) {
		instructions.add(instruction);
	}

	private int getRegister(IRVar var) {
		for (int i = 0; i < registers.length; i++) {
			final Register register = registers[i];
			if (register.contains(var)) {
				return i;
			}
		}
		return -1;
	}

	private void freeLastUsed(IRInstruction instruction) {
		final Set<LiveVar> lastUsed = block.getLastUsed(instruction);
		if (lastUsed.isEmpty()) {
			return;
		}

		for (LiveVar var : lastUsed) {
			for (int i = 0; i < registers.length; i++) {
				final Register register = registers[i];
				if (register.var != null && LiveVar.equals(var, register.var)) {
					if (var.scope() == VariableScope.global && register.usedForWrite) {
						add(new IRCopy(register.var, IRVar.createRegisterVar(i, register.var.type()), Location.DUMMY));
					}
					register.free();
					break;
				}
			}
		}
	}

	private static boolean contains(IRVar var, Set<LiveVar> lives) {
		for (LiveVar live : lives) {
			if (LiveVar.equals(live, var)) {
				return true;
			}
		}
		return false;
	}

	private static class Register {

		public final int index;
		@Nullable private IRVar var;
		private boolean usedForWrite;

		public Register(int index) {
			this.index = index;
		}

		public void setUsed(@NotNull IRVar var, boolean write) {
			Utils.assertTrue(isFree());
			this.var = var;
			usedForWrite = write;
		}

		public boolean isFree() {
			return var == null;
		}

		public void free() {
			Utils.assertTrue(!isFree());
			this.var = null;
		}

		public boolean contains(@NotNull IRVar var) {
			return var.equals(this.var);
		}

		public boolean contains(@NotNull LiveVar var) {
			return this.var != null && LiveVar.equals(var, this.var);
		}
	}
}
