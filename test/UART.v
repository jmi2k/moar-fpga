`include "UART.v"
`timescale 1ns/100ps

module UART_test;
	reg  [7:0] din = "U";
	wire [2:0] rgb_;

	reg
		clk = 1,
		rst = 0,
		oe  = 0;

	wire
		rdy,
		txd;

	UART #(
		.Fclk(50_000_000)
	) uart(
		.CLK(clk),
		.RST(rst),
		.DIN(din),
		.OE(oe),
		.RDY(rdy),
		.TXD(txd)
	);

	initial begin
		$dumpfile("UART.vcd");
		$dumpvars(0, UART_test);

		    #5_000 oe <= 1;
		       #20 oe <= 0;
		#2_000_000 oe <= 1;
		#2_000_000 $finish;
	end

	always
		#10 clk <= !clk;
endmodule
