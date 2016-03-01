
import dii_package::dii_flit;

module testbench
  (
   input clk, rst,
   input glip_logic_rst,
   glip_channel.slave fifo_in,
   glip_channel.master fifo_out
   );

   localparam N = 4;
   localparam MAX_PKT_LEN = 16;

   dii_flit [N-1:0] dii_out; logic [N-1:0] dii_out_ready;
   dii_flit [N-1:0] dii_in; logic [N-1:0] dii_in_ready;   

   osd_him
     u_him(.*,
           .glip_in        ( fifo_in           ),
           .glip_out       ( fifo_out          ),
           .dii_out        ( dii_out[0]        ),
           .dii_out_ready  ( dii_out_ready[0]  ),
           .dii_in         ( dii_in[0]         ),
           .dii_in_ready   ( dii_in_ready[0]   )
           );

   logic sys_rst, cpu_rst;

   osd_scm
     #(.SYSTEMID(16'hdead), .NUM_MOD(N-1), .MAX_PKT_LEN(MAX_PKT_LEN))
   u_scm(.*,
         .id              ( 10'd1            ),
         .debug_in        ( dii_in[1]        ),
         .debug_in_ready  ( dii_in_ready[1]  ),
         .debug_out       ( dii_out[1]       ),
         .debug_out_ready ( dii_out_ready[1] )
         );

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
      if (cpu_rst) begin
         counter <= 5'h0;
      end else begin
         if ((w_valid & w_ready) |
             (ar_valid & ar_ready)) begin
            counter <= counter + 1;
         end
      end
   end

   assign aw_valid = w_valid;
   assign b_ready = 1;
   
   assign r_ready = 1;
   
   always @(*) begin
      w_valid = 1;
      ar_valid = 0;
      aw_addr = 0;
      w_data = 'x;
      ar_addr = 'x;
      
      case (counter)
        // Test Divisor write
        0: begin
           w_data = 8'h80;
           aw_addr = 3;
        end
        1: begin
           w_data = 8'hde;
           aw_addr = 0;
        end
        2: begin
           w_data = 8'had;
           aw_addr = 0;
        end
        3: begin
           w_data = 8'h00;
           aw_addr = 3;
        end
        // Test THRE read
        4: begin
           w_valid = 0;
           ar_valid = 1;
           ar_addr = 5;
        end     
        5: w_data = 8'h48;
        // Test THRE read
        6: begin
           w_valid = 0;
           ar_valid = 1;
           ar_addr = 5;
        end     
        7: w_data = 8'h65;
        8: w_data = 8'h6c;
        9: w_data = 8'h6c;
        10: w_data = 8'h6f;
        11: w_data = 8'h20;
        12: w_data = 8'h57;
        13: w_data = 8'h6f;
        14: w_data = 8'h72;
        15: w_data = 8'h6c;
        16: w_data = 8'h64;
        17: w_data = 8'h21;
        18: w_data = 8'h0a;
        default: w_valid = 0;        
      endcase // case (counter)
   end
   
   osd_dem_uart_nasti
     u_uart (.*,
             .id              ( 10'd2            ),
             .debug_in        ( dii_in[2]        ),
             .debug_in_ready  ( dii_in_ready[2]  ),
             .debug_out       ( dii_out[2]       ),
             .debug_out_ready ( dii_out_ready[2] )
             );

   logic                                  req_valid;
   logic                                  req_ready;
   logic                                  req_rw;
   logic [30:0]                           req_addr;
   logic                                  req_burst;
   logic [15:0]                           req_size;

   logic                                  write_valid;
   logic [511:0]                          write_data;
   logic [63:0]                           write_strb;   
   logic                                  write_ready;
   
   logic                                  read_valid;
   logic [511:0]                          read_data;
   logic                                  read_ready;

   assign req_ready = 1;
   assign write_ready = 1;
   
   osd_mam
     #(.DATA_WIDTH(512), .BASE_ADDR(0), .MEM_SIZE(1024*1024*1024),
       .ADDR_WIDTH(32), .MAX_PKT_LEN(MAX_PKT_LEN))
   u_mam (.*,
          .id (10'd3),
          .debug_in        ( dii_in[3]        ),
          .debug_in_ready  ( dii_in_ready[3]  ),
          .debug_out       ( dii_out[3]       ),
          .debug_out_ready ( dii_out_ready[3] )
          );

   debug_ring
     #(.PORTS(N))
   u_ring(.*,
          .dii_in        ( dii_out       ),
          .dii_in_ready  ( dii_out_ready ),
          .dii_out       ( dii_in        ),
          .dii_out_ready ( dii_in_ready  )
          );

endmodule // testbench
