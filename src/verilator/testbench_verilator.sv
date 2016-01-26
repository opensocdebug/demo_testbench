
module testbench_verilator
  (input clk, rst);

   localparam WIDTH = 16;
   
   glip_channel #(.WIDTH(WIDTH)) fifo_in (.clk(clk));
   glip_channel #(.WIDTH(WIDTH)) fifo_out (.clk(clk));   

   logic logic_rst, com_rst;
   
   glip_tcp_toplevel
     #(.WIDTH(WIDTH))
   u_glip(.clk_io    (clk),
          .clk_logic (clk),
          .rst       (rst),
          .logic_rst (logic_rst),
          .com_rst   (com_rst),
          .fifo_in   (fifo_in),
          .fifo_out  (fifo_out));

   assign logic_rst = rst;
   
   testbench
     u_tb(.*,
          .fifo_in        (fifo_in),
          .fifo_out       (fifo_out),
          .glip_logic_rst (logic_rst));

endmodule // testbench_verilator
