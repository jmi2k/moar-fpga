`include "UART.v"

module SoC #(
	parameter
		Bauds = 300,
		Fclk  = 48_000_000
) (
	output [2:0] RGB_,

	input
		CLK,
		RST_,

	output
		MISO,
		TXD
);
	reg  [7:0]            hello [0:1024];
	reg  [$clog2(Fclk):0] tick  = 0;
	reg  [30:0]           index = 0;
	reg  [7:0]            din   = "\0";
	reg  [2:0]            rgb   = 0;
	wire                  rdy;

	reg
		blink = 0,
		oe    = 0;

	UART #(
		.Bauds(Bauds),
		.Fclk(Fclk)
	) uart(
		.CLK(CLK),
		.RST(!RST_),
		.DIN(din),
		.OE(oe),
		.RDY(rdy),
		.TXD(TXD)
	);

	assign
		RGB_ = ~rgb,
		MISO = blink;

	initial
		$readmemh("hello.hex", hello);

	always @(posedge CLK)
		if (rdy) begin
			index <= hello[index+1] == 0 ? 0 : index+1;
			din <= hello[index];
			oe <= 1;
		end else
			oe <= 0;

	always @(posedge CLK) begin
		tick <= tick+1;
		case (tick)
			Fclk/3-1: begin
				rgb <= rgb+1;
				blink <= !blink;
			end
			Fclk/3:
				tick <= 0;
		endcase
	end
endmodule
