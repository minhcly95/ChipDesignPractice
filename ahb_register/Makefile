all: build run

build:
	verilator --trace --binary -j 0 rtl/*.sv dv/testbench.sv

run:
	obj_dir/Vahb_register

wave:
	gtkwave out/wave.vcd

figure:
	convert -alpha remove figures/diagram.ps figures/diagram.png
	convert -alpha remove figures/fsm.ps figures/fsm.png
