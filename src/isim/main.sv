
`timescale 1ns/100ps

module main;
   reg clk, rst;

   testbench_top top(.*);


   initial begin
      rst = 1'b1;
      #15;
      rst = 1'b0;
   end

   initial begin
      clk = 0;
      #10;
      forever #5 clk = !clk;
   end

endmodule // main
