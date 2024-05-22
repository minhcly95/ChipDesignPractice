all: build run

build:
	verilator --trace --binary -j 0 -o Vaxi_register rtl/*.sv dv/testbench.sv

run:
	obj_dir/Vaxi_register

wave:
	gtkwave out/wave.vcd

figure:
	convert -alpha remove figures/diagram.ps figures/diagram.png
