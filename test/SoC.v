`include "SoC.v"
`timescale 1ns/100ps

module SoC_test;
	wire [2:0] rgb_;
	wire       txd;

	reg
		clk = 1,
		rst = 0;

	localparam
		T = 1_000_000_000 / `FCLK;

	SoC #(
		.Bauds(115_200),
		.Fclk(`FCLK)
	) soc(
		.CLK(clk),
		.RST_(!rst),
		.TXD(txd),
		.RGB_(rgb_)
	);

	initial begin
		$dumpfile(`DUMP);
		$dumpvars(0, SoC_test);

		#300_000 $finish;
	end

	always
		#(T/2) clk <= !clk;
endmodule
