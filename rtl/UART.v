`include "UART/TX.v"
`include "UART/RX.v"

module UART #(
	parameter
		Bauds = 115_200,
		Wdata = 8,
		Wstop = 1
) (
	input  [Wdata-1:0] DIN,
	output [Wdata-1:0] DOUT,

	input
		CLK,
		RST,
		RXD,
		OE,

	output
		TXD,
		RDY,
		INT
);
	TX #(
		.Bauds(Bauds),
		.Wdata(Wdata),
		.Wstop(Wstop)
	) tx(
		.CLK(CLK),
		.RST(RST),
		.DIN(DIN),
		.TXD(TXD),
		.OE(OE),
		.RDY(RDY)
	);

	RX #(
		.Bauds(Bauds),
		.Wdata(Wdata),
		.Wstop(Wstop)
	) rx(
		.CLK(CLK),
		.RST(RST),
		.DOUT(DOUT),
		.RXD(RXD),
		.INT(INT)
	);
endmodule
