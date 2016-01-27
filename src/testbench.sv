
module testbench
  (
   input clk, rst,
   input glip_logic_rst,
   glip_channel.slave fifo_in,
   glip_channel.master fifo_out
   );

   localparam N = 3;

   /* Modules->Ring */
   dii_channel in_ports [N-1:0];
   /* Ring->Modules */
   dii_channel out_ports [N-1:0];   

   osd_him
     u_him(.*,
           .glip_in  (fifo_in),
           .glip_out (fifo_out),
           .dii_out  (out_ports[0]),
           .dii_in   (in_ports[0]));

   osd_scm
     #(.VENDORID(8'h0), .SYSTEMID(8'h0), .NUM_MOD(N-1))
   u_scm(.*,
         .debug_in  (in_ports[1]),
         .debug_out (out_ports[1]));

   osd_dem_uart
     u_uart (.*,
             .debug_in  (in_ports[2]),
             .debug_out (out_ports[2]),
             .out_char  ('x),
             .out_valid (0),
             .out_ready (),
             .in_char   (),
             .in_valid  (),
             .in_ready  (1));

   dii_channel_flat #(.N(N)) in_flat;
   dii_channel_flat #(.N(N)) out_flat;

   genvar i;
   generate
      for (i = 0; i < N; i = i + 1) begin
         assign out_flat.data[(i+1)*16-1:i*16] = out_ports[i].data;
         assign out_flat.first[i] = out_ports[i].first;
         assign out_flat.last[i]  = out_ports[i].last;
         assign out_flat.valid[i] = out_ports[i].valid;
         assign out_ports[i].ready = out_flat.ready[i];
         assign in_ports[i].data = in_flat.data[(i+1)*16-1:i*16];
         assign in_ports[i].first = in_flat.first[i];
         assign in_ports[i].last = in_flat.last[i];
         assign in_ports[i].valid = in_flat.valid[i];
         assign in_flat.ready[i] = in_ports[i].ready;
      end
   endgenerate


   debug_ring
     #(.PORTS(N))
   u_ring(.*,
          .in_flat  (out_flat),
          .out_flat (in_flat));

endmodule // testbench
