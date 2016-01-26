This is a testbench demo. It will run in verilator simulation and on
an FPGA.

## Run the verilator test

    export TOP=`pwd`
    cd src/verilator
    make
    ./demo

Currently you are clearly developing the hardware and not testing
anything, hence set the `HARDWARE` environment variable to your local
git clone of `opensocdebug/hardware.git`.