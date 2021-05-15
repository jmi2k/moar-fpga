`include "BRAM1.v"
`include "UART.v"
`include "VGA.v"

module SoC #(
	parameter
		Bauds = 9_600,
		W     = 640,
		H     = 480
) (
	input
		CLK,
		RXD,

	output
		HS_, VS_,
		R, G, B,
		TXD
);
	reg [18:0] taddr = 0;
	reg  [7:0] rtou  = 'hff;

	wire [$clog2(W*H)-1:0] vaddr;
	wire   [$clog2(W)-1:0] x;
	wire   [$clog2(H)-1:0] y;

	wire [7:0]
		tout,
		uout;

	wire
		hb,
		vb,
		ven,
		uhasc,
		urdy,
		vout;

	assign
		ven   = !hb & !vb,
		R     = ven & vout,
		G     = ven & vout,
		B     = ven & vout,
		vaddr = W*y + x;

	BRAM1 #(
		.Hexfile("hello.hex")
	) text(
		.CLK(CLK),
		.ADDR(taddr),
		.WR('b0),
		.DIN('b0),
		.DOUT(tout)
	);

	BRAM1 #(
		.Hexfile("EVA.hex"),
		.Ncells(W*H),
		.Wdata(1)
	) vram(
		.CLK(CLK),
		.ADDR(vaddr),
		.WR('b0),
		.DIN('b0),
		.DOUT(vout)
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

	VGA vga(
		.CLK(CLK),
		.HB(hb),
		.VB(vb),
		.HS_(HS_),
		.VS_(VS_),
		.X(x),
		.Y(y)
	);

	/*
	 * Step through the stored string
	 */
	always @(posedge CLK) begin
		if (urdy)  rtou = tout;
		if (|rtou) taddr <= taddr+urdy;
	end
endmodule
