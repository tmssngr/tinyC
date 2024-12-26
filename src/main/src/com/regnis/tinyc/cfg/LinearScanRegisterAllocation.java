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

	public static ControlFlowGraph process(@NotNull ControlFlowGraph cfg, @NotNull IRCanBeRegister canBeRegister, int maxRegisters) {
		final Map<String, BasicBlock> blocks = new HashMap<>();
		for (BasicBlock block : cfg.blocks()) {
			final LinearScanRegisterAllocation allocation = new LinearScanRegisterAllocation(block, canBeRegister, maxRegisters);
			final BasicBlock newBlock = allocation.process();
			blocks.put(newBlock.name, newBlock);
		}
		return new ControlFlowGraph(cfg.name(), blocks);
	}

	private final List<IRInstruction> instructions = new ArrayList<>();
	private final BasicBlock block;
	private final IRCanBeRegister canBeRegister;
	private final RegisterMap registerMap;

	private List<Object> lastDebugInfos;
	private boolean produceDebugInstructions;
	private int index;

	public LinearScanRegisterAllocation(@NotNull BasicBlock block, @NotNull IRCanBeRegister canBeRegister, int maxRegisters) {
		this.block = block;
		this.canBeRegister = canBeRegister;
		this.registerMap = new RegisterMap(maxRegisters);
	}

	public BasicBlock process() {
		final List<IRInstruction> instructions = block.instructions();
		for (index = 0; index < instructions.size(); index++) {
			final IRInstruction instruction = instructions.get(index);
			process(instruction);
		}
		return new BasicBlock(block.name, this.instructions, block.predecessors(), block.successors());
	}

	public void setProduceDebugInstructions() {
		produceDebugInstructions = true;
	}

	private void process(IRInstruction instruction) {
		logDebugState();

		maybeSpillRegisters(instruction);

		logDebugState();

		switch (instruction) {
		case IRAddrOf addrOf -> processAddrOf(addrOf);
		case IRAddrOfArray addrOfArray -> processAddrOfArray(addrOfArray);
		case IRBinary binary -> processBinary(binary);
		case IRBranch branch -> processBranch(branch);
		case IRCall call -> processCall(call);
		case IRCast cast -> processCast(cast);
		case IRComment ignored -> add(instruction);
		case IRCompare compare -> processCompare(compare);
		case IRJump jump -> processJump(jump);
		case IRLiteral literal -> processLiteral(literal);
		case IRMemLoad load -> processMemLoad(load);
		case IRMemStore store -> processMemStore(store);
		case IRMove move -> processMove(move);
		case IRRetValue retValue -> processRetValue(retValue);
		case IRString literal -> processString(literal);
		case IRUnary unary -> processUnary(unary);
		default -> throw new UnsupportedOperationException(String.valueOf(instruction));
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

		final Set<IRVar> liveBefore = block.getLiveBefore(index);
		final Set<IRVar> lastUsed = block.getLastUsed(index);

		final Set<IRVar> uses = new HashSet<>();
		final Set<IRVar> defines = new HashSet<>();
		DetectVarLiveness.detectLiveness(instruction, uses, defines);
		registerMap.maybeSpillRegisters(liveBefore, lastUsed, uses, defines,
		                                (var, registerVar) -> {
			                                add(new IRComment("Spill " + var.name()));
			                                add(new IRMove(var, registerVar, Location.DUMMY));
		                                });
	}

	private void processLiteral(IRLiteral instruction) {
		final IRVar target = instruction.target();
		if (!isGlobalOrLiveAfter(target)) {
			return;
		}

		final IRVar targetReg = targetRegister(target);
		add(new IRLiteral(targetReg, instruction.value(), instruction.location()));
	}

	private void processString(IRString instruction) {
		final IRVar target = instruction.target();
		if (!isGlobalOrLiveAfter(target)) {
			return;
		}

		final IRVar targetReg = targetRegister(target);
		add(new IRString(targetReg, instruction.stringIndex(), instruction.location()));
	}

	private void processAddrOf(IRAddrOf instruction) {
		final IRVar target = instruction.target();
		if (!isGlobalOrLiveAfter(target)) {
			return;
		}

		final IRVar source = instruction.source();
		assertIsLiveBefore(source);
		Utils.assertTrue(source.scope() != VariableScope.register);

		final IRVar registerVar = registerMap.maybeFreeRegister(source);
		if (registerVar != null) {
			add(new IRMove(source, registerVar, instruction.location()));
		}
		final IRVar var = targetRegister(target);
		add(new IRAddrOf(var, source, instruction.location()));
	}

	private void processAddrOfArray(IRAddrOfArray instruction) {
		final IRVar target = instruction.addr();
		if (!isGlobalOrLiveAfter(target)) {
			return;
		}

		final IRVar arrayOrPointer = instruction.array();
		freeLastUsed();
		final IRVar targetReg = targetRegister(target);
		add(new IRAddrOfArray(targetReg, arrayOrPointer, instruction.location()));
	}

	private void processBinary(IRBinary instruction) {
		final IRVar target = instruction.target();
		if (!isGlobalOrLiveAfter(target)) {
			return;
		}

		final IRVar left = loadIntoRegister(instruction.left());
		final IRVar right = loadIntoRegister(instruction.right());
		freeLastUsed();
		final IRVar targetReg = targetRegister(target);
		add(new IRBinary(targetReg, instruction.op(), left, right, instruction.location()));
	}

	private void processCompare(IRCompare instruction) {
		final IRVar target = instruction.target();
		if (!isGlobalOrLiveAfter(target)) {
			return;
		}

		final IRVar left = loadIntoRegister(instruction.left());
		final IRVar right = loadIntoRegister(instruction.right());
		freeLastUsed();
		final IRVar targetReg = targetRegister(target);
		add(new IRCompare(targetReg, instruction.op(), left, right, instruction.location()));
	}

	private void processCast(IRCast instruction) {
		final IRVar target = instruction.target();
		if (!isGlobalOrLiveAfter(target)) {
			return;
		}

		final IRVar source = loadIntoRegister(instruction.source());
		freeLastUsed();
		final IRVar targetReg = targetRegister(target);
		add(new IRCast(targetReg, source, instruction.location()));
	}

	private void processUnary(IRUnary instruction) {
		final IRVar target = instruction.target();
		if (!isGlobalOrLiveAfter(target)) {
			return;
		}

		final IRVar source = loadIntoRegister(instruction.source());
		freeLastUsed();
		final IRVar targetReg = targetRegister(target);
		add(new IRUnary(instruction.op(), targetReg, source));
	}

	private void processMove(IRMove instruction) {
		final IRVar target = instruction.target();
		if (!isGlobalOrLiveAfter(target)) {
			return;
		}

		final IRVar source = loadIntoRegister(instruction.source());
		freeLastUsed();
		final IRVar targetReg = targetRegister(target);
		Utils.assertTrue(source.scope() == VariableScope.register);
		Utils.assertTrue(targetReg.scope() == VariableScope.register);
		if (source.index() != targetReg.index()) {
			add(new IRMove(targetReg, source, instruction.location()));
		}
	}

	private void processMemLoad(IRMemLoad instruction) {
		final IRVar target = instruction.target();
		if (!isGlobalOrLiveAfter(target)) {
			return;
		}

		storeReferencedVars();

		final IRVar addr = loadIntoRegister(instruction.addr());
		freeLastUsed();
		final IRVar targetReg = targetRegister(target);
		add(new IRMemLoad(targetReg, addr, instruction.location()));
	}

	private void processMemStore(IRMemStore instruction) {
		storeReferencedVars();

		final IRVar addr = loadIntoRegister(instruction.addr());
		final IRVar value = loadIntoRegister(instruction.value());
		freeLastUsed();
		add(new IRMemStore(addr, value, instruction.location()));
	}

	private void processCall(IRCall instruction) {
		final List<IRVar> args = new ArrayList<>();
		for (IRVar arg : instruction.args()) {
			final IRVar var = getVar(arg);
			args.add(var);
		}

		freeLastUsed();
		storeLiveWrittenVarsFromRegister();

		IRVar target = instruction.target();
		if (target != null) {
			if (isGlobalOrLiveAfter(target)) {
				target = registerMap.useRegisterForWriting(target);
			}
			else {
				target = null;
			}
		}
		add(new IRCall(target, instruction.name(), args, instruction.location()));
	}

	private void processRetValue(IRRetValue instruction) {
		final IRVar var = loadIntoRegister(instruction.var());
		freeLastUsed();
		storeLiveWrittenVarsFromRegister();
		add(new IRRetValue(var, instruction.location()));
	}

	private void processBranch(IRBranch instruction) {
		final IRVar condition = loadIntoRegister(instruction.conditionVar());
		freeLastUsed();
		storeLiveWrittenVarsFromRegister();
		add(new IRBranch(condition, instruction.jumpOnTrue(), instruction.target(), instruction.nextLabel()));
	}

	private void processJump(IRJump instruction) {
		storeLiveWrittenVarsFromRegister();
		add(instruction);
	}

	private IRVar getVar(IRVar var) {
		assertIsLiveBefore(var);
		final IRVar registerVar = registerMap.getRegisterVar(var);
		return registerVar != null ? registerVar : var;
	}

	private IRVar loadIntoRegister(IRVar var) {
		assertIsLiveBefore(var);
		final IRVar registerVar = registerMap.getRegisterVar(var);
		if (registerVar != null) {
			return registerVar;
		}

		final IRVar regVar = registerMap.useRegisterForReading(var);
		add(new IRMove(regVar, var, Location.DUMMY));
		return regVar;
	}

	@NotNull
	private IRVar targetRegister(IRVar var) {
		return registerMap.useRegisterForWriting(var);
	}

	private void assertIsLiveBefore(IRVar var) {
		Utils.assertTrue(isLiveBefore(var));
	}

	private boolean isLiveBefore(IRVar var) {
		final Set<IRVar> lives = block.getLiveBefore(index);
		return RegisterMap.contains(var, lives);
	}

	private boolean isGlobalOrLiveAfter(IRVar var) {
		if (var.scope() == VariableScope.global) {
			return true;
		}

		final Set<IRVar> live = block.getLiveAfter(index);
		return RegisterMap.contains(var, live);
	}

	private void storeLiveWrittenVarsFromRegister() {
		storeAll(
				var -> RegisterMap.FreeOp.StoreWrittenAndFree);
	}

	private void storeReferencedVars() {
		storeAll(var -> canBeRegister.canBeRegister(var)
				? RegisterMap.FreeOp.Skip
				: RegisterMap.FreeOp.StoreWrittenAndFree);
	}

	private void freeLastUsed() {
		final Set<IRVar> lastUsed = block.getLastUsed(index);
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
				                    -> add(new IRMove(var, registerVar, Location.DUMMY)));
	}

	private void add(IRInstruction instruction) {
		instructions.add(instruction);
	}
}
