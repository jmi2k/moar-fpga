module BRAM1 #(
	parameter
		Hexfile = 'bx,
		Ncells  = 1_024,
		Wdata   = 8
) (
	input [$bits(Ncells)-1:0] ADDR,
	input         [Wdata-1:0] DIN,

	input
		CLK,
		WR,

	output [Wdata-1:0]
		DOUT
);
	reg [Wdata-1:0]
		mem [Ncells-1:0];

	assign
		DOUT = WR ? DIN : mem[ADDR];

	/*
	 * Load initial data into memory if provided
	 */
	initial
		if (Hexfile !== 'bx) $readmemh(Hexfile, mem);

	/*
	 * Read/write data
	 */
	always @(posedge CLK)
		if (WR)
			mem[ADDR] <= DIN;
endmodule
