
ifndef XILINX_VIVADO
$(error Please set environment variable XILINX_VIVADO for Xilinx tools)
endif

ifndef HARDWARE
$(error Please set environment variable HARDWARE to the path of OpenSoCDebug/hardware)
endif

ifndef TOP
$(error Please set environment variable TOP to the path of OpenSoCDebug/demo_testbench)
endif

VIVADO = vivado
project_name = tracer

srcs_verilog = \
	../testbench.sv \
	${HARDWARE}/interfaces/verilog/dii_channel.sv \
	${HARDWARE}/modules/him/verilog/osd_him.sv \
	${HARDWARE}/interconnect/verilog/debug_ring.sv \
	${HARDWARE}/interconnect/verilog/ring_router.sv \
	${HARDWARE}/interconnect/verilog/ring_router_demux.sv \
	${HARDWARE}/interconnect/verilog/ring_router_mux.sv \
	${HARDWARE}/interconnect/verilog/ring_router_mux_rr.sv \
	${HARDWARE}/blocks/buffer/verilog/dii_buffer.sv \
	${HARDWARE}/blocks/regaccess/verilog/osd_regaccess.sv \
        ${HARDWARE}/blocks/regaccess/verilog/osd_regaccess_demux.sv \
        ${HARDWARE}/blocks/regaccess/verilog/osd_regaccess_layer.sv \
	${HARDWARE}/modules/scm/verilog/osd_scm.sv \
	${HARDWARE}/modules/dem_uart/verilog/osd_dem_uart.sv \
	${HARDWARE}/modules/dem_uart/verilog/osd_dem_uart_nasti.sv \
	${HARDWARE}/modules/dem_uart/verilog/osd_dem_uart_16550.sv \

project = $(project_name)/$(project_name).xpr
project: $(project)
$(project): | $(srcs_verilog)
	$(VIVADO) -mode batch -source mk_project.tcl -tclargs $(TOP) $(HARDWARE)

vivado: $(project)
	$(VIVADO) $(project) &

all: project

.PHONY: all clean project

clean:
	rm -rf $(project_name)
