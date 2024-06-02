.global _start

.text
_start:
    # Load the base addr of the trace array
    li    x31, 0x80000000
    # Load 2 random 32-bit numbers
    li    x1, 0xbcfec832
    li    x2, 0x51290ce3
    # ---------------- OP-IMM -----------------
    # ADDI
    addi  x3, x1, 0xfffff89b # Should be 0xbcfec0cd
    sw    x3, 0(x31)
    addi  x3, x2, 0x3b2      # Should be 0x51291095
    sw    x3, 4(x31)
    # XORI
    xori  x3, x1, 0xfffff89b # Should be 0x430130a9
    sw    x3, 8(x31)
    xori  x3, x2, 0x3b2      # Should be 0x51290f51
    sw    x3, 12(x31)
    # ORI
    ori   x3, x1, 0xfffff89b # Should be 0xfffff8bb
    sw    x3, 16(x31)
    ori   x3, x2, 0x3b2      # Should be 0x51290ff3
    sw    x3, 20(x31)
    # ANDI
    andi  x3, x1, 0xfffff89b # Should be 0xbcfec812
    sw    x3, 24(x31)
    andi  x3, x2, 0x3b2      # Should be 0x000000a2
    sw    x3, 28(x31)
    # SLTI
    slti  x3, x1, 0xfffff89b # Should be 0x00000001
    sw    x3, 32(x31)
    slti  x3, x1, 0x3b2      # Should be 0x00000001
    sw    x3, 36(x31)
    slti  x3, x2, 0xfffff89b # Should be 0x00000000
    sw    x3, 40(x31)
    slti  x3, x2, 0x3b2      # Should be 0x00000000
    sw    x3, 44(x31)
    # SLTIU
    sltiu x3, x1, 0xfffff89b # Should be 0x00000001
    sw    x3, 48(x31)
    sltiu x3, x1, 0x3b2      # Should be 0x00000000
    sw    x3, 52(x31)
    sltiu x3, x2, 0xfffff89b # Should be 0x00000001
    sw    x3, 56(x31)
    sltiu x3, x2, 0x3b2      # Should be 0x00000000
    sw    x3, 60(x31)
    # SLLI
    slli  x3, x1, 11         # Should be 0xf6419000
    sw    x3, 64(x31)
    slli  x3, x2, 2          # Should be 0x44a4338c
    sw    x3, 68(x31)
    # SRLI
    srli  x3, x1, 11         # Should be 0x00179fd9
    sw    x3, 72(x31)
    srli  x3, x2, 2          # Should be 0x144a4338
    sw    x3, 76(x31)
    # SRAI
    srai  x3, x1, 11         # Should be 0xfff79fd9
    sw    x3, 80(x31)
    srai  x3, x2, 2          # Should be 0x144a4338
    sw    x3, 84(x31)
    # ------------------ OP -------------------
    # ADD
    add   x4, x1, x2         # Should be 0x0e27d515
    sw    x4, 88(x31)
    # SUB
    sub   x3, x1, x2         # Should be 0x6bd5bb4f
    sw    x3, 92(x31)
    sub   x3, x2, x1         # Should be 0x942a44b1
    sw    x3, 96(x31)
    # XOR
    xor   x3, x1, x2         # Should be 0xedd7c4d1
    sw    x3, 100(x31)
    # OR
    or    x3, x1, x2         # Should be 0xfdffccf3
    sw    x3, 104(x31)
    # AND
    and   x3, x1, x2         # Should be 0x10280822
    sw    x3, 108(x31)
    # SLT
    slt   x3, x1, x2         # Should be 0x00000001
    sw    x3, 112(x31)
    slt   x3, x2, x1         # Should be 0x00000000
    sw    x3, 116(x31)
    slt   x3, x1, x1         # Should be 0x00000000
    sw    x3, 120(x31)
    slt   x3, x2, x2         # Should be 0x00000000
    sw    x3, 124(x31)
    # SLTU
    sltu  x3, x1, x2         # Should be 0x00000000
    sw    x3, 128(x31)
    sltu  x3, x2, x1         # Should be 0x00000001
    sw    x3, 132(x31)
    # SLL
    sll   x3, x1, x2         # Should be 0xe7f64190
    sw    x3, 136(x31)
    sll   x3, x2, x1         # Should be 0x338c0000
    sw    x3, 140(x31)
    # SRL
    srl   x3, x1, x2         # Should be 0x179fd906
    sw    x3, 144(x31)
    srl   x3, x2, x1         # Should be 0x0000144a
    sw    x3, 148(x31)
    # SRA
    sra   x3, x1, x2         # Should be 0xf79fd906
    sw    x3, 152(x31)
    sra   x3, x2, x1         # Should be 0x0000144a
    sw    x3, 156(x31)
    # -------------- LUI / AUIPC --------------
    # LUI
    lui   x3, 0xc42bd        # Should be 0xc42bd000
    sw    x3, 160(x31)
    lui   x3, 0x97bd2        # Should be 0x97bd2000
    sw    x3, 164(x31)
    # AUIPC (PC is 0x164)
    auipc x3, 0xc42bd        # Should be 0xc42bd164
    sw    x3, 168(x31)
    auipc x3, 0x97bd2        # Should be 0x97bd216c
    sw    x3, 172(x31)
    # ------------- LOAD / STORE --------------
    # SB (x3 should be 0x97bd216c, x4 should be 0x0e27d515)
    sb    x1, 176(x31)
    sb    x2, 177(x31)
    sb    x3, 178(x31)
    sb    x4, 179(x31)       # Should be 0x156ce332
    # SH
    sh    x1, 180(x31)
    sh    x2, 182(x31)       # Should be 0x0ce3c832
    sh    x3, 184(x31)
    sh    x4, 186(x31)       # Should be 0xd515216c
    # LB
    lb    x3, 176(x31)       # Should be 0x00000032
    sw    x3, 188(x31)
    lb    x3, 177(x31)       # Should be 0xffffffe3
    sw    x3, 192(x31)
    # LBU
    lbu   x3, 176(x31)       # Should be 0x00000032
    sw    x3, 196(x31)
    lbu   x3, 177(x31)       # Should be 0x000000e3
    sw    x3, 200(x31)
    # LH
    lh    x3, 180(x31)       # Should be 0xffffc832
    sw    x3, 204(x31)
    lh    x3, 182(x31)       # Should be 0x00000ce3
    sw    x3, 208(x31)
    # LHU
    lhu   x3, 184(x31)       # Should be 0x0000216c
    sw    x3, 212(x31)
    lhu   x3, 186(x31)       # Should be 0x0000d515
    sw    x3, 216(x31)
