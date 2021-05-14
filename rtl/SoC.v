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
		rdy,
		uhasc;

	BRAM1 #(
		.Hexfile("hello.hex")
	) bram1(
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
		.RST('b0),
		.DIN(rtou),
		.DOUT(uout),
		.OE(uhasc),
		.RDY(rdy),
		.TXD(TXD),
		.RXD(RXD),
		.INT(uhasc)
	);

	/*
	 * Step through the stored string
	 */
	always @(posedge CLK) begin
		if (uhasc) rtou <= rout;
		if (|rtou) addr <= addr+uhasc;
	end
endmodule
