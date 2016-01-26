
module testbench
  (
   input clk, rst,
   input glip_logic_rst,
   glip_channel.slave fifo_in,
   glip_channel.master fifo_out
   );

   dii_channel in_ports [1:0];
   dii_channel out_ports [1:0];   

   osd_him
     u_him(.*,
           .glip_in  (fifo_in),
           .glip_out (fifo_out),
           .dii_out  (out_ports[0]),
           .dii_in   (in_ports[1]));

   debug_ring
     #(.PORTS(2))
   u_ring(.*,
          .in_flat_data ({out_ports[1].data, out_ports[0].data}),
          .in_flat_first ({out_ports[1].first, out_ports[0].first}),
          .in_flat_last ({out_ports[1].last, out_ports[0].last}),
          .in_flat_valid ({out_ports[1].valid, out_ports[0].valid}),
          .in_flat_ready ({out_ports[1].ready, out_ports[0].ready}),
          .out_flat_data ({in_ports[1].data, in_ports[0].data}),
          .out_flat_first ({in_ports[1].first, in_ports[0].first}),
          .out_flat_last ({in_ports[1].last, in_ports[0].last}),
          .out_flat_valid ({in_ports[1].valid, in_ports[0].valid}),
          .out_flat_ready ({in_ports[1].ready, in_ports[0].ready}));
   
endmodule // testbench
