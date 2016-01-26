
module testbench
  (
   input clk, rst,
   input glip_logic_rst,
   glip_channel.slave fifo_in,
   glip_channel.master fifo_out
   );

   dii_channel dii_in;
   dii_channel dii_out;   

   dii_channel in_ports [1:0];
   dii_channel out_ports [1:0];   
   
   osd_him
     u_him(.*,
           .glip_in  (fifo_in),
           .glip_out (fifo_out),
           .dii_out  (dii_out),
           .dii_in   (dii_in));

   debug_ring
     #(.PORTS(2))
   u_ring(.*,
          .out (in_ports),
          .in  (out_ports));
   
endmodule // testbench
