module tb_FIFO_buffer;
  //signal declaration
  localparam B = 8;
  localparam W = 4;
  localparam T = 10; // clock period
  
  reg clk, reset;
  reg rd, wr;
  wire [B - 1 : 0] r_data;
  reg [B - 1 : 0] w_data;
  wire full, empty;
  
FIFO_buffer uut
(
.clk(clk),
.reset(reset),
.rd(rd),
.wr(wr),
.w_data(w_data),
.r_data(r_data),
.empty(empty),
.full(full)
);

always 
begin
  clk = 1'b1;
  #(T/2);
  clk = 1'b0;
  #(T/2);
end
// reset for the first half cycle

initial 
begin
  reset = 1'b1;
  rd = 1'b0;
  wr = 1'b0;
  @(negedge clk);
  reset = 1'b0;
end
// test vectors
initial 
begin
  //write
  @(negedge clk);
  w_data = 8'b0000_0111;
  wr = 1'b1;
  @(negedge clk)
  wr = 1'b0;
  //write
  repeat(1) @ (negedge clk);
  w_data = 8'b0000_1000;
  wr = 1'b1;
  @(negedge clk)
  wr = 1'b0;
  //write
  repeat(1) @ (negedge clk);
  w_data = 8'b0000_0110;
  wr = 1'b1;
  @(negedge clk)
  wr = 1'b0;
  //read
  repeat(1) @ (negedge clk);
  rd = 1'b1;
  @(negedge clk)
  rd = 1'b0;
end
endmodule