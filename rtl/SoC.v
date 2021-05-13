`include "UART.v"

module SoC #(
	parameter
		Bauds = 9_600,
		Fclk  = `FCLK
) (
	input
		CLK,
		RXD,

	output
		TXD
);
	reg [30:0] index = 0;
	reg  [7:0] din   = "0";
	reg        oe    = 0;

	wire [7:0]
		dout;

	wire
		rdy,
		int;

	UART #(
		.Bauds(Bauds),
		.Fclk(Fclk)
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
		oe <= 1;
	end
endmodule
