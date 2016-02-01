
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
           ${HARDWARE}/modules/dem_uart/verilog/osd_dem_uart_nasti.sv \
           ${HARDWARE}/modules/dem_uart/verilog/osd_dem_uart_16550.sv \
           ../testbench.sv \
           ../main.sv

srcs_cxx = ${GLIP}/src/backend_tcp/logic/dpi/glip_tcp_dpi.cpp \
           ${GLIP}/src/backend_tcp/logic/dpi/GlipTcp.cpp

flags = \
	-I${GLIP}/src/backend_tcp/logic/dpi -Wa,-W -fPIC -m64 -std=c++11 -shared -g -pthread

all: demo glip_test

glip_test: ../glip_test.c
	$(CC) -std=c99 -o $@ -I${GLIP}/include $^ ${GLIP_LIBS}

dpi.so: $(srcs_cxx)
	g++ $(flags) $^ -o $@

demo: $(srcs_verilog) dpi.so
	vcs -sverilog -full64 -timescale=1ns/100ps -debug_all -o $@ $^

clean:
	rm -rf demo glip_test dpi.so

.PHONY: demo all clean
