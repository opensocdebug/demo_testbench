
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

   logic [7:0] uart_char;
   logic       uart_valid;
   logic       uart_ready;
   reg [4:0]   counter;

   always_ff @(posedge clk) begin
      if (rst) begin
         counter <= 0;
      end else begin
         if (uart_ready & (counter < 14)) begin
            counter <= counter + 1;
         end
      end
   end

   always_comb @(*) begin
      uart_valid = 1;
      uart_char = 'x;
      
      case (counter)
        0: uart_char = 8'h48;
        1: uart_char = 8'h65;
        2: uart_char = 8'h6c;
        3: uart_char = 8'h6c;
        4: uart_char = 8'h6f;
        5: uart_char = 8'h20;
        6: uart_char = 8'h57;
        7: uart_char = 8'h6f;
        8: uart_char = 8'h72;
        9: uart_char = 8'h6c;
        10: uart_char = 8'h64;
        11: uart_char = 8'h21;
        12: uart_char = 8'h0a;
        default: uart_valid = 0;        
      endcase // case (counter)
   end
   
   osd_dem_uart
     u_uart (.*,
             .id (10'd2),
             .debug_in  (in_ports[2]),
             .debug_out (out_ports[2]),
             .out_char  (uart_char),
             .out_valid (uart_valid),
             .out_ready (uart_ready),
             .in_char   (),
             .in_valid  (),
             .in_ready  ('1));

   dii_channel #(.N(N)) dii_in ();
   dii_channel #(.N(N)) dii_out ();

   genvar i;
   generate
      for (i = 0; i < N; i++) begin
         assign out_ports[i].ready = dii_out.assemble(out_ports[i].data,
                                                      out_ports[i].last,
                                                      out_ports[i].valid,
                                                      i);
         // here is a bug for Verilator,it cannot recognize in_port[i] as an interface
         //assign dii_in.ready[i] = in_ports[i].assemble(dii_in.data[i],
         //                                              dii_in.last[i],
         //                                              dii_in.valid[i]);
         assign in_ports[i].data = dii_in.data[i];
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
