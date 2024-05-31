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
- `Recode = 1` when `Opcode == 7'b0110011 (OP)`, otherwise `0`.

### ALU

| `F[2:0]` | Operation |
| --- | --- |
| `000` | Addition `A + B` |
| `001` | Subtraction `A - B` |
| `010` | Set if less than (SLT) `A < B` |
| `011` | Set if less than unsigned (SLTU) |
| `10x` | XOR `A ^ B` |
| `110` | OR <code>A &#124; B</code> |
| `111` | AND `A & B` |

![](figures/alu.png)

### Shifter

| `F[1:0] = ShiftOp` | Operation | `B` | `C` | `K` |
| --- | --- | --- | --- | --- |
| `x0` | Left shift `A << ShAmt` | `A` | `32'h0` | `~ShAmt` |
| `01` | Logical right shift `A >> ShAmt` | `32'h0` | `A` | `ShAmt` |
| `11` | Arithmetic right shift `A >>> ShAmt` | `{32{A[31]}}` | `A` | `ShAmt` |

![](figures/shifter.png)

## Control Matrix

| `OpCode`           | `funct3` | `SrcAMux` | `SrcBMux` | `ALUSet` | `ALUOp` | `ShAmtSrc` | `DestMux` | `RegWrite` |
|--------------------|----------|-----------|-----------|----------|---------|------------|-----------|------------|
| `0010011 (OP-IMM)` | `x01`    |           |           |          |         | `1`        | `01`      | `1`        |
| `0010011 (OP-IMM)` | Others   | `1`       | `01`      | `0`      |         |            | `00`      | `1`        |
| `0110011 (OP)`     | `x01`    |           |           |          |         | `0`        | `01`      | `1`        |
| `0110011 (OP)`     | Others   | `1`       | `00`      | `0`      |         |            | `00`      | `1`        |
| `0110111 (LUI)`    |          |           |           |          |         |            | `10`      | `1`        |
| `0010111 (AUIPC)`  |          | `0`       | `10`      | `1`      | `000`   |            | `00`      | `1`        |

- Empty cells are filled with don't care (`x`).
