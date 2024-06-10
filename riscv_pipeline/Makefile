FIGURE = fetch.png decode.png execute.png memory.png writeback.png fwd_mux.png src_mux.png alsu.png shifter.png flow_ctrl.png dmem.png
ASM = fibonacci.bin basic_test.bin

.PHONY: all build run wave build-asm figure

all: build run

build:
	iverilog -g2012 -Wall -o out/testbench.o -c compile.f

run:
	out/testbench.o

wave:
	gtkwave out/wave.vcd

build-asm: $(addprefix asm/,$(ASM))

asm/%.bin: asm/%.s
	riscv64-linux-gnu-as -march=rv32i -o asm/$*.o $<
	riscv64-linux-gnu-objcopy -j .text -O binary asm/$*.o $@

figure: $(addprefix figures/,$(FIGURE))

figures/%.png: figures/%.ps
	convert -alpha remove $< $@
