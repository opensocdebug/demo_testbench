# Xilinx Vivado script
# Version: Vivado 2015.4
# Function:
#   Generate a vivado project for OpenSoCDebug

set origin_dir "."
set project_name tracer
set TOP          [lindex $argv 0]
set HARDWARE     [lindex $argv 1]
set GLIP         $TOP/glip

# Set the directory path for the original project from where this script was exported
set orig_proj_dir [file normalize $origin_dir/$project_name]

# Create project
create_project $project_name $origin_dir/$project_name

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [get_projects $project_name]
set_property "default_lib" "xil_defaultlib" $obj
set_property "part" "xc7a100tcsg324-1" $obj
set_property "simulator_language" "Mixed" $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set 'sources_1' fileset object
set files [list \
               [file normalize $origin_dir/../testbench.sv] \
               [file normalize $GLIP/src/common/logic/interface/glip_channel.sv] \
               [file normalize $HARDWARE/interfaces/verilog/dii_channel.sv] \
               [file normalize $HARDWARE/modules/him/verilog/osd_him.sv] \
               [file normalize $HARDWARE/interconnect/verilog/debug_ring.sv] \
               [file normalize $HARDWARE/interconnect/verilog/ring_router.sv] \
               [file normalize $HARDWARE/interconnect/verilog/ring_router_demux.sv] \
               [file normalize $HARDWARE/interconnect/verilog/ring_router_mux.sv] \
               [file normalize $HARDWARE/interconnect/verilog/ring_router_mux_rr.sv] \
               [file normalize $HARDWARE/blocks/buffer/verilog/dii_buffer.sv] \
               [file normalize $HARDWARE/blocks/statctrlif/verilog/osd_statctrlif.sv] \
               [file normalize $HARDWARE/modules/scm/verilog/osd_scm.sv] \
               [file normalize $HARDWARE/modules/dem_uart/verilog/osd_dem_uart.sv] \
]
add_files -norecurse -fileset [get_filesets sources_1] $files

# add include path
#set_property include_dirs [list \
#                               [file normalize $origin_dir/src ]\
#                              ] [get_filesets sources_1]

#set_property verilog_define [list FPGA FPGA_FULL NEXYS4] [get_filesets sources_1]

# Set 'sources_1' fileset properties
set_property "top" "testbench" [get_filesets sources_1]

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

# Add/Import constrs file and set constrs file properties
#set file "[file normalize "$origin_dir/constraint/pin_plan.xdc"]"
#set file_added [add_files -norecurse -fileset $obj $file]

# generate all IP source code
#generate_target all [get_ips]

# force create the synth_1 path (need to make soft link in Makefile)
#launch_runs -scripts_only synth_1


# Create 'sim_1' fileset (if not found)
#if {[string equal [get_filesets -quiet sim_1] ""]} {
#  create_fileset -simset sim_1
#}

# Set 'sim_1' fileset object
#set obj [get_filesets sim_1]
#set files [list \
#               [file normalize $base_dir/src/test/verilog/chip_top_tb.sv] \
#              ]
#add_files -norecurse -fileset $obj $files

# add include path
#set_property include_dirs [list \
#                               [file normalize $origin_dir/src] \
#                              ] $obj
#set_property verilog_define [list FPGA] $obj

#set_property -name {xsim.elaborate.xelab.more_options} -value {-cc gcc -sv_lib dpi} -objects $obj
#set_property "top" "tb" $obj

# force create the sim_1/behav path (need to make soft link in Makefile)
#launch_simulation -scripts_only
