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
	reg  [7:0] din   = "\0";
	reg        oe    = 0;

	wire [7:0]
		dout;

	wire
		int,
		rdy;

	UART #(
		.Bauds(Bauds)
	) uart(
		.CLK(CLK),
		.RST(0),
		.DIN(din),
		.DOUT(dout),
		.OE(oe),
		.RDY(rdy),
		.TXD(TXD),
		.RXD(RXD),
		.INT(int)
	);

	always @(posedge CLK) begin
		din <= dout;
		oe <= int;
	end
endmodule
