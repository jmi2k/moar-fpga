`include "UART.v"

module SoC #(
	parameter
		Bauds = 300,
		Fclk  = `FCLK
) (
	output [2:0] RGB_,

	input
		CLK,
		RST_,
		RXD,

	output
		MISO,
		TXD
);
	reg  [30:0] index = 0;
	reg  [7:0]  din   = "\0";
	reg  [2:0]  rgb   = 0;
	wire [7:0]  dout;

	reg
		blink = 0,
		oe    = 0;

	wire
		rdy,
		int;

	UART #(
		.Bauds(Bauds),
		.Fclk(Fclk)
	) uart(
		.CLK(CLK),
		.RST(!RST_),
		.DIN(din),
		.DOUT(dout),
		.OE(oe),
		.RDY(rdy),
		.TXD(TXD),
		.RXD(RXD),
		.INT(int)
	);

	assign
		RGB_ = ~rgb,
		MISO = blink;

	always @(posedge CLK) begin
		din <= dout;
		oe <= int;
	end
endmodule
