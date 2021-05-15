module Delay #(
	parameter
		Wdata = 1,
		Delay = 1
) (
	input [Wdata-1:0] IN,
	input             CLK,

	output [Wdata-1:0]
		OUT
);
	genvar
		bit;

	/*
	 * Shift bits through the delay line
	 */
	generate
		for (bit = 0; bit < Wdata; bit = bit+1) begin
			reg [Delay-1:0]
				delay;

			assign
				OUT[bit] = delay[0];

			always @(posedge CLK)
				delay <= {delay>>1, IN[bit]};
		end
	endgenerate
endmodule