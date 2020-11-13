`include "UART.v"
`timescale 1ns/100ps

module UART_test;
	reg  [7:0] din = "U";
	wire [7:0] dout;
	wire [2:0] rgb_;

	reg
		clk = 1,
		rst = 0,
		rxd = 1,
		oe  = 0;

	wire
		rdy,
		txd,
		int;

	UART #(
		.Fclk(50_000_000)
	) uart(
		.CLK(clk),
		.RST(rst),
		.DIN(din),
		.DOUT(dout),
		.OE(oe),
		.RDY(rdy),
		.TXD(txd),
		.RXD(rxd),
		.INT(int)
	);

	initial begin
		$dumpfile(`DUMP);
		$dumpvars(0, UART_test);

		    #5_000 oe <= 1;
		       #20 oe <= 0;

		/* Send good frame */
		#2_000_000 rxd <= 0; /* Start */
		     #8680 rxd <= 1; /* Data... */
		     #8680 rxd <= 0;
		     #8680 rxd <= 0;
		     #8680 rxd <= 0;
		     #8680 rxd <= 0;
		     #8680 rxd <= 1;
		     #8680 rxd <= 0;
		     #8680 rxd <= 0; /* Stop */
		     #8680 rxd <= 1; /* Finished */

		/* Send broken frame: stop bit is flipped! */
		  #200_000 rxd <= 0; /* Start */
		     #8680 rxd <= 0; /* Data... */
		     #8680 rxd <= 1;
		     #8680 rxd <= 1;
		     #8680 rxd <= 1;
		     #8680 rxd <= 1;
		     #8680 rxd <= 0;
		     #8680 rxd <= 1;
		     #8680 rxd <= 1;
		     #8680 rxd <= 0; /* Stop */
		     #8680 rxd <= 1; /* Finished */

		/* Send broken frame: start bit flips before being sampled! */
		  #200_000 rxd <= 0; /* Start */
		      #100 rxd <= 1;
		     #8580 rxd <= 0; /* Data... */
		     #8680 rxd <= 0;
		     #8680 rxd <= 0;
		     #8680 rxd <= 0;
		     #8680 rxd <= 1;
		     #8680 rxd <= 0;
		     #8680 rxd <= 0; /* Stop */
		     #8680 rxd <= 1; /* Finished */
		  #200_000 $finish;
	end

	always
		#10 clk <= !clk;
endmodule
