all: build run

build:
	iverilog -g2012 -Wall -o out/testbench.o -c compile.f

run:
	out/testbench.o

wave:
	gtkwave out/wave.vcd

build-asm:
	riscv64-linux-gnu-as -march=rv32i -o asm/fibonacci.o asm/fibonacci.s
	riscv64-linux-gnu-objcopy -j .text -O binary asm/fibonacci.o asm/fibonacci.bin

figure:
	convert -alpha remove figures/diagram.ps figures/diagram.png
	convert -alpha remove figures/controller.ps figures/controller.png
	convert -alpha remove figures/alu.ps figures/alu.png
	convert -alpha remove figures/shifter.ps figures/shifter.png
