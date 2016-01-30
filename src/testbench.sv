
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

   logic [2:0] ar_addr;
   logic       ar_valid;
   logic       ar_ready;
   logic [1:0] r_resp;
   logic [7:0] r_data;
   logic       r_valid;
   logic       r_ready;
   logic [2:0] aw_addr;
   logic       aw_valid;
   logic       aw_ready;
   logic [7:0] w_data;
   logic       w_valid;
   logic       w_ready;
   logic [1:0] b_resp;
   logic       b_valid;
   logic       b_ready;
   
   reg [4:0]   counter;

   always_ff @(posedge clk) begin
      if (rst) begin
         counter <= 0;
      end else begin
         if (w_ready & (counter < 14)) begin
            counter <= counter + 1;
         end
      end
   end

   assign aw_valid = w_valid;
   assign aw_addr = 0;
   assign b_ready = 1;
   
   assign ar_valid = 0;
   assign ar_addr = 'x;
   assign r_ready = 0;
   
   always_comb @(*) begin
      w_valid = 1;
      w_data = 'x;
      
      case (counter)
        0: w_data = 8'h48;
        1: w_data = 8'h65;
        2: w_data = 8'h6c;
        3: w_data = 8'h6c;
        4: w_data = 8'h6f;
        5: w_data = 8'h20;
        6: w_data = 8'h57;
        7: w_data = 8'h6f;
        8: w_data = 8'h72;
        9: w_data = 8'h6c;
        10: w_data = 8'h64;
        11: w_data = 8'h21;
        12: w_data = 8'h0a;
        default: w_valid = 0;        
      endcase // case (counter)
   end
   
   osd_dem_uart_nasti
     u_uart (.*,
             .id (10'd2),
             .debug_in  (in_ports[2]),
             .debug_out (out_ports[2]));
   
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
