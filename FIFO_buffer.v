/* 1. <=: cac thu tuc thuc hien song song, 
       = cac thu tuc thuc hien lan luot
	   
   2. depth = N; luu duoc N gia tri bang 
      cach su dung toan tu ** = ^
   
   3. Verilog-2001 ANSI-style port declarations that combine
      the direction, data type and port names in the module header. 
   
*/
module FIFO_buffer
  #(
  parameter B = 8, // number of bits in a word
            W = 4  // number of address bits
  )
  (
  input wire clk, reset,
  input wire rd, wr,
  input wire [B - 1 : 0] w_data, // du lieu ghi vao
  output wire empty, full,
  output wire [B - 1 : 0] r_data // du lieu doc ra
  );
  
  // signal declaration: khai bao tin hieu
  reg [B - 1 : 0] array_reg [2 ** W - 1 : 0];
  // register array: mang
  // width: B bit = 8 bit, depth: 2^w  = 2^4 = 16 
  reg [W - 1 : 0] w_prt_reg, w_ptr_next, w_ptr_succ;
  reg [W - 1 : 0] r_prt_reg, r_prt_next, r_prt_succ;
  reg full_reg, empty_reg, full_next, empty_next;
  wire wr_en;
  
  //body
  //register file write operation
  always @ (posedge clk)
    if(wr_en)   // khi o che do ghi
	  array_reg[w_prt_reg] <= w_data;

  //register file read operation
  assign r_data = array_reg[r_prt_reg];
  // when FIFO is not full
  assign wr_en = wr & ~full_reg;
  
  //fifo control block
  // register for read, and write pointers
  always @( posedge clk, posedge reset)
    if(reset)
	  begin
	    w_prt_reg <= 0;
		r_prt_reg <= 0;
		full_reg <= 1'b0;
		empty_reg <= 1'b1;
	  end
	else
	  begin
	    w_prt_reg <= w_ptr_next;
		r_prt_reg <= r_prt_next;
		full_reg <= full_next;
		empty_reg <= empty_next;
	  end
	  
  // next state logic for read/write pointers
  always @ *
    begin 
      // successive pointers values: 
	  // gia tri con tro tiep theo
	  w_ptr_succ = w_prt_reg + 1;
	  r_prt_succ = r_prt_reg + 1;
	  // default: keep old values: 
	  w_ptr_next = w_prt_reg;
	  r_prt_next = r_prt_reg;
	  full_next = full_reg;
	  empty_next = empty_reg;
	  case ({wr, rd})
	    //2'b00: no op
		2'b01: // read
		  if (~empty_reg) // thanh ghi khong trong
		    begin
			  r_prt_next =  r_prt_succ;
			  full_next = 1'b0;
			  if(r_prt_succ == w_prt_reg)
			    empty_next = 1'b1;
			end
		2'b10: // write
		  if(~full_reg) // thanh ghi chua full
		    begin
			  w_ptr_next = w_ptr_succ;
			  empty_next = 1'b0;
			  if( w_ptr_succ == r_prt_reg)
			    full_next = 1'b1;
			end
		2'b11://write/ read
		  begin
		    w_ptr_next = w_ptr_succ;
			r_prt_next = r_prt_succ;
		  end
	  endcase
	end
//output
  assign full = full_reg;
  assign empty = empty_reg;
endmodule
  