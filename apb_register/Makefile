all: build run

build:
	iverilog -g2012 -Wall -o out/sim.o -c cmdfile.txt

run:
	vvp out/sim.o

wave:
	gtkwave out/wave.vcd
