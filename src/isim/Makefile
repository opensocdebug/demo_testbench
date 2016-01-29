
ifndef XILINX_VIVADO
$(error Please set environment variable XILINX_VIVADO for Xilinx tools)
endif

ifndef HARDWARE
$(error Please set environment variable HARDWARE to the path of OpenSoCDebug/hardware)
endif

ifndef TOP
$(error Please set environment variable TOP to the path of OpenSoCDebug/demo_testbench)
endif

GLIP ?= ${TOP}/glip
#HARDWARE ?= ${TOP}/osd-hardware

GLIP_LIBS=$(shell pkg-config --libs libglip)

srcs_verilog = ../testbench_top.sv \
           ${GLIP}/src/backend_tcp/logic/dpi/glip_tcp_toplevel.sv \
           ${GLIP}/src/common/logic/interface/glip_channel.sv \
           ../testbench.sv \
           ${HARDWARE}/interfaces/verilog/dii_channel.sv \
           ${HARDWARE}/modules/him/verilog/osd_him.sv \
           ${HARDWARE}/interconnect/verilog/debug_ring.sv \
           ${HARDWARE}/interconnect/verilog/ring_router.sv \
           ${HARDWARE}/interconnect/verilog/ring_router_demux.sv \
           ${HARDWARE}/interconnect/verilog/ring_router_mux.sv \
           ${HARDWARE}/interconnect/verilog/ring_router_mux_rr.sv \
           ${HARDWARE}/blocks/buffer/verilog/dii_buffer.sv \
           ${HARDWARE}/blocks/statctrlif/verilog/osd_statctrlif.sv \
           ${HARDWARE}/modules/scm/verilog/osd_scm.sv \
           ${HARDWARE}/modules/dem_uart/verilog/osd_dem_uart.sv \
           main.sv

srcs_cxx = ${GLIP}/src/backend_tcp/logic/dpi/glip_tcp_dpi.cpp \
           ${GLIP}/src/backend_tcp/logic/dpi/GlipTcp.cpp

flags = \
	-I${GLIP}/src/backend_tcp/logic/dpi -I$(XILINX_VIVADO)/data/xsim/include \
	-Wa,-W -fPIC -m64 -std=c++11 -shared -g -pthread

all: demo glip_test

glip_test: glip_test.c
	$(CC) -o glip_test -I${GLIP}/include glip_test.c ${GLIP_LIBS}

xsim.dir/xsim.svtype: $(srcs_verilog)
	xvlog -sv $(srcs_verilog)

xsim.dir/xsc/dpi.so: $(srcs_cxx)
	-mkdir -p xsim.dir/xsc
	g++ $(flags) $(srcs_cxx) $(XILINX_VIVADO)/lib/lnx64.o/librdi_simulator_kernel.so -o $@

demo: xsim.dir/demo/xsimk
xsim.dir/demo/xsimk: xsim.dir/xsim.svtype xsim.dir/xsc/dpi.so
	xelab -timescale 1ns/100ps work.main --snapshot demo -cc gcc -sv_lib dpi -debug all

sim: xsim.dir/demo/xsimk
	xsim demo

clean:
	rm -rf demo glip_test xsim.dir

.PHONY: demo all clean sim
