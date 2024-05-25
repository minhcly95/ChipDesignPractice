all: build run

build:
	verilator --trace --binary -j 0 -o Vaxi_apb_bridge rtl/*.sv dv/testbench.sv dv/ip/apb_register.sv

run:
	obj_dir/Vaxi_apb_bridge

wave:
	gtkwave out/wave.vcd

clean:
	rm -r obj_dir

figure:
	convert -alpha remove figures/diagram.ps figures/diagram.png
	convert -alpha remove figures/rwarbiter.ps figures/rwarbiter.png
	convert -alpha remove figures/apbcontroller.ps figures/apbcontroller.png
	convert -alpha remove figures/wreq.ps figures/wreq.png
	convert -alpha remove figures/rreq.ps figures/rreq.png
