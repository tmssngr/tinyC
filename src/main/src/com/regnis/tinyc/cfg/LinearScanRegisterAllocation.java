package com.regnis.tinyc.cfg;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;
import java.util.function.Function;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class LinearScanRegisterAllocation {

	public static ControlFlowGraph process(ControlFlowGraph cfg, int maxRegisters) {
		final Map<String, BasicBlock> blocks = new HashMap<>();
		for (BasicBlock block : cfg.blocks()) {
			final LinearScanRegisterAllocation allocation = new LinearScanRegisterAllocation(block, maxRegisters);
			final BasicBlock newBlock = allocation.process();
			blocks.put(newBlock.name, newBlock);
		}
		return new ControlFlowGraph(cfg.name(), blocks);
	}

	private final List<IRInstruction> instructions = new ArrayList<>();
	private final BasicBlock block;
	private final RegisterMap registerMap;

	private List<Object> lastDebugInfos;
	private boolean produceDebugInstructions;

	public LinearScanRegisterAllocation(BasicBlock block, int maxRegisters) {
		this.block = block;
		this.registerMap = new RegisterMap(maxRegisters);
	}

	public BasicBlock process() {
		for (IRInstruction instruction : block.instructions()) {
			process(instruction);
		}
		return new BasicBlock(block.name, instructions, block.predecessors(), block.successors());
	}

	public void setProduceDebugInstructions() {
		produceDebugInstructions = true;
	}

	private void process(IRInstruction instruction) {
		logDebugState();

		maybeSpillRegisters(instruction);

		logDebugState();

		switch (instruction) {
		case IRLiteral literal -> processLiteral(literal);
		case IRString literal -> processString(literal);
		case IRAddrOf addrOf -> processAddrOf(addrOf);
		case IRAddrOfArray addrOfArray -> processAddrOfArray(addrOfArray);
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
		logDebugState();
	}

	private void logDebugState() {
		if (!produceDebugInstructions) {
			return;
		}

		final List<Object> debugInfos = registerMap.createDebugState();
		if (Objects.equals(lastDebugInfos, debugInfos)) {
			return;
		}

		lastDebugInfos = debugInfos;
		add(new IRDebugComment(debugInfos));
	}

	private void maybeSpillRegisters(IRInstruction instruction) {
		if (instruction instanceof IRComment
		    || instruction instanceof IRCall) {
			return;
		}

		final Set<IRVar> liveBefore = block.getLiveBefore(instruction);
		final Set<IRVar> lastUsed = block.getLastUsed(instruction);

		final Set<IRVar> uses = new HashSet<>();
		final Set<IRVar> defines = new HashSet<>();
		DetectVarLiveness.detectLiveness(instruction, uses, defines);
		registerMap.maybeSpillRegisters(liveBefore, lastUsed, uses, defines,
		                                (var, registerVar) -> {
			                                add(new IRComment("Spill " + var.name()));
			                                add(new IRCopy(var, registerVar, Location.DUMMY));
		                                });
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
		Utils.assertTrue(source.scope() != VariableScope.register);

		final IRVar registerVar = registerMap.maybeFreeRegister(source);
		if (registerVar != null) {
			add(new IRCopy(source, registerVar, instruction.location()));
		}
		final IRVar var = targetRegister(target);
		add(new IRAddrOf(var, source, instruction.location()));
	}

	private void processAddrOfArray(IRAddrOfArray instruction) {
		final IRVar target = instruction.addr();
		if (!isGlobalOrLiveAfter(target, instruction)) {
			return;
		}

		final IRVar arrayOrPointer = instruction.array();
		freeLastUsed(instruction);
		final IRVar targetReg = targetRegister(target);
		add(new IRAddrOfArray(targetReg, arrayOrPointer, instruction.location()));
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
				target = registerMap.useRegisterForWriting(target);
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
		final IRVar registerVar = registerMap.getRegisterVar(var);
		return registerVar != null ? registerVar : var;
	}

	private IRVar loadIntoRegister(IRVar var, IRInstruction instruction) {
		assertIsLiveBefore(var, instruction);
		final IRVar registerVar = registerMap.getRegisterVar(var);
		if (registerVar != null) {
			return registerVar;
		}

		final IRVar regVar = registerMap.useRegisterForReading(var);
		add(new IRCopy(regVar, var, Location.DUMMY));
		return regVar;
	}

	@NotNull
	private IRVar targetRegister(IRVar var) {
		return registerMap.useRegisterForWriting(var);
	}

	private void assertIsLiveBefore(IRVar var, IRInstruction instruction) {
		Utils.assertTrue(isLiveBefore(var, instruction));
	}

	private boolean isLiveBefore(IRVar var, IRInstruction instruction) {
		final Set<IRVar> lives = block.getLiveBefore(instruction);
		return RegisterMap.contains(var, lives);
	}

	private boolean isGlobalOrLiveAfter(IRVar var, IRInstruction instruction) {
		if (var.scope() == VariableScope.global) {
			return true;
		}

		final Set<IRVar> live = block.getLiveAfter(instruction);
		return RegisterMap.contains(var, live);
	}

	private void storeLiveWrittenVarsFromRegister(IRInstruction instruction) {
		storeAll(
				var -> RegisterMap.FreeOp.StoreWrittenAndFree);
	}

	private void storeReferencedVars(IRInstruction instruction) {
		storeAll(var -> var.canBeRegister()
				? RegisterMap.FreeOp.Skip
				: RegisterMap.FreeOp.StoreWrittenAndFree);
	}

	private void freeLastUsed(IRInstruction instruction) {
		final Set<IRVar> lastUsed = block.getLastUsed(instruction);
		storeAll(var -> {
			if (!RegisterMap.contains(var, lastUsed)) {
				return RegisterMap.FreeOp.Skip;
			}
			return var.scope() == VariableScope.global
					? RegisterMap.FreeOp.StoreWrittenAndFree
					: RegisterMap.FreeOp.Free;
		});
	}

	private void storeAll(Function<IRVar, RegisterMap.FreeOp> function) {
		registerMap.freeAll(function,
		                    (var, registerVar)
				                    -> add(new IRCopy(var, registerVar, Location.DUMMY)));
	}

	private void add(IRInstruction instruction) {
		instructions.add(instruction);
	}
}
