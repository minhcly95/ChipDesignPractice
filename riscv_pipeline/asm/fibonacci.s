.global _start

.text
_start:
    li   x1, 1
    li   x2, 1
    add  x1, x1, x2
    sub  x2, x1, x2
    sw   x1, 0(x0)
    add  x1, x1, x2
    sub  x2, x1, x2
    sw   x1, 4(x0)
    add  x1, x1, x2
    sub  x2, x1, x2
    sw   x1, 8(x0)
    add  x1, x1, x2
    sub  x2, x1, x2
    sw   x1, 12(x0)
    add  x1, x1, x2
    sub  x2, x1, x2
    sw   x1, 16(x0)
    add  x1, x1, x2
    sub  x2, x1, x2
    sw   x1, 20(x0)
    add  x1, x1, x2
    sub  x2, x1, x2
    sw   x1, 24(x0)
    add  x1, x1, x2
    sub  x2, x1, x2
    sw   x1, 28(x0)
    add  x1, x1, x2
    sub  x2, x1, x2
    sw   x1, 32(x0)
    add  x1, x1, x2
    sub  x2, x1, x2
    sw   x1, 36(x0)
    lw   x3, 0(x0)
    lw   x4, 4(x0)
    lw   x5, 8(x0)
    lw   x6, 12(x0)
    lw   x7, 16(x0)
    lw   x8, 20(x0)
    lw   x9, 24(x0)
    lw   x10, 28(x0)
    lw   x11, 32(x0)
    lw   x12, 36(x0)
