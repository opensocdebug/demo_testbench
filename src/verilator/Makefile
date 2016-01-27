
VERILATOR ?= verilator
GLIP ?= ${TOP}/glip
HARDWARE ?= ${TOP}/osd-hardware

GLIP_LIBS=$(shell pkg-config --libs libglip)

srcs_verilog = testbench_verilator.sv \
           ${GLIP}/src/backend_tcp/logic/dpi/glip_tcp_toplevel.sv \
           ${GLIP}/src/common/logic/interface/glip_channel.sv \
           ../testbench.sv \
           ${HARDWARE}/interfaces/verilog/dii_channel.sv \
           ${HARDWARE}/interfaces/verilog/dii_channel_flat.sv \
           ${HARDWARE}/modules/him/verilog/osd_him.sv \
           ${HARDWARE}/interconnect/verilog/debug_ring.sv \
           ${HARDWARE}/interconnect/verilog/ring_router.sv \
           ${HARDWARE}/interconnect/verilog/ring_router_demux.sv \
           ${HARDWARE}/interconnect/verilog/ring_router_mux.sv \
           ${HARDWARE}/interconnect/verilog/ring_router_mux_rr.sv \
           ${HARDWARE}/blocks/buffer/verilog/dii_buffer.sv \
           ${HARDWARE}/modules/scm/verilog/osd_scm.sv \
           ${HARDWARE}/modules/dem_uart/verilog/osd_dem_uart.sv

srcs_cxx = main.cpp \
           ${GLIP}/src/backend_tcp/logic/dpi/glip_tcp_dpi.cpp \
           ${GLIP}/src/backend_tcp/logic/dpi/GlipTcp.cpp

flags = -CFLAGS "-I${GLIP}/src/backend_tcp/logic/dpi -std=c++11 -g" -LDFLAGS "-pthread" --exe --trace --sv --unroll-count 256 --Wno-fatal

all: demo glip_test

glip_test: glip_test.c
	$(CC) -o glip_test -I${GLIP}/include glip_test.c ${GLIP_LIBS}

demo: obj_dir/Vtestbench_verilator.mk Makefile
	make -C obj_dir -f Vtestbench_verilator.mk

obj_dir/Vtestbench_verilator.mk: $(srcs_verilog) $(srcs_cxx) Makefile
	$(VERILATOR) --cc $(srcs_verilog) $(srcs_cxx) $(flags) -o ../demo
	touch obj_dir/Vtestbench_verilator.mk

clean:
	rm -rf demo obj_dir glip_test
