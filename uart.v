module uart
  /*
  default: 19200 baud, 8 data bit
  1 stop bit, 2^2 FIF0
  */
  #(
  parameter DBIT = 8, // data bit
            SB_TICK = 16,  // ticks for stop bit 
			DVSR = 163, 
			// DVSR = 50M / 16*baud rate
			DVSR_BIT = 8, // bit of DVSR
			FIFO_W = 2 // addr bits of FIFO
			// words in FIFO = 2^FIF0_W
  )
  (
  input wire clk, reset,
  input wire rd_uart, wr_uart, rx,
  input wire [7:0] w_data,
  output wire [7:0] r_data,
  output wire tx_full, rx_empty, tx
  );
  // signal declaration
  wire tick, rx_done_tick, tx_done_tick;
  wire tx_empty, tx_fifo_not_empty;
  wire [7:0] tx_fifo_out, rx_data_out;
  //body
  uart_rx // module RX
  # (.DBIT(DBIT),
     .SB_TICK(SB_TICK)
	 )
   uart_rx_unit
   (
   .clk(clk),
   .reset(reset),
   .rx(rx),
   .s_tick(s_tick),
   .rx_done_tick(rx_done_tick),
   .dout(rx_data_out)
   );
   uart_tx   //module TX
   #(.DBIT(DBIT),
      .SB_TICK(SB_TICK)
	  )
   uart_tx_unit
    (
	.clk(clk),
	.reset(reset),
	.tx_start(tx_fifo_not_empty),
	.s_tick(tick),
	.din(tx_fifo_out),
	.tx_done_tick(tx_done_tick),
	.tx(tx)
	);
	
	// Module FIFO for RX
	FIFO_buffer
	#(
	.B(DBIT),
	.W(FIFO_W)
	)
	fifo_rx_unit
	(
	.clk(clk),
	.reset(reset),
	.rd(rd_uart),
	.wr(rx_done_tick),
	.w_data(rx_data_out),
	.empty(rx_empty),
	.full(),
	.r_data(r_data)
	);
    // Module FIFO for TX	
  FIFO_buffer
	#(
	.B(DBIT), 
	.W(FIFO_W)
	) 
  fifo_tx_unit 
  (
  .clk(clk), 
  .reset(reset), 
  .rd(tx_done_tick), 
  .wr(wr_uart), 
  .w_data(w_data), 
  .empty(tx_empty), 
  .full(tx_full), 
  .r_data(tx_fifo_out)
  ); 
  assign tx_fifo_not_empty = ~tx_empty;
endmodule

  