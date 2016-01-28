
module testbench
  (
   input clk, rst,
   input glip_logic_rst,
   glip_channel.slave fifo_in,
   glip_channel.master fifo_out
   );

   localparam N = 3;

   /* Modules->Ring */
   dii_channel in_ports [N-1:0] ();
   /* Ring->Modules */
   dii_channel out_ports [N-1:0] ();   

   osd_him
     u_him(.*,
           .glip_in  (fifo_in),
           .glip_out (fifo_out),
           .dii_out  (out_ports[0]),
           .dii_in   (in_ports[0]));

   osd_scm
     #(.SYSTEMID(16'hdead), .NUM_MOD(N-1))
   u_scm(.*,
         .id (10'd1),
         .debug_in  (in_ports[1]),
         .debug_out (out_ports[1]));

   osd_dem_uart
     u_uart (.*,
             .debug_in  (in_ports[2]),
             .debug_out (out_ports[2]),
             .out_char  ('x),
             .out_valid ('0),
             .out_ready (),
             .in_char   (),
             .in_valid  (),
             .in_ready  ('1));

   dii_channel #(.N(N)) dii_in ();
   dii_channel #(.N(N)) dii_out ();

   genvar i;
   generate
      for (i = 0; i < N; i++) begin
         assign out_ports[i].ready = dii_out.assemble(out_ports[i].data,
                                                      out_ports[i].first,
                                                      out_ports[i].last,
                                                      out_ports[i].valid,
                                                      i);
         // here is a bug for Verilator,it cannot recognize in_port[i] as an interface
         //assign dii_in.ready[i] = in_ports[i].assemble(dii_in.data[i],
         //                                              dii_in.first[i],
         //                                              dii_in.last[i],
         //                                              dii_in.valid[i]);
         assign in_ports[i].data = dii_in.data[i];
         assign in_ports[i].first = dii_in.first[i];
         assign in_ports[i].last = dii_in.last[i];
         assign in_ports[i].valid = dii_in.valid[i];
         assign dii_in.ready[i] = in_ports[i].ready;
      end
   endgenerate


   debug_ring
     #(.PORTS(N))
   u_ring(.*,
          .dii_in  (dii_out),
          .dii_out (dii_in));

endmodule // testbench
