# RISC-V Nonpipelined Processor

This is a barebone implementation of the RISC-V architecture without pipelining and any extension.

## Requirements
- Supports all instructions of the RV32I instruction set.
- Instruction and data memories have no latency.
- `FENCE` is treated as `NOP`.
- `ECALL` and `EBREAK` halt the processor and raise the `Halt` output.
- Invalid OpCode are treated as `EBREAK`.
- If `Continue` is high, resume execution from a halt.

## Structure
### Datapath

![](figures/diagram.png)

### Controller

![](figures/controller.png)

- `ShiftOp` is wired to `{Funct7[5], Funct3[2]}`.
- In `ALUDec`, `ALUCode = Funct3 | {2'b00, Funct7[5]}` if `Recode == 1` to encode for `SUB`,
otherwise `ALUCode = Funct3`.

#### Main Decoder

| `OpCode`           | `funct3`   | `ImmSel` | `{SrcASel,SrcBSel}` | `{ALUSet,ALUOp}` | `ShAmtSel` | `ExecSel` | `{RegWrite,RegDSel}` | `{Jump,Branch,BranchNeg}` |
|--------------------|------------|----------|---------------------|------------------|------------|-----------|----------------------|---------------------------|
| `0010011(OP-IMM)` | `x01`       |          |                     |                  | `1 (IMM)`  | `1 (SFT)` | `1_01 (EXEC)`        | `00x (PC4)`               |
| `0010011(OP-IMM)` | Others      | `000(I)` | `11 (REG IMM)`      | `0_xxx`          |            | `0 (ALU)` | `1_01 (EXEC)`        | `00x (PC4)`               |
| `0110011(OP)`     | `x01`       |          |                     |                  | `0 (REG)`  | `1 (SFT)` | `1_01 (EXEC)`        | `00x (PC4)`               |
| `0110011(OP)`     | Others      |          | `10 (REG REG)`      | `0_xxx`          |            | `0 (ALU)` | `1_01 (EXEC)`        | `00x (PC4)`               |
| `0110111(LUI)`    |             | `010(U)` |                     |                  |            |           | `1_10 (IMM)`         | `00x (PC4)`               |
| `0010111(AUIPC)`  |             | `010(U)` | `01 (PC  IMM)`      | `1_000 (ADD)`    |            | `0 (ALU)` | `1_01 (EXEC)`        | `00x (PC4)`               |
| `0000011(LOAD)`   |             | `000(I)` | `11 (REG IMM)`      | `1_000 (ADD)`    |            | `0 (ALU)` | `1_00 (MEM)`         | `00x (PC4)`               |
| `0100011(STORE)`  |             | `001(S)` | `11 (REG IMM)`      | `1_000 (ADD)`    |            | `0 (ALU)` | `0_xx`               | `00x (PC4)`               |
| `1101111(JAL)`    |             | `100(J)` | `01 (PC  IMM)`      | `1_000 (ADD)`    |            | `0 (ALU)` | `1_11 (PC4)`         | `1xx (JUMP)`              |
| `1100111(JALR)`   |             | `000(I)` | `11 (REG IMM)`      | `1_000 (ADD)`    |            | `0 (ALU)` | `1_11 (PC4)`         | `1xx (JUMP)`              |
| `1100010(BRANCH)` | `000(BEQ)`  | `101(B)` | `10 (REG REG)`      | `1_001 (SUB)`    |            | `0 (ALU)` | `0_xx`               | `010 (BRANCH_ZERO)`       |
| `1100010(BRANCH)` | `001(BNE)`  | `101(B)` | `10 (REG REG)`      | `1_001 (SUB)`    |            | `0 (ALU)` | `0_xx`               | `011 (BRANCH_NOTZERO)`    |
| `1100010(BRANCH)` | `100(BLT)`  | `101(B)` | `10 (REG REG)`      | `1_010 (SLT)`    |            | `0 (ALU)` | `0_xx`               | `011 (BRANCH_NOTZERO)`    |
| `1100010(BRANCH)` | `101(BGE)`  | `101(B)` | `10 (REG REG)`      | `1_010 (SLT)`    |            | `0 (ALU)` | `0_xx`               | `010 (BRANCH_ZERO)`       |
| `1100010(BRANCH)` | `110(BLTU)` | `101(B)` | `10 (REG REG)`      | `1_011 (SLTU)`   |            | `0 (ALU)` | `0_xx`               | `011 (BRANCH_NOTZERO)`    |
| `1100010(BRANCH)` | `111(BGEU)` | `101(B)` | `10 (REG REG)`      | `1_011 (SLTU)`   |            | `0 (ALU)` | `0_xx`               | `010 (BRANCH_ZERO)`       |

- Empty cells are filled with don't care (`x`).
- `MemWrite = 1` iff `Opcode == 0100011 (STORE)`. 
- `Recode = 1` iff `Opcode == 7'b0110011 (OP)`.

### Data Memory

![](figures/dmem.png)

| `MemSize` | Description |
|-|-|
| `000` | Byte (8-bit) |
| `001` | Half-word (16-bit) |
| `010` | Word (32-bit) |
| `100` | Byte with signed extension |
| `101` | Half-word with signed extension |

### ALU

![](figures/alu.png)

| `F[2:0]` | Operation |
| --- | --- |
| `000` | Addition `A + B` |
| `001` | Subtraction `A - B` |
| `010` | Set if less than (SLT) `A < B` |
| `011` | Set if less than unsigned (SLTU) |
| `10x` | XOR `A ^ B` |
| `110` | OR <code>A &#124; B</code> |
| `111` | AND `A & B` |

### Shifter

![](figures/shifter.png)

| `F[1:0] = ShiftOp` | Operation | `B` | `C` | `K` |
| --- | --- | --- | --- | --- |
| `x0` | Left shift `A << ShAmt` | `A` | `32'h0` | `~ShAmt` |
| `01` | Logical right shift `A >> ShAmt` | `32'h0` | `A` | `ShAmt` |
| `11` | Arithmetic right shift `A >>> ShAmt` | `{32{A[31]}}` | `A` | `ShAmt` |

### Imm Decoder

| Type | `ImmSel` | `Imm`                |
|------|----------|----------------------|
| I    | `000`    | `{Sign, ImmI}`       |
| S    | `001`    | `{Sign, ImmS}`       |
| U    | `010`    | `{ImmU, 12'b0}`      |
| J    | `100`    | `{Sign, ImmJ, 1'b0}` |
| B    | `101`    | `{Sign, ImmB, 1'b0}` |

