`include "BRAM1.v"
`include "UART.v"

module SoC #(
	parameter
		Bauds = 9_600
) (
	input
		CLK,
		RXD,

	output
		TXD
);
	reg [18:0] addr = 0;
	reg  [7:0] rtou = 'hff;

	wire [7:0]
		rout,
		uout;

	wire
		uhasc,
		urdy;

	BRAM1 #(
		.Hexfile("hello.hex")
	) text(
		.CLK(CLK),
		.ADDR(addr),
		.WR('b0),
		.DIN('b0),
		.DOUT(rout)
	);

	UART #(
		.Bauds(Bauds)
	) uart(
		.CLK(CLK),
		.DIN(rtou),
		.DOUT(uout),
		.OE(urdy),
		.RDY(urdy),
		.TXD(TXD),
		.RXD(RXD),
		.INT(uhasc)
	);

	/*
	 * Step through the stored string
	 */
	always @(posedge CLK) begin
		if (urdy)  rtou = rout;
		if (|rtou) addr <= addr+urdy;
	end
endmodule
