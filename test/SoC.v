`include "SoC.v"
`timescale 1ns/100ps

module SoC_test;
	wire
		txd;

	reg
		clk = 1,
		rst = 0;

	localparam
		T = 1_000_000_000 / `FCLK;

	SoC #(
		.Bauds(9_600),
		.Fclk(`FCLK)
	) soc(
		.CLK(clk),
		.TXD(txd)
	);

	initial begin
		$dumpfile(`DUMP);
		$dumpvars(0, SoC_test);

		#20_000_000 $finish;
	end

	always
		#(T/2) clk <= !clk;
endmodule
